import 'package:flutter_svg/flutter_svg.dart';
import 'package:questra_app/imports.dart';

class DailyQuestsCard extends ConsumerWidget {
  const DailyQuestsCard({
    super.key,
    required this.title,
    required this.descirption,
    this.child,
    this.badgeBgPadding = 10,
    required this.icon,
    this.onTap,
    this.outerPadding = false,
  });

  final double badgeBgPadding;
  final bool outerPadding;
  final Widget? child;
  final String title;
  final String descirption;
  final dynamic icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // bool isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final duration = const Duration(milliseconds: 1800);

    return Padding(
      padding: outerPadding ? const EdgeInsets.symmetric(vertical: 8) : EdgeInsets.zero,
      child: SystemCard(
        duration: outerPadding ? const Duration(milliseconds: 800) : duration,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        onTap: () {
          ref.read(soundEffectsServiceProvider).playSystemButtonClick();
          if (onTap != null) {
            onTap!();
          }
        },
        child: Column(
          children: [
            Row(
              children: [
                buildBadge(),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                      // const SizedBox(height: 5),
                      Text(
                        descirption,
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 12,
                          color: AppColors.descriptionColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
            if (child != null) ...[child!],
          ],
        ),
      ),
    );
  }

  Container buildBadge() {
    return Container(
      padding: EdgeInsets.all(badgeBgPadding),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary.withValues(alpha: .65),
      ),
      child: Center(
        child: (icon is IconData) ? Icon(icon) : SvgPicture.network(icon, width: 30, height: 30),
      ),
    );
  }
}
