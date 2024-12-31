import 'package:questra_app/imports.dart';
import 'package:questra_app/theme/app_theme.dart';

class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.child,
    required this.color,
    required this.glowColor,
    this.blurRadius,
    this.spreadRadius,
    required this.onPressed,
    this.border,
  });

  final Widget child;
  final Color color;
  final Color glowColor;
  final double? blurRadius;
  final double? spreadRadius;
  final Function() onPressed;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: border ??
            Border.all(
              width: 1,
              color: HexColor('002333').withValues(alpha: 0.15),
            ),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: blurRadius ?? 20,
            spreadRadius: spreadRadius ?? 2,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: size.width * .35,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: AppColors.whiteColor,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
