import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/features/events/widgets/event_quest_card.dart';
import 'package:questra_app/features/quests/widgets/quest_image_upload.dart';
import 'package:questra_app/imports.dart';

class ViewEventQuest extends ConsumerStatefulWidget {
  const ViewEventQuest({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewQuestPageState();
}

class _ViewQuestPageState extends ConsumerState<ViewEventQuest> {
  // EventModel get _event => widget.event;
  bool _finish = false;

  void play() {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
  }

  void cancel() {
    setState(() {
      _finish = false;
    });
  }

  void finish() {
    play();

    setState(() {
      _finish = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quest = ref.watch(viewEventQuestProvider)!;
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).view_quest),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: (_finish) ? buildFinish() : buildBody(quest),
        ),
      ),
    );
  }

  Widget buildFinish() {
    final event = ref.watch(selectedQuestEvent);
    return Center(
      child: QuestImageUpload(isEvent: true, minImagesCount: event?.minImageUploadCount ?? 1),
    );
  }

  Widget buildBody(EventQuestModel quest) {
    // final isLoading = ref.watch(questsControllerProvider);
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EventsQuestCard(quest: quest, isView: true),
        const SizedBox(height: 30),
        SystemCard(
          onTap: finish,
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
