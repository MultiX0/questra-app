import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/events/controller/events_controller.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/features/events/pages/player_registered.dart';
import 'package:questra_app/features/events/widgets/event_quest_card.dart';
import 'package:questra_app/features/quests/widgets/loading_events_card.dart';
import 'package:questra_app/imports.dart';

class QuestEventsPage extends ConsumerStatefulWidget {
  const QuestEventsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuestEventsPageState();
}

class _QuestEventsPageState extends ConsumerState<QuestEventsPage> {
  bool refreshLoading = false;

  int selectedIndex = 0;

  void onTap(EventQuestModel quest) {
    // final event = ref.watch(selectedQuestEvent);
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    ref.read(viewEventQuestProvider.notifier).state = quest;
    context.push(Routes.viewEventQuestPage);
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.sizeOf(context);
    final event = ref.watch(selectedQuestEvent);
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: event!.title),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              buildCategoryChange(),
              const SizedBox(height: 10),
              Expanded(
                child:
                    selectedIndex == 0
                        ? ref
                            .watch(getAllQuestsInEventProvider)
                            .when(
                              data: (quests) {
                                if (quests.isEmpty) return Center(child: buildEmptyQuests());
                                return ListView.builder(
                                  itemCount: quests.length,
                                  itemBuilder: (conext, i) {
                                    final quest = quests[i];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      child: EventsQuestCard(
                                        quest: quest,
                                        onTap: () => onTap(quest),
                                      ),
                                    );
                                  },
                                );
                              },
                              error: (error, _) => Center(child: ErrorWidget(error)),
                              loading:
                                  () => ListView.builder(
                                    itemCount: 4,
                                    itemBuilder: (context, i) => LoadingQuestsCard(),
                                  ),
                            )
                        : PlayerRegisteredToEvent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryChange() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Row(
      spacing: 10,
      children: [
        Expanded(
          child: buildCategoryCard(
            duration: const Duration(milliseconds: 300),
            index: 0,
            text: "Quests",
          ),
        ),
        Expanded(
          child: buildCategoryCard(
            duration: const Duration(milliseconds: 300),
            index: 1,
            text: "Participants",
          ),
        ),
      ],
    ),
  );
  GestureDetector buildCategoryCard({
    required Duration duration,
    required int index,
    required String text,
  }) {
    bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        if (selectedIndex == index) return;
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          color:
              isActive
                  ? Colors.purpleAccent.withValues(alpha: .15)
                  : AppColors.primary.withValues(alpha: 0.15),
          border: Border.all(color: isActive ? Colors.purpleAccent : AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Center(child: Text(text)),
      ),
    );
  }

  Widget buildEmptyQuests() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        child: SystemCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.hexagon, color: AppColors.primary, size: 50),
              const SizedBox(height: 15),
              Text(
                "There is no quests for now",
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  color: AppColors.descriptionColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              if (refreshLoading) ...[
                BeatLoader(),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    backgroundColor: HexColor("7AD5FF").withValues(alpha: .35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: HexColor('7AD5FF')),
                    ),
                    foregroundColor: AppColors.whiteColor,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                    setState(() {
                      refreshLoading = true;
                    });
                    await Future.delayed(const Duration(milliseconds: 800));
                    ref.invalidate(getAllQuestsInEventProvider);

                    await Future.delayed(const Duration(milliseconds: 1500), () {
                      setState(() {
                        refreshLoading = false;
                      });
                    });
                  },
                  child: Text("Refresh"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
