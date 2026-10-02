import 'dart:io';

import 'package:http/http.dart' as http;

class GoogleMapsConfig {
  static const apiKey = 'AIzaSyBx7X2S83I4ei7X51AOUOiqiaj-e7gHO0E';
  static const iosBundleId = 'com.storatax.app';
  static const androidPackage = 'com.storatax.app';

  /// Google rejects iOS Maps SDK / Places HTTP calls if the key is
  /// iOS-restricted and this header is missing.
  static Map<String, String> headers() {
    if (Platform.isIOS) {
      return {'X-Ios-Bundle-Identifier': iosBundleId};
    }
    if (Platform.isAndroid) {
      return {'X-Android-Package': androidPackage};
    }
    return {};
  }

  static Future<http.Response> get(Uri uri) {
    return http.get(uri, headers: headers());
  }
}
