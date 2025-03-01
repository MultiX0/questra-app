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
                "Victory Achieved, Hero!",
                style: TextStyle(fontFamily: AppFonts.header, fontSize: 18),
              ),
              Icon(LucideIcons.trophy, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Your dedication and skills have led you to triumph. The realm celebrates your success great rewards await you!",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              color: AppColors.descriptionColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '- Your reward is: ${quest.xp_reward}XP, ${quest.coin_reward}\$ coins',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          if (!widget.isEvent) ...[
            if (quest.owned_title != null && quest.owned_title!.isNotEmpty) ...[
              Text(
                '- Earned title: ${quest.owned_title}',
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
