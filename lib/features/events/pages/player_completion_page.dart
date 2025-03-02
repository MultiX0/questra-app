// ignore_for_file: deprecated_member_use

import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/events/controller/events_controller.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/features/events/providers/providers.dart';
import 'package:questra_app/features/events/widgets/event_quest_card.dart';
import 'package:questra_app/features/events/widgets/submission_view_widget.dart';
import 'package:questra_app/features/quests/widgets/loading_events_card.dart';
import 'package:questra_app/imports.dart';

class PlayerCompletionPage extends ConsumerStatefulWidget {
  const PlayerCompletionPage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerCompletionPageState();
}

class _PlayerCompletionPageState extends ConsumerState<PlayerCompletionPage> {
  String? selectedQuestId;
  bool refreshLoading = false;

  void onTap(EventQuestModel quest) {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    if (selectedQuestId != quest.id) {
      setState(() {
        selectedQuestId = quest.id;
      });
      ref.read(selectedEventQuestIdProvider.notifier).state = quest.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedQuestId != null) {
          setState(() {
            selectedQuestId = null;
          });
          return false;
        }

        return true;
      },
      child: BackgroundWidget(
        child: Scaffold(
          appBar: TheAppBar(title: selectedQuestId != null ? null : "Player Quests"),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: selectedQuestId != null ? SubmissionViewWidget() : buildQuestsBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuestsBody() {
    return ref
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
                  child: EventsQuestCard(quest: quest, onTap: () => onTap(quest)),
                );
              },
            );
          },
          error: (error, _) => Center(child: ErrorWidget(error)),
          loading:
              () =>
                  ListView.builder(itemCount: 4, itemBuilder: (context, i) => LoadingQuestsCard()),
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
