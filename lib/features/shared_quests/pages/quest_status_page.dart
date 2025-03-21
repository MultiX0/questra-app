import 'package:cached_network_image/cached_network_image.dart';
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/shared_quests/controller/shared_quests_controller.dart';
import 'package:questra_app/features/shared_quests/providers/shared_quests_provider.dart';
import 'package:questra_app/features/shared_quests/widgets/shared_quest_card.dart';
import 'package:questra_app/imports.dart';

class SharedQuestStatusPage extends ConsumerWidget {
  const SharedQuestStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> refresh(int questId) async {
      await Future.delayed(const Duration(milliseconds: 200), () async {
        await ref.read(sharedQuestsControllerProvider.notifier).getQuestByIdFromRepo(questId);
      });
    }

    final quest = ref.watch(selectedSharedQuestProvider)!;
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).shared_quest_status),
        body: AppRefreshIndicator(
          onRefresh: () => refresh(quest.quest!.id),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                buildStateCard(quest.quest!, ref, context),
                const SizedBox(height: 15),
                buildQuestDetailsCard(quest.quest!),
                const SizedBox(height: 15),
                buildPlayersCompletedCard(quest, isArabic, ref, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPlayersCompletedCard(
    SelectedSharedQuestSupport supportClass,
    bool isArabic,
    WidgetRef ref,
    BuildContext context,
  ) {
    // final quest = supportClass.quest;
    final completedPlayers = supportClass.completedPlayers;
    if (completedPlayers.isEmpty) return const SizedBox.shrink();
    return SystemCard(
      onTap: () {
        playSound(ref);
      },
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text("{ ${AppLocalizations.of(context).winners} }", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 15),

          ...completedPlayers.map((user) {
            return Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: .15),
                      backgroundImage: CachedNetworkImageProvider(user.avatar!),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.username),
                  ),
                ),
                const Spacer(),

                // TODO ADD VIEW QUEST SUBMISSION SYSTEM IN THE FUTURE
                // Icon(
                //   isArabic ? LucideIcons.chevron_left : LucideIcons.chevron_right,
                //   color: AppColors.whiteColor,
                // ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void playSound(WidgetRef ref) {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
  }

  Widget buildQuestDetailsCard(SharedQuestModel quest) {
    return SharedQuestCard(quest: quest, isStatus: true, isView: true);
  }

  Widget buildStateCard(SharedQuestModel quest, WidgetRef ref, BuildContext context) {
    return SystemCard(
      onTap: () {
        playSound(ref);
      },
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Text(AppLocalizations.of(context).shared_quest_status, style: TextStyle(fontSize: 18)),
          Text('∘✧─────────────✧∘'),
          const SizedBox(height: 5),
          questStatus(quest, ref, context),
        ],
      ),
    );
  }

  Text questStatus(SharedQuestModel quest, WidgetRef ref, BuildContext context) {
    final me = ref.read(authStateProvider)!;
    String _text = AppLocalizations.of(context).quest_status_expired;
    Color _color = Colors.red[400]!;

    if (quest.request!.firstCompleteWin && quest.playersCompleted.isNotEmpty) {
      _text = AppLocalizations.of(context).quest_status_completed;
      _color = AppColors.primary;
    }
    final otherUserId =
        quest.request!.senderId != me.id ? quest.request!.senderId : quest.request!.receiverId;
    if (quest.playersCompleted.contains(me.id) && quest.playersCompleted.contains(otherUserId)) {
      _text = AppLocalizations.of(context).quest_status_completed;
      _color = AppColors.primary;
    }

    if (!quest.request!.firstCompleteWin && quest.playersCompleted.length <= 1) {
      _text = AppLocalizations.of(context).quest_status_ongoing;
      _color = Colors.orange;
    }
    final now = DateTime.now().toUtc();
    if (quest.request!.deadLine.isBefore(now) && quest.playersCompleted.isNotEmpty) {
      _text = AppLocalizations.of(context).quest_status_completed;
      _color = AppColors.primary;
    }

    if (quest.request!.deadLine.isBefore(now) && quest.playersCompleted.isEmpty) {
      _text = AppLocalizations.of(context).quest_status_expired;
      _color = Colors.red[400]!;
    }
    return Text(_text, style: TextStyle(fontWeight: FontWeight.w600, color: _color, fontSize: 18));
  }
}
