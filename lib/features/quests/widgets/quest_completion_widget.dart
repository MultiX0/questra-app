import 'package:questra_app/core/providers/leveling_providers.dart';
import 'package:questra_app/imports.dart';

class QuestCompletionWidget extends ConsumerStatefulWidget {
  const QuestCompletionWidget({super.key, this.isEvent = false});

  final bool isEvent;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuestCompletionWidgetState();
}

class _QuestCompletionWidgetState extends ConsumerState<QuestCompletionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(soundEffectsServiceProvider).playCongrats();
    });
  }

  bool get isArabic => ref.watch(localeProvider).languageCode == 'ar';

  void finish() {
    final cachedLevel = ref.read(cachedUserLevelProvider);
    dynamic quest;
    if (widget.isEvent) {
      quest = ref.read(viewEventQuestProvider)!;
    } else {
      quest = ref.read(viewQuestProvider)!;
    }

    if (cachedLevel == null) {
      context.pop();
      return;
    }

    final result = addXp(quest.xp_reward, {'xp': cachedLevel.xp, 'level': cachedLevel.level});
    if ((result['level'] ?? 1) > cachedLevel.level) {
      context.pushReplacement(Routes.leveledUpPage);
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    dynamic quest;
    if (widget.isEvent) {
      quest = ref.read(viewEventQuestProvider)!;
    } else {
      quest = ref.read(viewQuestProvider)!;
    }

    return SystemCard(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).quest_completetion_card_title,
                style: TextStyle(
                  fontFamily: isArabic ? null : AppFonts.header,
                  fontSize: 18,
                  fontWeight: isArabic ? FontWeight.bold : null,
                ),
              ),
              Icon(LucideIcons.trophy, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            AppLocalizations.of(context).quest_completetion_card_description,
            style: TextStyle(
              fontWeight: FontWeight.w200,
              color: AppColors.descriptionColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            // '- Your reward is: ${quest.xp_reward}XP, ${quest.coin_reward}\$ coins',
            AppLocalizations.of(
              context,
            ).quest_completetion_card_reward(quest.xp_reward, quest.coin_reward),
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          if (!widget.isEvent) ...[
            if (quest.owned_title != null && quest.owned_title!.isNotEmpty) ...[
              Text(
                AppLocalizations.of(
                  context,
                ).quest_completetion_card_title_earned(quest.owned_title),
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ],
          const SizedBox(height: 20),
          SystemCardButton(onTap: finish),
        ],
      ),
    );
  }
}
