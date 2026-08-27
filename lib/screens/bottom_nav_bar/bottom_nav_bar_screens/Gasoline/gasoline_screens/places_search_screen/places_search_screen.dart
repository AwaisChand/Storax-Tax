import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // 🔥 Fixed the API Key typo to match your active, working key (ending in GHO0E)
  final String apiKey = "AIzaSyBx7X2S83I4ei7X51AOUOiqiaj-e7gHO0E";

  void searchPlaces(String input) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 300), () async {
      if (input.isEmpty) {
        if (!mounted) return;
        setState(() => predictions = []);
        return;
      }

      final url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?input=$input"
          "&key=$apiKey"
          "&sessiontoken=$sessionToken";

      try {
        final res = await http.get(Uri.parse(url));
        final data = json.decode(res.body);

        print(data);

        if (!mounted) return;

        setState(() {
          predictions = data['predictions'] ?? [];
        });
      } catch (e) {
        print("PLACE SEARCH ERROR: $e");
      }
    });
  }

  Future<Map<String, dynamic>> getPlaceDetail(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId&key=$apiKey";

    final res = await http.get(Uri.parse(url));
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
            child: ListView.builder(
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

                    final lat = detail['geometry']['location']['lat'];
                    final lng = detail['geometry']['location']['lng'];

                    Navigator.pop(context, {
                      "name": item['description'],
                      "lat": lat,
                      "lng": lng,
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