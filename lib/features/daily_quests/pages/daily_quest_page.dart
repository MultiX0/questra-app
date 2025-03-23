import 'dart:developer';

import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/daily_quests/models/daily_quest_model.dart';
import 'package:questra_app/features/daily_quests/providers/daily_quest_state.dart';
import 'package:questra_app/imports.dart';

class DailyQuestPage extends ConsumerStatefulWidget {
  const DailyQuestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DailyQuestPageState();
}

class _DailyQuestPageState extends ConsumerState<DailyQuestPage> {
  @override
  Widget build(BuildContext context) {
    final dailyQuest = ref.watch(dailyQuestStateProvider);
    final quest = dailyQuest.quest;
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).daily_quest),
        body: Center(
          child:
              dailyQuest.isLoading
                  ? BeatLoader()
                  : Padding(
                    padding: const EdgeInsets.all(25),
                    child: AppRefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(milliseconds: 1000), () {
                          ref.read(dailyQuestStateProvider.notifier).init();
                        });
                      },
                      child: ListView(
                        children: [
                          SystemCard(
                            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context).details,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 15),
                                buildExercise(
                                  name: 'Push-Ups',
                                  count: quest?.pushUps ?? 0,
                                  iAchive: quest?.pushUpsIdid ?? 0,
                                  increment: () => increment(questModel: quest!, pushUps: true),
                                ),
                                buildExercise(
                                  name: 'Set-Ups',
                                  count: quest?.setUps ?? 0,
                                  iAchive: quest?.setUpsIdid ?? 0,
                                  increment: () => increment(questModel: quest!, setUps: true),
                                ),
                                buildExercise(
                                  name: 'Squats',
                                  count: quest?.squats ?? 0,
                                  iAchive: quest?.squatsIdid ?? 0,
                                  increment: () => increment(questModel: quest!, squats: true),
                                ),
                                buildExercise(
                                  name: 'Run-KM',
                                  count: quest?.kmRun ?? 0,
                                  iAchive: quest?.runningIdid ?? 0.0,
                                  increment: () => increment(questModel: quest!, run: true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  void increment({
    bool pushUps = false,
    bool setUps = false,
    bool squats = false,
    bool run = false,
    required DailyQuestModel questModel,
  }) {
    log("increment");
    DailyQuestModel quest = questModel;
    if (pushUps) {
      log("pushups");
      quest = quest.copyWith(pushUpsIdid: (questModel.pushUpsIdid ?? 0) + 1);
    }
    if (setUps) {
      quest = quest.copyWith(setUpsIdid: (questModel.setUpsIdid ?? 0) + 1);
    }

    if (squats) {
      quest = quest.copyWith(squatsIdid: (questModel.squatsIdid ?? 0) + 1);
    }

    if (run) {
      quest = quest.copyWith(runningIdid: (questModel.runningIdid ?? 0.0) + 0.1);
    }

    ref.read(dailyQuestStateProvider.notifier).updateState(quest);
  }

  Widget buildExercise({
    required dynamic count,
    required String name,
    required dynamic iAchive,
    required Function() increment,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          SystemCard(
            isButton: true,
            padding: EdgeInsets.all(8),
            onTap: () {
              ref.read(soundEffectsServiceProvider).playSystemButtonClick();
              increment();
            },
            child: Icon(LucideIcons.plus),
          ),
          Text(
            "$name: ${iAchive is double ? iAchive.toStringAsFixed(1) : iAchive}/$count",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SystemCard(isButton: true, padding: EdgeInsets.all(8), child: Icon(LucideIcons.minus)),
        ],
      ),
    );
  }
}
