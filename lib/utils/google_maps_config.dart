import 'dart:io';

import 'package:http/http.dart' as http;

class GoogleMapsConfig {
  static const apiKey = 'AIzaSyCtVdR79rZ-cTDtXYrURz1YmGLmeCiBIDo';
  static const iosBundleId = 'com.storatax.app';
  static const androidPackage = 'com.storatax.app';

  /// Google rejects iOS Maps SDK / Places HTTP calls if the key is
  /// iOS-restricted and this header is missing.
  static Map<String, String> headers() {
    if (Platform.isIOS) {
      return {'X-Ios-Bundle-Identifier': iosBundleId};
    }
    // Do not send Android package without SHA-1; Google can deny Places.
    if (Platform.isAndroid) {
      return {};
    }
    return {};
  }

  static Future<http.Response> get(Uri uri) {
    return http.get(uri, headers: headers());
  }
}
