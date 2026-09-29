import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/sensitive_data_detector.dart';

class SensitiveDataReviewDialog extends StatefulWidget {
  const SensitiveDataReviewDialog({
    super.key,
    required this.imageFile,
    required this.autoDetect,
    this.initialBoxes = const [],
    this.fileLabel,
    this.fileIndex = 1,
    this.fileCount = 1,
  });

  final File imageFile;
  final bool autoDetect;
  final List<SensitiveBox> initialBoxes;
  final String? fileLabel;
  final int fileIndex;
  final int fileCount;

  static Future<List<SensitiveBox>?> open(
    BuildContext context, {
    required File imageFile,
    required bool autoDetect,
    List<SensitiveBox> initialBoxes = const [],
    String? fileLabel,
    int fileIndex = 1,
    int fileCount = 1,
  }) {
    return showDialog<List<SensitiveBox>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SensitiveDataReviewDialog(
        imageFile: imageFile,
        autoDetect: autoDetect,
        initialBoxes: initialBoxes.map((e) => e.copy()).toList(),
        fileLabel: fileLabel,
        fileIndex: fileIndex,
        fileCount: fileCount,
      ),
    );
  }

  @override
  State<SensitiveDataReviewDialog> createState() =>
      _SensitiveDataReviewDialogState();
}

class _SensitiveDataReviewDialogState extends State<SensitiveDataReviewDialog>
    with SingleTickerProviderStateMixin {
  final List<SensitiveBox> _boxes = [];
  bool _detecting = false;
  Size? _imageSize;

  late AnimationController _scanController;
  Offset? _dragStart;
  Offset? _dragCurrent;

  @override
  void initState() {
    super.initState();
    _boxes.addAll(widget.initialBoxes.map((e) => e.copy()));
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    try {
      final size = await SensitiveDataDetector.imageSize(widget.imageFile);
      if (!mounted) return;
      setState(() {
        _imageSize = Size(size.width, size.height);
      });
    } catch (_) {}

    if (!widget.autoDetect) return;

    setState(() => _detecting = true);
    _scanController.repeat();

    final started = DateTime.now();
    final detected = await SensitiveDataDetector.detect(widget.imageFile);
    final elapsed = DateTime.now().difference(started);
    if (elapsed < const Duration(milliseconds: 900)) {
      await Future.delayed(const Duration(milliseconds: 900) - elapsed);
    }

    if (!mounted) return;
    _scanController.stop();
    setState(() {
      _boxes
        ..clear()
        ..addAll(detected);
      _detecting = false;
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  String _t(String key, String fallback) =>
      AppLocalizations.of(context)?.translate(key) ?? fallback;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 720;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 980,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          children: [
            _header(),
            const Divider(height: 1),
            Expanded(
              child: wide
                  ? Row(
                      children: [
                        Expanded(flex: 3, child: _imageStage()),
                        SizedBox(width: 220, child: _sidePanel()),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(child: _imageStage()),
                        _sidePanel(),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _reviewActionButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const LinearGradient _brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFC44D),
      Color(0xFFF4A000),
      Color(0xFFE07800),
    ],
  );

  Widget _reviewActionButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _detecting ? null : () => Navigator.pop(context, _boxes),
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _brandGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40F4A000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            child: _detecting
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _t('detectingText', 'Detecting'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _t('doneText', 'Done'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Text(
            _t('reviewText', 'Review'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _sidePanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_t('reviewFileOfText', 'Review file')} ${widget.fileIndex} ${_t('ofText', 'of')} ${widget.fileCount}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.fileLabel ?? widget.imageFile.path.split(RegExp(r'[\\/]')).last,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Text(
            _t(
              'reviewHintText',
              'Click a box to hide it. Drag to cover anything the scan missed.',
            ),
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _imageStage() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imgSize = _imageSize ?? const Size(1, 1);
          final fitted = applyBoxFit(
            BoxFit.contain,
            imgSize,
            Size(constraints.maxWidth, constraints.maxHeight),
          );
          final dest = fitted.destination;
          final dx = (constraints.maxWidth - dest.width) / 2;
          final dy = (constraints.maxHeight - dest.height) / 2;

          Offset toLocalNorm(Offset p) {
            final x = ((p.dx - dx) / dest.width).clamp(0.0, 1.0);
            final y = ((p.dy - dy) / dest.height).clamp(0.0, 1.0);
            return Offset(x, y);
          }

          return GestureDetector(
            onPanStart: _detecting
                ? null
                : (d) {
                    _dragStart = toLocalNorm(d.localPosition);
                    _dragCurrent = _dragStart;
                    setState(() {});
                  },
            onPanUpdate: _detecting
                ? null
                : (d) {
                    _dragCurrent = toLocalNorm(d.localPosition);
                    setState(() {});
                  },
            onPanEnd: _detecting
                ? null
                : (_) {
                    final a = _dragStart;
                    final b = _dragCurrent;
                    _dragStart = null;
                    _dragCurrent = null;
                    if (a == null || b == null) return;
                    final left = a.dx < b.dx ? a.dx : b.dx;
                    final top = a.dy < b.dy ? a.dy : b.dy;
                    final w = (a.dx - b.dx).abs();
                    final h = (a.dy - b.dy).abs();
                    if (w < 0.012 || h < 0.012) {
                      _toggleBoxAt(a);
                      return;
                    }
                    setState(() {
                      _boxes.add(
                        SensitiveBox(
                          id: 'u${DateTime.now().microsecondsSinceEpoch}',
                          left: left,
                          top: top,
                          width: w,
                          height: h,
                          userDrawn: true,
                        ),
                      );
                    });
                  },
            child: Stack(
              children: [
                Positioned(
                  left: dx,
                  top: dy,
                  width: dest.width,
                  height: dest.height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                for (final box in _boxes.where((e) => e.visible))
                  Positioned(
                    left: dx + box.left * dest.width,
                    top: dy + box.top * dest.height,
                    width: box.width * dest.width,
                    height: box.height * dest.height,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0x73D4B44A),
                          border: Border.all(
                            color: const Color(0xFF8B6B1F),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_dragStart != null && _dragCurrent != null)
                  Positioned(
                    left: dx +
                        (_dragStart!.dx < _dragCurrent!.dx
                                ? _dragStart!.dx
                                : _dragCurrent!.dx) *
                            dest.width,
                    top: dy +
                        (_dragStart!.dy < _dragCurrent!.dy
                                ? _dragStart!.dy
                                : _dragCurrent!.dy) *
                            dest.height,
                    width: (_dragStart!.dx - _dragCurrent!.dx).abs() *
                        dest.width,
                    height: (_dragStart!.dy - _dragCurrent!.dy).abs() *
                        dest.height,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x73D4B44A),
                        border: Border.all(
                          color: AppColors.goldenOrangeColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                if (_detecting)
                  Positioned(
                    left: dx,
                    top: dy,
                    width: dest.width,
                    height: dest.height,
                    child: AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, _) {
                        return Stack(
                          children: [
                            Container(color: Colors.black.withValues(alpha: 0.08)),
                            Positioned(
                              top: _scanController.value * (dest.height - 4),
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 4,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFFFFC44D),
                                      Color(0xFFF4A000),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleBoxAt(Offset norm) {
    for (var i = _boxes.length - 1; i >= 0; i--) {
      final b = _boxes[i];
      if (!b.visible) continue;
      if (norm.dx >= b.left &&
          norm.dx <= b.left + b.width &&
          norm.dy >= b.top &&
          norm.dy <= b.top + b.height) {
        setState(() => b.visible = false);
        return;
      }
    }
  }
}
