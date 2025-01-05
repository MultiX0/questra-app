import 'package:questra_app/imports.dart';

class SystemCard extends StatelessWidget {
  const SystemCard({
    super.key,
    this.border,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius,
  });

  final Color? color;
  final Border? border;
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      constraints: BoxConstraints(
        minWidth: size.width,
      ),
      decoration: BoxDecoration(
        color: color ?? HexColor('7AD5FF').withValues(alpha: .05),
        border: border ??
            Border.all(
              color: HexColor('43A7D5'),
              width: 0.75,
            ),
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 40),
        child: child,
      ),
    );
  }
}
