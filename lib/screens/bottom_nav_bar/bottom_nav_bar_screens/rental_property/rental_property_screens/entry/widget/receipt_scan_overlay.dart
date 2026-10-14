import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class ReceiptScanOverlay extends StatefulWidget {
  const ReceiptScanOverlay({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final File image;
  final String title;
  final String subtitle;

  @override
  State<ReceiptScanOverlay> createState() => _ReceiptScanOverlayState();
}

class _ReceiptScanOverlayState extends State<ReceiptScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxCardWidth = (media.size.width - 32).clamp(0.0, 420.0);
    final maxCardHeight = media.size.height - media.padding.vertical - 32;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withValues(alpha: 0.62),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxCardWidth,
                    maxHeight: maxCardHeight,
                  ),
                  child: Container(
                    width: maxCardWidth,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.goldenOrangeColor.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldenOrangeColor.withValues(
                            alpha: 0.18,
                          ),
                          blurRadius: 28,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: ColoredBox(
                              color: const Color(0xFF0C0C0C),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.contain,
                                    child:
                                        widget.image.path
                                                .toLowerCase()
                                                .endsWith('.pdf')
                                            ? _PdfScanPreview(
                                              fileName:
                                                  widget.image.path
                                                      .split(Platform.pathSeparator)
                                                      .last,
                                            )
                                            : Image.file(
                                              widget.image,
                                              filterQuality:
                                                  FilterQuality.medium,
                                            ),
                                  ),
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: AnimatedBuilder(
                                        animation: _controller,
                                        builder: (context, _) {
                                          return CustomPaint(
                                            painter: _ScanBeamPainter(
                                              progress: _controller.value,
                                              color:
                                                  AppColors.goldenOrangeColor,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 148,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              minHeight: 3,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.12,
                              ),
                              color: AppColors.goldenOrangeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PdfScanPreview extends StatelessWidget {
  const _PdfScanPreview({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_rounded,
            size: 88,
            color: AppColors.goldenOrangeColor,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanBeamPainter extends CustomPainter {
  _ScanBeamPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final beam =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: 0.55),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, y - 18, size.width, 36));

    canvas.drawRect(Rect.fromLTWH(0, y - 18, size.width, 36), beam);

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(covariant _ScanBeamPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
