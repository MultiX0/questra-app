// ignore_for_file: deprecated_member_use

import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/imports.dart';

class AddCusomeQuestPage extends ConsumerStatefulWidget {
  const AddCusomeQuestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddCusomeQuestPageState();
}

class _AddCusomeQuestPageState extends ConsumerState<AddCusomeQuestPage> {
  late TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void finish() {
    final _text = _controller.text.trim();
    if (_text.isEmpty || _text.length < 10) {
      CustomToast.systemToast(
        "You need to enter at least 10 characters to be able to create a special quest, and you also need to enter precise details about the quest.",
        systemMessage: true,
      );
      return;
    }

    ref
        .read(questsControllerProvider.notifier)
        .addCustomQuest(description: _text, context: context);
  }

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(authStateProvider);
    final isLoading = ref.watch(questsControllerProvider);
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          CustomToast.systemToast("You cannot leave this page while the quest is being created.");
          return false;
        }
        return true;
      },
      child: BackgroundWidget(
        child: Scaffold(
          appBar: TheAppBar(title: "Add Quest"),
          body: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SystemCard(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Quest Details",
                              style: TextStyle(
                                fontFamily: AppFonts.header,
                                fontSize: 18,
                              ),
                            ),
                            Icon(
                              LucideIcons.diamond,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        buildQuestForm(size),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "hint: You need to write the quest details accurately in order for it to be accepted by the system.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (isLoading) ...[
                          BeatLoader(),
                        ] else ...[
                          SystemCardButton(
                            onTap: finish,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox buildQuestForm(Size size) {
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
          border: UnderlineInputBorder(
              borderSide: BorderSide(
            color: AppColors.primary,
          )),
          errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: AppColors.primary,
          )),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: AppColors.primary,
          )),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: AppColors.primary,
          )),
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: AppColors.primary,
          )),
          focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: AppColors.primary,
          )),
          hintStyle: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 14,
            color: Colors.white.withValues(alpha: .86),
          ),
          hintText: "please enter your quest details here ...",
        ),
      ),
    );
  }
}
