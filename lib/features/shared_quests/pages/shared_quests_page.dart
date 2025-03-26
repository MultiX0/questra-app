import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/shared_quests/models/shared_quest_model.dart';
import 'package:questra_app/features/shared_quests/providers/shared_quests_provider.dart';
import 'package:questra_app/features/shared_quests/widgets/shared_quest_card.dart';
import 'package:questra_app/imports.dart';

class SharedQuestsPage extends ConsumerStatefulWidget {
  const SharedQuestsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SharedQuestsPageState();
}

class _SharedQuestsPageState extends ConsumerState<SharedQuestsPage> {
  Future<void> refresh() async {
    final sharedQuestsRef = sharedQuestsStateProvider;
    await Future.delayed(const Duration(milliseconds: 800), () {
      ref.read(sharedQuestsRef.notifier).getQuests();
    });
    setState(() {
      btnLoading = false;
    });
  }

  bool btnLoading = false;

  @override
  Widget build(BuildContext context) {
    // final visitedUser = ref.watch(selectedFriendProvider)!;
    final middleware = ref.watch(sharedQuestsStateProvider);

    return BackgroundWidget(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(Routes.addSharedQuestPage),
          backgroundColor: AppColors.primary.withValues(alpha: .5),
          elevation: 3,

          child: Icon(LucideIcons.plus, color: AppColors.whiteColor),
        ),
        appBar: TheAppBar(title: AppLocalizations.of(context).shared_quests),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child:
              middleware.isLoading
                  ? BeatLoader()
                  : (middleware.quests.isEmpty)
                  ? buildEmptyState()
                  : AppRefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      itemCount: middleware.quests.length + 1,
                      itemBuilder: (context, i) {
                        final quests = middleware.quests.toList();
                        if (i == 0) {
                          return buildRequestsCard();
                        }
                        quests.sort(
                          (a, b) => a.playersCompleted.length.compareTo(b.playersCompleted.length),
                        );
                        final quest = quests.elementAt(i - 1);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SharedQuestCard(quest: quest, onTap: () => onQuestTapped(quest)),
                        );
                      },
                    ),
                  ),
        ),
      ),
    );
  }

  void onQuestTapped(SharedQuestModel quest) {
    context.push('${Routes.sharedQuestsMiddleWare}/${quest.id}');
  }

  Widget buildRequestsCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SystemCard(
        onTap: () {
          ref.read(soundEffectsServiceProvider).playSystemButtonClick();
          context.push(Routes.questRequestsPage);
        },
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        isButton: true,
        child: Row(
          children: [
            Icon(LucideIcons.hexagon),
            const SizedBox(width: 15),
            Text(
              AppLocalizations.of(context).quest_requests,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return AppRefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: buildRequestsCard()),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: SizedBox(
                child: SystemCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shield_alert, color: AppColors.primary, size: 45),
                      const SizedBox(height: 15),
                      Text(
                        AppLocalizations.of(context).shared_quests_empty_state,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 15),
                      if (btnLoading)
                        BeatLoader()
                      else
                        MainAppButton(
                          onTap: () {
                            setState(() {
                              btnLoading = true;
                            });
                            refresh();
                          },
                          title: AppLocalizations.of(context).refresh,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
