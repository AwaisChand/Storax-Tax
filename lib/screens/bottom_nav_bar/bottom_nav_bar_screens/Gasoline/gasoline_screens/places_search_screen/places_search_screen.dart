import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:storatax/utils/google_maps_config.dart';

import '../../../../../../res/app_assets.dart';

class PlaceSearchScreen extends StatefulWidget {
  final bool isFrom;

  const PlaceSearchScreen({super.key, required this.isFrom});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController controller = TextEditingController();
  String sessionToken = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  List predictions = [];
  Timer? debounce;
  String? searchError;

  void searchPlaces(String input) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 300), () async {
      if (input.isEmpty) {
        if (!mounted) return;
        setState(() {
          predictions = [];
          searchError = null;
        });
        return;
      }

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': input,
          'key': GoogleMapsConfig.apiKey,
          'sessiontoken': sessionToken,
        },
      );

      try {
        final res = await GoogleMapsConfig.get(uri);
        final data = json.decode(res.body);

        debugPrint('PLACE SEARCH: ${data['status']} ${data['error_message']}');

        if (!mounted) return;

        final status = data['status']?.toString() ?? '';
        setState(() {
          predictions = data['predictions'] ?? [];
          if (status == 'OK' || status == 'ZERO_RESULTS') {
            searchError = null;
          } else {
            searchError = data['error_message']?.toString() ?? status;
          }
        });
      } catch (e) {
        debugPrint('PLACE SEARCH ERROR: $e');
        if (!mounted) return;
        setState(() {
          predictions = [];
          searchError = e.toString();
        });
      }
    });
  }

  Future<Map<String, dynamic>?> getPlaceDetail(String placeId) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': GoogleMapsConfig.apiKey,
        'sessiontoken': sessionToken,
        'fields': 'geometry,formatted_address,name',
      },
    );

    final res = await GoogleMapsConfig.get(uri);
    final data = json.decode(res.body);

    return data['result'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: TextField(
          controller: controller,
          autofocus: true,
          onChanged: searchPlaces,
          decoration: const InputDecoration(
            hintText: "Search location",
            border: InputBorder.none,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundImg),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔥 UI FIX: Wrapped the suggestion list inside a Positioned.fill
          /// to prevent layout rendering breaks inside the Stack structure
          Positioned.fill(
            child: searchError != null && predictions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        searchError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final item = predictions[index];

                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.grey),
                  title: Text(
                    item['description'],
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () async {
                    final detail = await getPlaceDetail(item['place_id']);
                    final location = detail?['geometry']?['location'];
                    if (location == null) return;

                    Navigator.pop(context, {
                      "name": item['description'],
                      "lat": location['lat'],
                      "lng": location['lng'],
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}