import 'package:questra_app/features/quests/widgets/quest_completion_widget.dart';
import 'package:questra_app/features/shared_quests/providers/shared_quests_provider.dart';
import 'package:questra_app/features/shared_quests/repository/shared_quests_repository.dart';
import 'package:questra_app/features/shared_quests/widgets/shared_quest_card.dart';
import 'package:questra_app/imports.dart';

class SharedQuestViewPage extends ConsumerStatefulWidget {
  const SharedQuestViewPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewQuestPageState();
}

class _ViewQuestPageState extends ConsumerState<SharedQuestViewPage> {
  bool _finish = false;
  bool isLoading = false;

  void play() {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
  }

  void cancel() {
    setState(() {
      _finish = false;
    });
  }

  void finish(SharedQuestModel quest) {
    final me = ref.read(authStateProvider)!;
    bool isArabic = ref.read(localeProvider).languageCode == 'ar';

    if (quest.playersCompleted.contains(me.id)) {
      final message =
          isArabic
              ? "لقد أكملت هذه المهمة مرة بالفعل"
              : "I have already completed this quest once.";
      CustomToast.systemToast(message);
      context.pop();
    }
    play();

    finishSheet(me.id, quest);
  }

  @override
  Widget build(BuildContext context) {
    final quest = ref.watch(selectedSharedQuestProvider)!;
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).view_quest),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: (_finish) ? buildFinish() : buildBody(quest.quest!),
        ),
      ),
    );
  }

  Widget buildFinish() {
    return Center(child: QuestCompletionWidget(isShared: true));
  }

  void handleFinish() {
    setState(() {
      _finish = true;
    });
  }

  void handleLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  void finishSheet(String userId, SharedQuestModel quest) {
    // ref.read(soundEffectsServiceProvider).playSystemButtonClick();

    openSheet(
      context: context,
      body: StatefulBuilder(
        builder: (context, setState) {
          return isLoading
              ? BeatLoader()
              : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        shrinkWrap: true,
                        children: [
                          Icon(LucideIcons.hexagon, color: AppColors.primary, size: 40),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context).quest_complete_confirmation,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.whiteColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SystemCardButton(
                          onTap: () async {
                            handleLoading(true);
                            await ref
                                .read(sharedQuestsProvider)
                                .completeQuest(userId: userId, quest: quest);
                            handleLoading(false);
                            handleFinish();
                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            context.pop();
                          },
                          text: AppLocalizations.of(context).yes,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: SystemCardButton(
                          onTap: () => context.pop(),
                          text: AppLocalizations.of(context).cancel.toLowerCase(),
                          doneButton: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              );
        },
      ),
    );
  }

  Widget buildBody(SharedQuestModel quest) {
    // final isLoading = ref.watch(questsControllerProvider);
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SharedQuestCard(quest: quest, isView: true),
        const SizedBox(height: 30),
        SystemCard(
          onTap: () => finish(quest),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: kToolbarHeight - 5),
          // isButton:
          // true,
          child: Center(
            child: Text(
              AppLocalizations.of(context).finish,
              style: TextStyle(fontFamily: isArabic ? null : AppFonts.header),
            ),
          ),
        ),
      ],
    );
  }
}
