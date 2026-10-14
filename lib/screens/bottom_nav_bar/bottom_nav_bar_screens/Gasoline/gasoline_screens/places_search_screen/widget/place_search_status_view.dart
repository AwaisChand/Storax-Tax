import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class PlaceSearchStatusView extends StatefulWidget {
  const PlaceSearchStatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.pulse = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool pulse;

  @override
  State<PlaceSearchStatusView> createState() => _PlaceSearchStatusViewState();
}

class _PlaceSearchStatusViewState extends State<PlaceSearchStatusView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _glow = Tween<double>(begin: 0.12, end: 0.32).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    if (widget.pulse) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant PlaceSearchStatusView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && oldWidget.pulse) {
      _controller
        ..stop()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.pulse ? _scale.value : 1,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldenOrangeColor.withValues(
                          alpha: widget.pulse ? _glow.value : 0.18,
                        ),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: Icon(
              widget.icon,
              size: 40,
              color: AppColors.goldenOrangeColor,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGrayColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
