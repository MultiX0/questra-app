import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';
import 'dart:ui' as ui;

class QuestCard extends ConsumerWidget {
  const QuestCard({
    super.key,
    required this.questModel,
    this.viewPage,
    this.special = false,
    this.onTap,
  });

  final QuestModel questModel;
  final bool? viewPage;
  final bool special;
  final Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isView = viewPage != null && viewPage == true;
    final size = MediaQuery.sizeOf(context);
    final now = DateTime.now();
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    // log('is arabic lang: $isArabic');
    // log("arabic title ${questModel.ar_title}");

    return Stack(
      children: [
        SystemCard(
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
                        text:
                            special
                                ? AppLocalizations.of(context).custom_quest
                                : AppLocalizations.of(context).quest,
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
                    glowColor: AppColors.whiteColor,
                    text: "${AppLocalizations.of(context).quest_title}:",
                    textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,

                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      // fontFamily: AppFonts.primary,
                      fontSize: 14,
                    ),
                    spreadRadius: 0.5,
                    blurRadius: 15,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    // glowColor: AppColors.whiteColor,
                    isArabic ? questModel.ar_title ?? questModel.title : questModel.title,
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
                    textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,

                    glowColor: AppColors.whiteColor,
                    text: "${AppLocalizations.of(context).description}:",

                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      // fontFamily: AppFonts.primary,
                      fontSize: 14,
                    ),
                    spreadRadius: 0.5,
                    blurRadius: 15,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isArabic
                        ? questModel.ar_description ?? questModel.description
                        : questModel.description,
                    maxLines: isView ? null : 1,
                    overflow: isView ? null : TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      // fontFamily: AppFonts.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GlowText(
                glowColor: Colors.white54,
                textAlign: TextAlign.start,
                text:
                    "${AppLocalizations.of(context).quest_completetion_card_reward(questModel.coin_reward, questModel.xp_reward)}${questModel.owned_title != null ? ", \n${AppLocalizations.of(context).quest_completetion_card_title_earned(questModel.owned_title!)}" : ''}",
                style: TextStyle(color: Colors.white54, fontSize: 12),
                spreadRadius: 0.5,
                blurRadius: 15,
              ),
              if (isView) ...[
                const SizedBox(height: 14),
                if (questModel.expected_completion_time_date != null)
                  Text(
                    AppLocalizations.of(
                      context,
                    ).last_submit_time_quest(questModel.expected_completion_time_date!),
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 11),
                  ),
              ],
            ],
          ),
        ),
        if (questModel.completed_at != null) ...[
          if (now.isBefore(questModel.completed_at!.add(const Duration(hours: 24)))) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  CustomToast.systemToast(
                    "${isArabic ? "تحتاج الى الانتظار حتى" : "you need to wait until"} ${appDateFormat(questModel.completed_at!.add(const Duration(hours: 24)))}",
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).marketplace_item_locked,
                      style: TextStyle(fontFamily: AppFonts.header, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
