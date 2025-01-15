import 'package:questra_app/imports.dart';

final _controller = TextEditingController();

class QuestFeedbackWidget extends ConsumerWidget {
  const QuestFeedbackWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);

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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: size.width * .3,
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
                ),
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
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      "[ done ]",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
