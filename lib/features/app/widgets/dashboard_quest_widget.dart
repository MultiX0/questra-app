import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/app/widgets/none_active_quests_widget.dart';
import 'package:questra_app/imports.dart';

class DashboardQuestWidget extends ConsumerWidget {
  const DashboardQuestWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final quests = ref.watch(currentOngointQuestsProvider);

    if (quests == null || quests.isEmpty) {
      return NoneActiveQuestsWidget();
    }

    final firstQuest = quests.first;
    final duration = const Duration(seconds: 2);

    return SystemCard(
      duration: duration,
      onTap: () => Navs(context, ref).viewQuest(firstQuest),
      padding: EdgeInsets.all(
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: size.width * .15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: HexColor('43A7D5'),
                    width: 0.75,
                  ),
                ),
                child: Center(
                  child: GlowText(
                    glowColor: AppColors.whiteColor,
                    text: "Quest",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w200,
                      fontFamily: AppFonts.primary,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowText(
                glowColor: AppColors.whiteColor,
                text: "Quest Title:",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                // glowColor: AppColors.whiteColor,
                firstQuest.title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowText(
                glowColor: AppColors.whiteColor,
                text: "Description:",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                firstQuest.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: AppFonts.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          GlowText(
            glowColor: Colors.white54,
            text:
                "Reward: +${firstQuest.xp_reward} XP, +${firstQuest.coin_reward} Coins${firstQuest.owned_title != null ? ", “${firstQuest.owned_title}” Title" : ''}",
            style: TextStyle(
              color: Colors.white54,
              fontFamily: AppFonts.primary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
