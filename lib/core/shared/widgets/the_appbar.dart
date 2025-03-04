import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';

class TheAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const TheAppBar({
    super.key,
    this.actions,
    // this.ref,
    this.title,
  });

  // final WidgetRef? ref;
  final List<Widget>? actions;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';
    return AppBar(
      title: GlowText(
        glowColor: HexColor('7AD5FF').withValues(alpha: isArabic ? 0.2 : 0.5),
        spreadRadius: 0.5,
        blurRadius: 30,
        text: title ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isArabic ? 35 : 24,
          color: HexColor('7AD5FF').withValues(alpha: isArabic ? 0.9 : 0),
          fontFamily: isArabic ? "HSN" : AppFonts.header,
          // fontFamily: "HSN",
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
