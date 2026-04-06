import 'dart:io';
import 'package:flutter/services.dart';

class IOSScanner {
  static const MethodChannel _channel = MethodChannel('vision_scanner');

  static Future<String?> scanDocument() async {
    if (!Platform.isIOS) return null;

    try {
      final String? path = await _channel.invokeMethod('scanDocument');
      return path;
    } catch (e) {
      print("iOS Scanner error: $e");
      return null;
    }
  }
}