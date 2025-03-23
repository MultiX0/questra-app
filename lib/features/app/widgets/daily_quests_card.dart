import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';

class DailyQuestsCard extends ConsumerWidget {
  const DailyQuestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return SystemCard(
      onTap: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        context.push(Routes.dailyQuestsPage);
      },
      child: Column(
        children: [
          Icon(LucideIcons.hexagon, size: 40),
          const SizedBox(height: 25),
          GlowText(
            text: AppLocalizations.of(context).daily_quest,
            glowColor: AppColors.primary,
            style: TextStyle(
              fontFamily: isArabic ? null : AppFonts.header,
              fontWeight: isArabic ? FontWeight.bold : null,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
