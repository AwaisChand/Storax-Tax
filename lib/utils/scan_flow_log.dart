import 'package:flutter/foundation.dart';

/// Filter the console with `[GasolineScan]` (gasoline-basic add receipt flow).
void gasolineScanLog(String message) {
  debugPrint('[GasolineScan] $message');
}

/// Filter the console with `[TaxManagerScan]` (Tax Manager / files scan flow).
void taxManagerScanLog(String message) {
  debugPrint('[TaxManagerScan] $message');
}

/// Filter the console with `[QuebecScan]` (Uber Québec scan flow).
void quebecScanLog(String message) {
  debugPrint('[QuebecScan] $message');
}
