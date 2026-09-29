import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../data/network/network_api_service.dart';
import '../../../res/app_url.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../view_models/tax_manager_view_model/tax_manager_view_model.dart';

class CropScanResult {
  const CropScanResult({
    required this.file,
    required this.fileName,
    this.scanData,
    this.redactedTempPath,
  });

  final File file;
  final String fileName;
  final Map<String, dynamic>? scanData;
  final String? redactedTempPath;
}

enum _CropPhase { crop, scanning, preview }

class CropDocumentDialog extends StatefulWidget {
  const CropDocumentDialog({
    super.key,
    required this.imageFile,
    required this.fileName,
  });

  final File imageFile;
  final String fileName;

  static Future<CropScanResult?> open(
    BuildContext context, {
    required File imageFile,
    required String fileName,
  }) {
    return showDialog<CropScanResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CropDocumentDialog(
        imageFile: imageFile,
        fileName: fileName,
      ),
    );
  }

  @override
  State<CropDocumentDialog> createState() => _CropDocumentDialogState();
}

class _CropDocumentDialogState extends State<CropDocumentDialog>
    with SingleTickerProviderStateMixin {
  final _cropController = CropController();
  late final AnimationController _scanLine;

  Uint8List? _bytes;
  _CropPhase _phase = _CropPhase.crop;
  bool _cropping = false;
  File? _scannedFile;
  File? _redactedFile;
  String? _redactedUrl;
  String? _redactedTempPath;
  Map<String, dynamic>? _scanData;

  String _t(String key, String fallback) =>
      AppLocalizations.of(context)?.translate(key) ?? fallback;

  @override
  void initState() {
    super.initState();
    _scanLine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    try {
      final raw = await widget.imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(raw, targetWidth: 1800);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!mounted) return;
      setState(() => _bytes = png?.buffer.asUint8List() ?? raw);
    } catch (_) {
      final bytes = await widget.imageFile.readAsBytes();
      if (!mounted) return;
      setState(() => _bytes = bytes);
    }
  }

  @override
  void dispose() {
    _scanLine.dispose();
    super.dispose();
  }

  Future<File> _writeTemp(Uint8List bytes, {String ext = 'jpg'}) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/tax_scan_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _useFullImage() async {
    if (_bytes == null) return;
    await _runScan(widget.imageFile);
  }

  Future<void> _cropAndScan() async {
    if (_cropping || _bytes == null) return;
    setState(() => _cropping = true);
    try {
      final source = await _writeTemp(_bytes!, ext: 'png');
      final cropped = await _cropToReceiptCorners(source);
      if (!mounted) return;
      await _runScan(cropped);
    } catch (e, st) {
      debugPrint('Auto crop failed: $e\n$st');
      if (!mounted) return;
      setState(() => _cropping = false);
      Utils.toastMessage('Could not crop the receipt. Try again.');
    }
  }

  Future<Rect?> _detectReceiptBounds(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null || decoded.width < 32 || decoded.height < 32) {
      return null;
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(file.absolute.path),
      );
      if (result.blocks.isEmpty) return null;

      var minX = double.infinity;
      var minY = double.infinity;
      var maxX = 0.0;
      var maxY = 0.0;
      for (final block in result.blocks) {
        final box = block.boundingBox;
        minX = math.min(minX, box.left);
        minY = math.min(minY, box.top);
        maxX = math.max(maxX, box.right);
        maxY = math.max(maxY, box.bottom);
      }
      if (!minX.isFinite) return null;

      final padX = (maxX - minX) * 0.08 + decoded.width * 0.02;
      final padY = (maxY - minY) * 0.08 + decoded.height * 0.02;
      final left = (minX - padX).clamp(0, decoded.width - 1.0).toDouble();
      final top = (minY - padY).clamp(0, decoded.height - 1.0).toDouble();
      final right = (maxX + padX)
          .clamp(left + 8, decoded.width.toDouble())
          .toDouble();
      final bottom = (maxY + padY)
          .clamp(top + 8, decoded.height.toDouble())
          .toDouble();
      final width = right - left;
      final height = bottom - top;
      if (width < 40 || height < 40) return null;
      return Rect.fromLTWH(left, top, width, height);
    } catch (e) {
      debugPrint('Receipt bounds detect error: $e');
      return null;
    } finally {
      await recognizer.close();
    }
  }

  Future<File> _cropToReceiptCorners(File source) async {
    final bounds = await _detectReceiptBounds(source);
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return source;
    if (bounds == null) return source;

    final x = bounds.left.round().clamp(0, decoded.width - 1);
    final y = bounds.top.round().clamp(0, decoded.height - 1);
    var w = bounds.width.round();
    var h = bounds.height.round();
    if (x + w > decoded.width) w = decoded.width - x;
    if (y + h > decoded.height) h = decoded.height - y;
    if (w < 40 || h < 40) return source;

    final cropped = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
    return _writeTemp(
      Uint8List.fromList(img.encodeJpg(cropped, quality: 90)),
      ext: 'jpg',
    );
  }

  Future<void> _onCropped(CropResult result) async {
    if (result is CropFailure) {
      debugPrint('Crop failed: ${result.cause}');
      if (mounted) setState(() => _cropping = false);
      Utils.toastMessage(
        'Could not finish cropping. Adjust the box or use the full image.',
      );
      return;
    }
    if (result is! CropSuccess) {
      if (mounted) setState(() => _cropping = false);
      return;
    }
    final file = await _writeTemp(result.croppedImage, ext: 'png');
    await _runScan(file);
  }

  Future<void> _runScan(File file) async {
    if (!mounted) return;
    setState(() {
      _phase = _CropPhase.scanning;
      _scannedFile = file;
      _cropping = false;
    });
    _scanLine.repeat(reverse: true);

    try {
      final taxManager = context.read<TaxManagerViewModel>();
      final response = await taxManager.scanTaxManagerApi(file);
      if (!mounted) return;

      if (response == null || response['status'].toString() != '1') {
        _scanLine.stop();
        Utils.showErrorDialog(
          context: context,
          message:
              response?['success']?.toString() ??
              "This document doesn't appear to be a tax document. "
                  'Please upload a tax-related document or enter manually.',
        );
        setState(() => _phase = _CropPhase.crop);
        return;
      }

      final data =
          response['data'] is Map
              ? Map<String, dynamic>.from(response['data'] as Map)
              : null;
      final url = _extractRedactedUrl(
        Map<String, dynamic>.from(response),
        data,
      );
      final tempPath =
          response['redacted_temp_path']?.toString() ??
          data?['redacted_temp_path']?.toString();
      debugPrint('Scan redacted_url for preview: $url path=$tempPath');
      File? redacted;
      if (url != null || (tempPath != null && tempPath.isNotEmpty)) {
        redacted = await _downloadRedacted(url, tempPath: tempPath);
      }
      if (!mounted) return;
      _scanLine.stop();

      setState(() {
        _scanData = data;
        _redactedUrl = url;
        _redactedTempPath = tempPath;
        _redactedFile = redacted;
        _phase = _CropPhase.preview;
      });
    } catch (_) {
      if (!mounted) return;
      _scanLine.stop();
      Utils.showErrorDialog(
        context: context,
        message:
            'Unable to scan the document. Please try again or enter manually.',
      );
      setState(() => _phase = _CropPhase.crop);
    }
  }

  Future<void> _finish() async {
    if (_redactedFile == null &&
        (_redactedUrl != null || _redactedTempPath != null)) {
      _redactedFile = await _downloadRedacted(
        _redactedUrl,
        tempPath: _redactedTempPath,
      );
    }
    final resultFile =
        _redactedFile ?? _scannedFile ?? widget.imageFile;
    if (_scanData != null &&
        _redactedTempPath != null &&
        _redactedTempPath!.isNotEmpty) {
      _scanData!['redacted_temp_path'] = _redactedTempPath;
    }
    if (!mounted) return;
    Navigator.pop(
      context,
      CropScanResult(
        file: resultFile,
        fileName: widget.fileName,
        scanData: _scanData,
        redactedTempPath: _redactedTempPath,
      ),
    );
  }

  String? _extractRedactedUrl(
    Map<String, dynamic> response,
    Map<String, dynamic>? data,
  ) {
    final raw =
        response['redacted_url'] ??
        response['redactedUrl'] ??
        data?['redacted_url'] ??
        data?['redactedUrl'];
    return _normalizeRedactedUrl(raw?.toString());
  }

  String? _normalizeRedactedUrl(String? raw) {
    if (raw == null) return null;
    var url = raw.trim().replaceAll('"', '');
    if (url.isEmpty || url.toLowerCase() == 'null') return null;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    final base = AppUrl.baseUrl;
    final path = url.startsWith('/') ? url.substring(1) : url;
    if (path.startsWith('api/')) {
      return '$base$path';
    }
    return path.startsWith('storage/') ? '$base$path' : '${base}storage/$path';
  }

  List<String> _redactedUrlCandidates(String? url, String? tempPath) {
    final candidates = <String>[];
    void add(String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty || candidates.contains(trimmed)) return;
      candidates.add(trimmed);
    }

    add(url);
    if (url != null && url.startsWith('http://')) {
      add('https://${url.substring('http://'.length)}');
    }

    final path = (tempPath ?? '')
        .trim()
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll('\\', '/');
    final id = path.contains('/') ? path.split('/').last : path;
    final uuid = id.replaceAll(RegExp(r'\.png$', caseSensitive: false), '');
    if (uuid.isNotEmpty && (url == null || !url.contains(uuid))) {
      add('${AppUrl.baseUrl}api/redacted-preview/$uuid');
    }

    return candidates;
  }

  Future<File?> _downloadRedacted(String? url, {String? tempPath}) async {
    String? token;
    try {
      token = await NetworkApiService().getToken();
    } catch (_) {}

    final headerSets = <Map<String, String>>[
      {'Accept': 'image/png,image/jpeg,application/octet-stream,*/*'},
      {
        'Accept': 'image/png,image/jpeg,application/octet-stream,*/*',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    ];

    for (final candidate in _redactedUrlCandidates(url, tempPath)) {
      for (final headers in headerSets) {
        try {
          debugPrint('Downloading redacted image: $candidate');
          final response = await http
              .get(Uri.parse(candidate), headers: headers)
              .timeout(const Duration(seconds: 30));
          debugPrint(
            'Redacted download status=${response.statusCode} '
            'bytes=${response.bodyBytes.length} '
            'type=${response.headers['content-type']}',
          );
          final file = await _fileFromImageResponse(response);
          if (file != null) return file;
        } catch (e) {
          debugPrint('Redacted download failed for $candidate: $e');
        }
      }
    }
    return null;
  }

  Future<File?> _fileFromImageResponse(http.Response response) async {
    if (response.statusCode != 200 || response.bodyBytes.length < 64) {
      return null;
    }
    final bytes = response.bodyBytes;
    final isPng =
        bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isJpeg =
        bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
    final sniff = String.fromCharCodes(
      bytes.take(24).where((b) => b >= 32 && b < 127),
    ).toLowerCase();
    if (sniff.contains('<html') || sniff.contains('<!doctype')) {
      return null;
    }
    if (!isPng && !isJpeg) {
      final type = response.headers['content-type'] ?? '';
      if (!type.contains('image')) return null;
    }
    return _writeTemp(bytes, ext: isJpeg ? 'jpg' : 'png');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      backgroundColor: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: size.height * 0.88,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              _header(),
              Expanded(child: _stage()),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.crop_free_rounded,
              color: AppColors.goldenOrangeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('cropDocumentText', 'Crop document'),
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF12325A),
                  ),
                ),
                if (_phase == _CropPhase.crop)
                  Text(
                    _t(
                      'cropHintText',
                      'Drag the corners so only the tax document is inside the box.',
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      height: 1.3,
                      color: const Color(0xFF8A94A6),
                    ),
                  ),
                if (_phase == _CropPhase.preview)
                  Text(
                    'Review the redacted scan before continuing.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8A94A6),
                    ),
                  ),
              ],
            ),
          ),
          if (_phase != _CropPhase.scanning)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
            ),
        ],
      ),
    );
  }

  Widget _stage() {
    return ColoredBox(
      color: const Color(0xFF111827),
      child: switch (_phase) {
        _CropPhase.crop => _cropStage(),
        _CropPhase.scanning => _scanningStage(),
        _CropPhase.preview => _previewStage(),
      },
    );
  }

  Widget _cropStage() {
    if (_bytes == null) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: Color(0xFFF4A000),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Crop(
          image: _bytes!,
          controller: _cropController,
          onCropped: _onCropped,
          baseColor: const Color(0xFF111827),
          maskColor: const Color(0xCC000000),
          radius: 6,
          clipBehavior: Clip.hardEdge,
          interactive: false,
          willUpdateScale: (scale) => scale >= 1 && scale <= 6,
          filterQuality: FilterQuality.high,
          initialRectBuilder: InitialRectBuilder.withBuilder(
            (viewportRect, imageRect) {
              if (imageRect.width <= 8 || imageRect.height <= 8) {
                return viewportRect.deflate(20);
              }
              final inset = (imageRect.shortestSide * 0.045).clamp(6.0, 22.0);
              return imageRect.deflate(inset);
            },
          ),
          cornerDotBuilder: (size, _) => SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.goldenOrangeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          progressIndicator: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Color(0xFFF4A000),
            ),
          ),
        ),
        if (_cropping)
          ColoredBox(
            color: const Color(0x88000000),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Color(0xFFF4A000),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cropping...',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _scanningStage() {
    final file = _scannedFile ?? widget.imageFile;
    final navy = AppColors.midNightColor;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: Colors.white,
                    child: Image.file(file, fit: BoxFit.contain),
                  ),
                  AnimatedBuilder(
                    animation: _scanLine,
                    builder: (context, _) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final y =
                              8 +
                              _scanLine.value * (constraints.maxHeight - 16);
                          return IgnorePointer(
                            child: Stack(
                              children: [
                                Positioned(
                                  top: y - 28,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          navy.withValues(alpha: 0),
                                          navy.withValues(alpha: 0.08),
                                          navy.withValues(alpha: 0.18),
                                          navy.withValues(alpha: 0.08),
                                          navy.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: y - 1,
                                  left: 12,
                                  right: 12,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(99),
                                      gradient: LinearGradient(
                                        colors: [
                                          navy.withValues(alpha: 0),
                                          navy,
                                          AppColors.goldenOrangeColor
                                              .withValues(alpha: 0.85),
                                          navy,
                                          navy.withValues(alpha: 0),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: navy.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          spreadRadius: 0.4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            _t('scanningEllipsisText', 'Scanning...'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewStage() {
    final file = _redactedFile;
    if (file == null) {
      return const Center(
        child: Icon(Icons.broken_image_outlined, size: 40),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          file,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Widget _footer() {
    if (_phase == _CropPhase.scanning) {
      return const SizedBox(height: 12);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
      ),
      child: _phase == _CropPhase.preview
          ? SizedBox(
              width: double.infinity,
              child: _primaryButton(
                label: _t('doneText', 'Done'),
                onTap: _finish,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _primaryButton(
                  label: _t('cropAndScanText', 'Crop & Scan'),
                  onTap: (_bytes != null && !_cropping) ? _cropAndScan : null,
                ),
                const SizedBox(height: 8),
                _outlineButton(
                  label: _t(
                    'useFullImageScanText',
                    'Use full image & Scan',
                  ),
                  onTap: _cropping ? null : _useFullImage,
                ),
                TextButton(
                  onPressed:
                      _cropping ? null : () => Navigator.pop(context),
                  child: Text(
                    _t('cancelText', 'Cancel'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _primaryButton({required String label, VoidCallback? onTap}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldenOrangeColor,
          disabledBackgroundColor: const Color(0xFFF4A000).withValues(
            alpha: 0.45,
          ),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({required String label, VoidCallback? onTap}) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF12325A),
          side: const BorderSide(color: Color(0xFFD5DCE8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}
