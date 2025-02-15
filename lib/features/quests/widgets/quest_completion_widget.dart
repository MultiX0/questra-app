import 'package:questra_app/imports.dart';

class QuestCompletionWidget extends ConsumerWidget {
  const QuestCompletionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quest = ref.read(viewQuestProvider)!;
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
                style: TextStyle(
                  fontFamily: AppFonts.header,
                  fontSize: 18,
                ),
              ),
              Icon(
                LucideIcons.trophy,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "Your dedication and skills have led you to triumph. The realm celebrates your success great rewards await you!",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              color: AppColors.descriptionColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            '- Your reward is: ${quest.xp_reward}XP, ${quest.coin_reward}\$ coins',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (quest.owned_title != null && quest.owned_title!.isNotEmpty) ...[
            Text(
              '- Earned title: ${quest.owned_title}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
          const SizedBox(
            height: 20,
          ),
          SystemCardButton(
            onTap: () {
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
