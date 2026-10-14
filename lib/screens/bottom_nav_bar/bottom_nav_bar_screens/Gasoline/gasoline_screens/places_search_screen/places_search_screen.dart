import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/google_maps_config.dart';

import '../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import 'widget/place_search_status_view.dart';

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
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  List predictions = [];
  Timer? debounce;
  String? searchError;
  String _placeStatus = '';

  void searchPlaces(String input) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 300), () async {
      if (input.isEmpty) {
        if (!mounted) return;
        setState(() {
          predictions = [];
          searchError = null;
          _placeStatus = '';
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
        final apiMessage = data['error_message']?.toString();
        setState(() {
          predictions = data['predictions'] ?? [];
          _placeStatus =
              status == 'OK' && predictions.isEmpty ? 'ZERO_RESULTS' : status;
          if (status == 'OK' && predictions.isNotEmpty) {
            searchError = null;
          } else {
            searchError = _messageForPlaceStatus(
              _placeStatus.isEmpty ? 'ZERO_RESULTS' : _placeStatus,
              apiMessage,
            );
          }
        });
      } catch (e) {
        debugPrint('PLACE SEARCH ERROR: $e');
        if (!mounted) return;
        setState(() {
          predictions = [];
          _placeStatus = 'NETWORK_ERROR';
          searchError = _t(
            'placeNetworkErrorText',
            'No internet connection. Please check your network and try again.',
          );
        });
      }
    });
  }

  Future<Map<String, dynamic>?> getPlaceDetail(String placeId) async {
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
          'place_id': placeId,
          'key': GoogleMapsConfig.apiKey,
          'sessiontoken': sessionToken,
          'fields': 'geometry,formatted_address,name',
        });

    final res = await GoogleMapsConfig.get(uri);
    final data = json.decode(res.body);

    return data['result'];
  }

  String _t(String key, String fallback) {
    final value = AppLocalizations.of(context)?.translate(key);
    if (value == null || value.isEmpty || value == key) return fallback;
    return value;
  }

  String _messageForPlaceStatus(String status, String? apiMessage) {
    switch (status) {
      case 'ZERO_RESULTS':
        return _t(
          'placeZeroResultsText',
          'We could not match that search. Try another name or spelling.',
        );
      case 'OVER_QUERY_LIMIT':
        return _t(
          'placeOverQueryLimitText',
          'Location search limit reached. Please try again later.',
        );
      case 'REQUEST_DENIED':
        return _t(
          'placeRequestDeniedText',
          'Location search is not available right now.',
        );
      case 'INVALID_REQUEST':
        return _t('placeInvalidRequestText', 'Please enter a valid location.');
      case 'UNKNOWN_ERROR':
        return _t(
          'placeUnknownErrorText',
          'Unable to search locations. Please try again.',
        );
      default:
        if (apiMessage != null && apiMessage.trim().isNotEmpty) {
          return apiMessage;
        }
        return _t(
          'placeUnknownErrorText',
          'Unable to search locations. Please try again.',
        );
    }
  }

  Widget _statusBody() {
    final idle = controller.text.trim().isEmpty;
    if (idle) {
      return PlaceSearchStatusView(
        key: const ValueKey('place_idle'),
        icon: Icons.location_on_rounded,
        title: _t('placeIdleTitleText', 'Find a Location'),
        subtitle: _t(
          'placeIdleSubtitleText',
          'Start typing an address, city, or landmark.',
        ),
        pulse: true,
      );
    }

    switch (_placeStatus) {
      case 'OVER_QUERY_LIMIT':
        return PlaceSearchStatusView(
          key: const ValueKey('place_limit'),
          icon: Icons.hourglass_empty_rounded,
          title: _t('placeOverQueryLimitTitleText', 'Search Limit Reached'),
          subtitle: searchError ?? '',
        );
      case 'REQUEST_DENIED':
        return PlaceSearchStatusView(
          key: const ValueKey('place_denied'),
          icon: Icons.lock_outline_rounded,
          title: _t('placeRequestDeniedTitleText', 'Search Unavailable'),
          subtitle: searchError ?? '',
        );
      case 'INVALID_REQUEST':
        return PlaceSearchStatusView(
          key: const ValueKey('place_invalid'),
          icon: Icons.edit_off_rounded,
          title: _t('placeInvalidRequestTitleText', 'Invalid Search'),
          subtitle: searchError ?? '',
        );
      case 'NETWORK_ERROR':
        return PlaceSearchStatusView(
          key: const ValueKey('place_network'),
          icon: Icons.wifi_off_rounded,
          title: _t('placeNetworkErrorTitleText', 'No Connection'),
          subtitle: searchError ?? '',
        );
      case 'UNKNOWN_ERROR':
        return PlaceSearchStatusView(
          key: const ValueKey('place_unknown'),
          icon: Icons.error_outline_rounded,
          title: _t('placeUnknownErrorTitleText', 'Search Failed'),
          subtitle: searchError ?? '',
        );
      default:
        return PlaceSearchStatusView(
          key: const ValueKey('place_empty'),
          icon: Icons.location_off_rounded,
          title: _t('placeZeroResultsTitleText', 'No Location Found'),
          subtitle:
              searchError ??
              _t(
                'placeZeroResultsText',
                'We could not match that search. Try another name or spelling.',
              ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.goldenOrangeColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 48,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.blackColor,
          ),
        ),
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            onChanged: searchPlaces,
            cursorColor: AppColors.goldenOrangeColor,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(
                    context,
                  )!.translate("searchLocationText") ??
                  'Search Location',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.pureGrayColor,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.goldenOrangeColor,
              ),
              suffixIcon:
                  controller.text.isEmpty
                      ? null
                      : IconButton(
                        onPressed: () {
                          controller.clear();
                          searchPlaces('');
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.mediumGrayColor,
                        ),
                      ),
              filled: true,
              fillColor: AppColors.whiteColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.goldenOrangeColor,
                  width: 1.4,
                ),
              ),
            ),
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child:
                  controller.text.trim().isEmpty ||
                          (searchError != null && predictions.isEmpty)
                      ? _statusBody()
                      : ListView.builder(
                        key: const ValueKey('place_results'),
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          final item = predictions[index];

                          return ListTile(
                            leading: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.goldenOrangeColor,
                            ),
                            title: Text(
                              item['description'],
                              style: GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onTap: () async {
                              final detail = await getPlaceDetail(
                                item['place_id'],
                              );
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
          ),
        ],
      ),
    );
  }
}
