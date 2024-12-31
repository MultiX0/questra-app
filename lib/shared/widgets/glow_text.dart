import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/constants/app_fonts.dart';

class GlowText extends StatelessWidget {
  const GlowText({
    super.key,
    this.blurRadius,
    required this.glowColor,
    this.spreadRadius,
    required this.text,
    this.style,
    this.textAlign,
  });

  final Color glowColor;
  final TextStyle? style;
  final String text;
  final double? blurRadius;
  final double? spreadRadius;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: blurRadius ?? 8,
            color: glowColor,
            spreadRadius: spreadRadius ?? 2,
          )
        ],
      ),
      child: Text(
        text,
        textAlign: textAlign ?? TextAlign.center,
        style: style ??
            TextStyle(
              fontSize: 28,
              fontFamily: AppFonts.header,
              fontWeight: FontWeight.bold,
              color: HexColor('7AD5FF'),
            ),
      ),
    );
  }
}
