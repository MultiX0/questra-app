import 'dart:developer';

import 'package:questra_app/core/shared/widgets/cooldown_timer.dart';
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/app/widgets/daily_quests_card.dart';
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
    final now = DateTime.now().toUtc();
    log('${quest?.id}');

    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).daily_quest),
        body: Center(
          child:
              (dailyQuest.isLoading || quest == null)
                  ? BeatLoader()
                  : ((quest.submittedAt != null &&
                              quest.submittedAt!.add(const Duration(hours: 6)).isAfter(now))
                          ? quest.submittedAt?.add(const Duration(hours: 6))
                          : null) !=
                      null
                  ? CooldownTimer(
                    lastQuestTime: quest.submittedAt!.add(const Duration(hours: 6)),
                    refreshWidget: MainAppButton(
                      onTap: () => ref.read(dailyQuestStateProvider.notifier).init(),
                      title: AppLocalizations.of(context).refresh,
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: AppRefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(milliseconds: 1000), () {
                          ref.read(dailyQuestStateProvider.notifier).init();
                        });
                      },
                      child: ListView(
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            AppLocalizations.of(context).exercice_hint,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppColors.descriptionColor),
                          ),
                          const SizedBox(height: 5),
                          DailyQuestsCard(
                            outerPadding: true,
                            title: AppLocalizations.of(context).pushups_title,
                            descirption: AppLocalizations.of(context).pushups_label,
                            icon:
                                'https://firebasestorage.googleapis.com/v0/b/remindeme-d926a.appspot.com/o/icons%2Fpush-ups.svg?alt=media&token=dbb829d6-be7f-49cc-9e38-a51c12942ca9',
                            child: buildExercise(
                              count: quest.pushUps,
                              iAchive: quest.pushUpsIdid,
                              increment: () => handleChange(questModel: quest, pushUps: true),
                              decrement:
                                  () => handleChange(
                                    questModel: quest,
                                    pushUps: true,
                                    increment: false,
                                  ),
                            ),
                          ),
                          DailyQuestsCard(
                            outerPadding: true,
                            title: AppLocalizations.of(context).situps_title,
                            descirption: AppLocalizations.of(context).situps_label,
                            icon:
                                'https://firebasestorage.googleapis.com/v0/b/remindeme-d926a.appspot.com/o/icons%2Fset-ups.svg?alt=media&token=d10aa68c-d751-4999-941a-3efddd588fa1',
                            child: buildExercise(
                              count: quest.setUps,
                              iAchive: quest.setUpsIdid ?? 0,
                              increment: () => handleChange(questModel: quest, setUps: true),
                              decrement:
                                  () => handleChange(
                                    questModel: quest,
                                    setUps: true,
                                    increment: false,
                                  ),
                            ),
                          ),
                          DailyQuestsCard(
                            outerPadding: true,
                            title: AppLocalizations.of(context).squats_title,
                            descirption: AppLocalizations.of(context).squats_label,
                            icon:
                                'https://firebasestorage.googleapis.com/v0/b/remindeme-d926a.appspot.com/o/icons%2Fedited-squats.svg?alt=media&token=585a1a5e-722d-4018-9ce2-ea600739c9d1',
                            child: buildExercise(
                              count: quest.squats,
                              iAchive: quest.squatsIdid ?? 0,
                              increment: () => handleChange(questModel: quest, squats: true),
                              decrement:
                                  () => handleChange(
                                    questModel: quest,
                                    squats: true,
                                    increment: false,
                                  ),
                            ),
                          ),
                          DailyQuestsCard(
                            outerPadding: true,
                            title: AppLocalizations.of(context).running_title,
                            descirption: AppLocalizations.of(context).running_label,
                            icon:
                                'https://firebasestorage.googleapis.com/v0/b/remindeme-d926a.appspot.com/o/icons%2Frunning.svg?alt=media&token=1083150c-1e37-43e1-bac3-ceeacfe3f54b',
                            child: buildExercise(
                              count: quest.kmRun,
                              iAchive: quest.runningIdid ?? 0,
                              increment: () => handleChange(questModel: quest, run: true),
                              decrement:
                                  () =>
                                      handleChange(questModel: quest, run: true, increment: false),
                            ),
                          ),
                          const SizedBox(height: 10),
                          MainAppButton(
                            onTap: finishQuest,
                            title: AppLocalizations.of(context).finish,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  void finishQuest() {
    openSheet(
      context: context,
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
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
                        AppLocalizations.of(context).daily_quest_complete_confirmation,
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
                      onTap: () {
                        ref.read(dailyQuestStateProvider.notifier).finishQuest(context);
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

  void handleChange({
    bool pushUps = false,
    bool setUps = false,
    bool squats = false,
    bool run = false,
    required DailyQuestModel questModel,
    bool increment = true,
  }) {
    log("increment");
    DailyQuestModel quest = questModel;
    if (pushUps) {
      log("pushups");
      if (increment) {
        quest = quest.copyWith(pushUpsIdid: (questModel.pushUpsIdid ?? 0) + 1);
      } else {
        if (questModel.pushUpsIdid! >= 1) {
          quest = quest.copyWith(pushUpsIdid: (questModel.pushUpsIdid ?? 0) - 1);
        }
      }
    }
    if (setUps) {
      if (increment) {
        quest = quest.copyWith(setUpsIdid: (questModel.setUpsIdid ?? 0) + 1);
      } else {
        if (questModel.setUpsIdid! >= 1) {
          quest = quest.copyWith(setUpsIdid: (questModel.setUpsIdid ?? 0) - 1);
        }
      }
    }

    if (squats) {
      if (increment) {
        quest = quest.copyWith(squatsIdid: (questModel.squatsIdid ?? 0) + 1);
      } else {
        if (questModel.squatsIdid! >= 1) {
          quest = quest.copyWith(squatsIdid: (questModel.squatsIdid ?? 0) - 1);
        }
      }
    }

    if (run) {
      if (increment) {
        quest = quest.copyWith(runningIdid: (questModel.runningIdid ?? 0.0) + 0.1);
      } else {
        if (questModel.runningIdid! >= 0.1) {
          quest = quest.copyWith(runningIdid: (questModel.runningIdid ?? 0.0) - 0.1);
        }
      }
    }

    ref.read(dailyQuestStateProvider.notifier).updateState(quest);
  }

  Widget buildExercise({
    required dynamic count,

    required dynamic iAchive,
    required Function() increment,
    required Function() decrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

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
            "${iAchive is double ? iAchive.toStringAsFixed(1) : iAchive} / ${count is double ? count.toStringAsFixed(1) : count}",
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SystemCard(
            onTap: () {
              ref.read(soundEffectsServiceProvider).playSystemButtonClick();
              decrement();
            },
            isButton: true,
            padding: EdgeInsets.all(8),
            child: Icon(LucideIcons.minus),
          ),
        ],
      ),
    );
  }
}
