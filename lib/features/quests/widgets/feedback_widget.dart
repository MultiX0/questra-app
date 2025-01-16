import 'package:questra_app/core/shared/constants/constants.dart';
import 'package:questra_app/features/quests/models/feedback_model.dart';
import 'package:questra_app/features/quests/widgets/quest_completion_widget.dart';
import 'package:questra_app/imports.dart';

class QuestFeedbackWidget extends ConsumerStatefulWidget {
  const QuestFeedbackWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuestFeedbackWidgetState();
}

class _QuestFeedbackWidgetState extends ConsumerState<QuestFeedbackWidget> {
  late TextEditingController _controller;
  late TextEditingController _feedbackStatusController;

  String feedbackTypeGroup = '';

  bool done = false;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _feedbackStatusController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _feedbackStatusController.dispose();
    super.dispose();
  }

  void finish() async {
    final quest = ref.watch(viewQuestProvider)!;

    FeedbackModel? feedbackModel;

    if (_controller.text.trim().isNotEmpty) {
      feedbackModel = setFeedback(quest.id);
    }

    final result = await ref.read(questsControllerProvider.notifier).finishQuest(
          context: context,
          quest: quest,
          feedback: feedbackModel,
        );
    if (result) {
      setState(() {
        done = true;
      });
    }
  }

  FeedbackModel setFeedback(String questId) {
    final user = ref.read(authStateProvider);
    return FeedbackModel(
      user_feedback_id: -1,
      created_at: DateTime.now(),
      user_id: user?.id ?? "",
      user_quest_id: questId,
      feedback_type: _feedbackStatusController.text.trim(),
      description: _controller.text.trim(),
    );
  }

  void selectFeedbackType() {
    openSheet(
      context: context,
      body: SelectRadioWidget(
        changeVal: (val) {
          setState(() {
            _feedbackStatusController.text = val;
            feedbackTypeGroup = val;
          });
          context.pop();
        },
        group: feedbackTypeGroup,
        choices: questFeedbackTypes,
        title: "Feedback type",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (done) {
      return QuestCompletionWidget();
    }

    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          SystemCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Feedback",
                      style: TextStyle(
                        fontFamily: AppFonts.header,
                        fontSize: 18,
                      ),
                    ),
                    Icon(
                      LucideIcons.message_circle,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                buildFeedbackTypeForm(),
                const SizedBox(
                  height: 15,
                ),
                buildFeedbackForm(size),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "hint: Your feedback help the system to understand more about your needs to make better quests for you.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SystemCardButton(
                  onTap: finish,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ConstrainedBox buildFeedbackForm(Size size) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: size.width * .25,
      ),
      child: TextField(
        controller: _controller,
        maxLines: null,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 14,
            color: Colors.white.withValues(alpha: .86),
          ),
          hintText: "please enter your feedback here ...",
        ),
      ),
    );
  }

  TextField buildFeedbackTypeForm() {
    return TextField(
      controller: _feedbackStatusController,
      onTap: selectFeedbackType,
      readOnly: true,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        filled: false,
        border: UnderlineInputBorder(
            borderSide: BorderSide(
          color: AppColors.primary,
        )),
        hintStyle: TextStyle(
          fontWeight: FontWeight.w200,
          fontSize: 14,
          color: Colors.white.withValues(alpha: .86),
        ),
        hintText: "select feedback type",
      ),
    );
  }
}
