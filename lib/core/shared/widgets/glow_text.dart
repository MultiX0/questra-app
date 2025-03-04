import 'package:flutter/material.dart';
import 'package:questra_app/core/shared/constants/app_fonts.dart';

class GlowText extends StatelessWidget {
  const GlowText({
    super.key,
    required this.glowColor,
    required this.text,
    this.style,
    this.textAlign,
    this.blurRadius = 15.0,
    this.spreadRadius = 0.5,
    this.textDirection = TextDirection.ltr,
  });

  final Color glowColor;
  final TextStyle? style;
  final String text;
  final double blurRadius;
  final double spreadRadius;
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          textDirection: textDirection,

          text,
          style: TextStyle(
            fontSize: style?.fontSize ?? 14,
            fontWeight: style?.fontWeight,
            fontFamily: style?.fontFamily,
            foreground:
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = spreadRadius
                  ..color = glowColor.withValues(alpha: .5),
          ),
          textAlign: textAlign ?? TextAlign.center,
        ),
        // Main Text Layer
        Text(
          text,
          textDirection: textDirection,
          style:
              style?.copyWith(
                shadows: [
                  BoxShadow(color: glowColor, blurRadius: blurRadius, spreadRadius: spreadRadius),
                ],
              ) ??
              TextStyle(
                fontSize: 28,
                fontFamily: AppFonts.header,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  BoxShadow(color: glowColor, blurRadius: blurRadius, spreadRadius: spreadRadius),
                ],
              ),
          textAlign: textAlign ?? TextAlign.center,
        ),
      ],
    );
  }
}
