// ignore_for_file: deprecated_member_use

import 'package:flutter_glow/flutter_glow.dart';
import 'package:questra_app/features/shared_quests/controller/shared_quests_controller.dart';
import 'package:questra_app/imports.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

class AddCustomSharedQuestPage extends ConsumerStatefulWidget {
  const AddCustomSharedQuestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddCustomSharedQuestPageState();
}

class _AddCustomSharedQuestPageState extends ConsumerState<AddCustomSharedQuestPage> {
  late TextEditingController _questController;
  late TextEditingController _deadLine;
  late FocusNode _deadLineNode;

  DateTime? selectedDate;
  bool firstCompleteWin = false;

  @override
  void initState() {
    _questController = TextEditingController();
    _deadLine = TextEditingController();
    _deadLineNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _questController.dispose();
    _deadLine.dispose();
    _deadLineNode.dispose();
    super.dispose();
  }

  void submmit() {
    final content = _questController.text.trim();

    if (content.isEmpty || content.length < 10) {
      CustomToast.systemToast(AppLocalizations.of(context).custom_quest_add_toast);
      return;
    }

    if (selectedDate == null) {
      CustomToast.systemToast(AppLocalizations.of(context).quest_deadline_required);
      return;
    }

    ref
        .read(sharedQuestsControllerProvider.notifier)
        .sendRequest(
          questContent: content,
          deadLine: selectedDate!,
          isAiGenerated: false,
          firstCompleteWin: firstCompleteWin,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(sharedQuestsControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          CustomToast.systemToast(AppLocalizations.of(context).custom_quest_add_alert);
          return false;
        }
        return true;
      },
      child: BackgroundWidget(
        child: Scaffold(
          appBar: TheAppBar(title: AppLocalizations.of(context).add_quest),
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
                              AppLocalizations.of(context).custom_quest_add_card_title,
                              style: TextStyle(
                                fontFamily: isArabic ? null : AppFonts.header,
                                fontWeight: isArabic ? FontWeight.bold : null,
                                fontSize: 18,
                              ),
                            ),
                            Icon(LucideIcons.diamond, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 15),
                        buildQuestForm(
                          size,
                          controller: _questController,
                          isReadOnly: false,
                          hintText: AppLocalizations.of(context).shared_quest_add_details_hint,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          AppLocalizations.of(context).shared_quest_add_deadline_hint,
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 5),

                        buildQuestForm(
                          size,
                          isReadOnly: true,
                          controller: _deadLine,
                          hintText: AppLocalizations.of(context).shared_quest_deadline,
                          onTap: () => deadLinePicker(context),
                          node: _deadLineNode,
                        ),

                        const SizedBox(height: 15),

                        Text(
                          AppLocalizations.of(context).custom_quest_add_card_note,
                          style: TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            GlowCheckbox(
                              color: AppColors.primary.withValues(alpha: .5),
                              checkColor: Colors.black,
                              glowColor: AppColors.primary,
                              value: firstCompleteWin,
                              onChange: (_) {
                                setState(() {
                                  firstCompleteWin = !firstCompleteWin;
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context).quest_first_complete_win_label,
                              style: TextStyle(color: AppColors.whiteColor, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        Text(
                          AppLocalizations.of(context).shared_quest_add_note,
                          style: TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                        const SizedBox(height: 10),
                        if (isLoading) ...[BeatLoader()] else ...[SystemCardButton(onTap: submmit)],
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

  void deadLinePicker(BuildContext context) {
    picker.DatePicker.showDateTimePicker(
      context,
      theme: picker.DatePickerTheme(
        backgroundColor: AppColors.scaffoldBackground,
        itemStyle: TextStyle(color: AppColors.whiteColor),
        cancelStyle: TextStyle(color: Colors.white60),
      ),
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 7)),
      // onChanged: (date) {
      //   final d = DateFormat.yMMMMd('en_US').format(date);

      //   setState(() {
      //     _deadLine.text = d;
      //     selectedDate = date;
      //   });
      // },
      onConfirm: (date) {
        // final d = DateFormat.yMMMMd('en_US').format(date);
        if (date.isBefore(DateTime.now().add(const Duration(hours: 5)))) {
          setState(() {
            _deadLine.clear();
            selectedDate = null;
          });
          CustomToast.systemToast(AppLocalizations.of(context).shared_quest_deadline_toast);
          return;
        }
        setState(() {
          _deadLine.text = appDateFormat(date);
          selectedDate = date;
        });
        _deadLineNode.unfocus();
      },
      currentTime: DateTime.now(),
      locale: picker.LocaleType.en,
    );
  }

  ConstrainedBox buildQuestForm(
    Size size, {
    required TextEditingController controller,
    required String hintText,
    required bool isReadOnly,
    Function()? onTap,
    FocusNode? node,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size.width * .25),
      child: TextField(
        focusNode: node,
        onTap: onTap,
        readOnly: isReadOnly,
        controller: controller,
        maxLines: null,
        cursorColor: AppColors.primary,

        decoration: InputDecoration(
          hintMaxLines: 1,
          filled: false,
          border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
          hintStyle: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 14,
            color: Colors.white.withValues(alpha: .86),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
