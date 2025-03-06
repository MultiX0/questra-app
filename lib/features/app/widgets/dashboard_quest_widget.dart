import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/app/widgets/none_active_quests_widget.dart';
import 'package:questra_app/imports.dart';

class DashboardQuestWidget extends ConsumerWidget {
  const DashboardQuestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final quests = ref.watch(currentOngointQuestsProvider);
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (quests == null || quests.isEmpty) {
      return NoneActiveQuestsWidget();
    }

    final firstQuest = quests.first;
    final duration = const Duration(milliseconds: 1800);

    return SystemCard(
      duration: duration,
      onTap: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        Navs(context, ref).viewQuest(firstQuest, false);
      },
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: size.width * .15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: HexColor('43A7D5'), width: 0.75),
                ),
                child: Center(
                  child: GlowText(
                    blurRadius: 10,
                    spreadRadius: 0.2,
                    glowColor: AppColors.whiteColor,
                    text: AppLocalizations.of(context).quest,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w200,
                      // fontFamily: AppFonts.primary,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowText(
                blurRadius: 10,
                spreadRadius: 0.2,
                glowColor: AppColors.whiteColor,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,

                text: "${AppLocalizations.of(context).quest_title}:",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  // fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                // glowColor: AppColors.whiteColor,
                isArabic ? firstQuest.ar_title ?? firstQuest.title : firstQuest.title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.whiteColor,
                  // fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowText(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                blurRadius: 10,
                spreadRadius: 0.2,
                textAlign: TextAlign.start,
                glowColor: AppColors.whiteColor,
                text: "${AppLocalizations.of(context).description}:",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  // fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isArabic
                    ? firstQuest.ar_description ?? firstQuest.description
                    : firstQuest.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlowText(
            glowColor: Colors.white54,
            textAlign: TextAlign.start,
            text:
                "${AppLocalizations.of(context).quest_completetion_card_reward(firstQuest.coin_reward, firstQuest.xp_reward)}${firstQuest.owned_title != null ? ", \n${AppLocalizations.of(context).quest_completetion_card_title_earned(firstQuest.owned_title!)}" : ''}",
            style: TextStyle(color: Colors.white54, fontSize: 12),
            spreadRadius: 0.5,
            blurRadius: 15,
          ),
        ],
      ),
    );
  }
}
