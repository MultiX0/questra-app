import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/quest_card.dart';
import 'package:questra_app/features/quests/models/quest_model.dart';
import 'package:questra_app/features/quests/providers/quests_providers.dart';
import 'package:questra_app/features/quests/widgets/finish_quest.dart';
import 'package:questra_app/imports.dart';

class ViewQuestPage extends ConsumerStatefulWidget {
  const ViewQuestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewQuestPageState();
}

class _ViewQuestPageState extends ConsumerState<ViewQuestPage> {
  bool _finish = false;

  void finish() {
    setState(() {
      _finish = !_finish;
    });
  }

  void skip() {
    // TODO implement the quest skip functionality
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
          child: (_finish) ? buildFinish() : buildBody(quest),
        ),
      ),
    );
  }

  Widget buildFinish() => Center(
        child: FinishQuestWidget(
          cancel: finish,
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
