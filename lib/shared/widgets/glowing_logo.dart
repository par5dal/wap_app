// lib/shared/widgets/glowing_logo.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class GlowingLogo extends StatefulWidget {
  final double size;
  final String logoAssetPath;

  const GlowingLogo({
    super.key,
    required this.size,
    required this.logoAssetPath,
  });

  @override
  State<GlowingLogo> createState() => _GlowingLogoState();
}

class _GlowingLogoState extends State<GlowingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color1 = theme.colorScheme.primary;
    final color2 = theme.colorScheme.secondary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: widget.size * 0.15,
              sigmaY: widget.size * 0.15,
            ),
            child: RotationTransition(
              turns: _controller,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color1, color2, color1.withAlpha(127)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          Image.asset(
            widget.logoAssetPath,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
