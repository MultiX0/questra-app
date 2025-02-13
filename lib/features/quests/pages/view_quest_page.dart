import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/quest_card.dart';
import 'package:questra_app/features/quests/widgets/feedback_widget.dart';
import 'package:questra_app/features/quests/widgets/finish_quest.dart';
import 'package:questra_app/imports.dart';

class ViewQuestPage extends ConsumerStatefulWidget {
  const ViewQuestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewQuestPageState();
}

class _ViewQuestPageState extends ConsumerState<ViewQuestPage> {
  bool _finish = false;
  bool _skip = false;

  void play() {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
  }

  void finish() {
    play();
    if (_skip) {
      setState(() {
        _skip = false;
      });
    }
    setState(() {
      _finish = true;
    });
  }

  void skip() {
    play();

    if (_finish) {
      setState(() {
        _finish = false;
      });
    }

    setState(() {
      _skip = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quest = ref.watch(viewQuestProvider)!;
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(
          title: "View Quest",
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: (_finish)
              ? buildFinish()
              : (_skip)
                  ? buildSkip()
                  : buildBody(quest),
        ),
      ),
    );
  }

  Widget buildFinish() => Center(
        child: FinishQuestWidget(
          cancel: finish,
        ),
      );

  Widget buildSkip() => Center(
        child: QuestFeedbackWidget(
          skip: true,
        ),
      );

  Column buildBody(QuestModel quest) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QuestCard(
          questModel: quest,
          viewPage: true,
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SystemCard(
              onTap: finish,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: kToolbarHeight - 5),
              isButton: true,
              child: Text(
                "finish",
                style: TextStyle(
                  fontFamily: AppFonts.header,
                ),
              ),
            ),
            SystemCard(
              onTap: skip,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: kToolbarHeight - 5),
              isButton: true,
              child: Text(
                "skip",
                style: TextStyle(
                  fontFamily: AppFonts.header,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
