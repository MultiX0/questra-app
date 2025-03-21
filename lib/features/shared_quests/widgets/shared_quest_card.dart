// import 'dart:developer';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/imports.dart';
import 'dart:ui' as ui;

class SharedQuestCard extends ConsumerWidget {
  const SharedQuestCard({
    super.key,
    this.onTap,
    required this.quest,
    this.isView = false,
    this.isStatus = false,
  });

  final Function()? onTap;
  final SharedQuestModel quest;
  final bool isView;
  final bool isStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final me = ref.watch(authStateProvider)!;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final coinsRewarded = calculateQuestCoins(me.level?.level ?? 1, quest.difficulty);
    final xpRewarded = questXp(me.level?.level ?? 1, quest.difficulty);

    return SystemCard(
      duration: const Duration(milliseconds: 800),
      onTap: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        if (onTap != null) {
          onTap!();
        }
      },
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
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
                      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,

                      glowColor: AppColors.whiteColor,
                      text: "${AppLocalizations.of(context).quest_title}:",
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
                      isArabic ? quest.arTitle : quest.title,
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
                      glowColor: AppColors.whiteColor,
                      text: "${AppLocalizations.of(context).description}:",

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
                      isArabic ? quest.arDescription : quest.description,
                      maxLines: isView ? null : 1,
                      overflow: isView ? null : TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GlowText(
                  glowColor: Colors.white54,
                  textAlign: TextAlign.start,
                  text: AppLocalizations.of(
                    context,
                  ).quest_completetion_card_reward(coinsRewarded, xpRewarded),
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                  spreadRadius: 0.5,
                  blurRadius: 15,
                ),
              ],
            ),
          ),
          if (!isView && !isStatus) buildTopLayer(ref: ref, me: me, context: context),
        ],
      ),
    );
  }

  Widget buildTopLayer({
    required WidgetRef ref,
    required UserModel me,
    required BuildContext context,
  }) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.black.withValues(alpha: .8),
    );

    final padding = EdgeInsets.all(16);
    final style = TextStyle(fontWeight: FontWeight.bold, fontSize: 24);

    if (quest.request!.firstCompleteWin && quest.playersCompleted.contains(me.id)) {
      return buildTopCard(
        padding: padding,
        decoration: decoration,
        context: context,
        style: style.copyWith(fontSize: 18, color: AppColors.primary),
        text: AppLocalizations.of(context).you_won,
      );
    }

    final now = DateTime.now();
    if (quest.request != null && quest.request!.deadLine.isBefore(now)) {
      return buildTopCard(
        padding: padding,
        decoration: decoration,
        context: context,
        style: style.copyWith(fontSize: 18, color: Colors.red[300]!),
        text: AppLocalizations.of(context).expired_quest,
      );
    }

    final otherUser = ref.watch(selectedFriendProvider)!;
    if (quest.playersCompleted.isEmpty) {
      return const SizedBox.shrink();
    }

    if (quest.playersCompleted.contains(otherUser.id) && quest.playersCompleted.contains(me.id)) {
      return buildTopCard(
        padding: padding,
        decoration: decoration,
        context: context,
        style: style.copyWith(fontSize: 18),
        text: AppLocalizations.of(context).shared_quests_both_win,
      );
    }

    bool isTheWinnerMe = (quest.playersCompleted[0] as String).trim() == me.id;
    String text =
        isTheWinnerMe
            ? AppLocalizations.of(context).you_won
            : AppLocalizations.of(context).you_lost;
    Color textColor = isTheWinnerMe ? AppColors.primary : Colors.red[300]!;

    return buildTopCard(
      padding: padding,
      decoration: decoration,
      context: context,
      style: style.copyWith(color: textColor),
      text: text,
    );
  }

  Positioned buildTopCard({
    required EdgeInsets padding,
    required BoxDecoration decoration,
    required BuildContext context,
    required TextStyle style,
    required String text,
  }) {
    return Positioned.fill(
      child: Container(
        padding: padding,
        decoration: decoration,
        child: Center(
          child: GlowText(text: text, glowColor: style.color ?? AppColors.whiteColor, style: style),
        ),
      ),
    );
  }
}
