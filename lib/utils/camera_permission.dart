import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Ensures camera permission **before** invoking native document scanners.
///
/// Background:
/// - `cunning_document_scanner` (iOS) and parts of the Android pipeline
///   internally call `Permission.camera.request()`. On iOS the system
///   permission prompt is only shown **once**; subsequent calls return the
///   cached denial (`permanentlyDenied`) without showing any UI. The package
///   then throws `Exception('Permission not granted')`, which is opaque to
///   the user.
///
/// This helper handles all states explicitly:
///  - `granted`        → returns `true`.
///  - `denied`         → triggers the system prompt.
///  - `permanentlyDenied` / `restricted` → shows a localised dialog offering
///    to open the app's iOS/Android Settings page.
///
/// Returns `true` only when permission is granted at the time of the call.
Future<bool> ensureCameraPermission(BuildContext context) async {
  PermissionStatus status = await Permission.camera.status;

  if (status.isGranted || status.isLimited) {
    return true;
  }

  if (status.isDenied) {
    status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) {
      return true;
    }
  }

  if (!context.mounted) return false;

  await _showOpenSettingsDialog(context);
  return false;
}

Future<void> _showOpenSettingsDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      return AlertDialog(
        title: const Text('Camera access needed'),
        content: const Text(
          'Storatax needs camera access to scan receipts and documents. '
          'Please enable it from Settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      );
    },
  );
}
