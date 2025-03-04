import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/imports.dart';
import 'dart:ui' as ui;

class EventsQuestCard extends ConsumerWidget {
  const EventsQuestCard({super.key, this.onTap, required this.quest, this.isView = false});

  final Function()? onTap;
  final EventQuestModel quest;
  final bool isView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return SystemCard(
      duration: const Duration(milliseconds: 800),
      onTap: onTap,
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
                    glowColor: AppColors.whiteColor,
                    text: AppLocalizations.of(context).quest,
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
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowText(
                textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,

                glowColor: AppColors.whiteColor,
                text: "${AppLocalizations.of(context).quest_title}:",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
                spreadRadius: 0.5,
                blurRadius: 15,
              ),
              const SizedBox(height: 5),
              Text(
                // glowColor: AppColors.whiteColor,
                quest.title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontFamily: AppFonts.primary,
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
                glowColor: AppColors.whiteColor,
                text: "${AppLocalizations.of(context).description}:",

                textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
                spreadRadius: 0.5,
                blurRadius: 15,
              ),
              const SizedBox(height: 5),
              Text(
                quest.description,
                maxLines: isView ? null : 1,
                overflow: isView ? null : TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70, fontFamily: AppFonts.primary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlowText(
            glowColor: Colors.white54,
            textAlign: TextAlign.start,
            text: "Reward: +${quest.xp_reward} XP, +${quest.coin_reward} Coins",
            style: TextStyle(color: Colors.white54, fontFamily: AppFonts.primary, fontSize: 10),
            spreadRadius: 0.5,
            blurRadius: 15,
          ),
        ],
      ),
    );
  }
}
