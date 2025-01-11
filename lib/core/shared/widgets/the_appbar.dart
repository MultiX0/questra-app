import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';

class TheAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TheAppBar({
    super.key,
    this.actions,
    // this.ref,
    required this.title,
  });

  // final WidgetRef? ref;
  final List<Widget>? actions;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GlowText(
        glowColor: HexColor('7AD5FF').withValues(alpha: 0.5),
        spreadRadius: 0.75,
        blurRadius: 30,
        text: title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: HexColor('7AD5FF'),
          fontFamily: AppFonts.header,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
