import 'dart:developer';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:questra_app/features/onboarding/widgets/next_button.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_bg.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_title.dart';
import 'package:questra_app/features/onboarding/widgets/select_radio_widget.dart';
import 'package:questra_app/imports.dart';
import 'package:intl/intl.dart';
import 'package:questra_app/core/shared/utils/bottom_sheet.dart';

class UserDataPage extends ConsumerStatefulWidget {
  const UserDataPage({
    super.key,
    required this.next,
  });

  final VoidCallback next;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserDataPageState();
}

class _UserDataPageState extends ConsumerState<UserDataPage> {
  late TextEditingController _nameController;
  late TextEditingController _birthDayController;
  late TextEditingController _genderController;
  late TextEditingController _activityController;

  late FocusNode genderFocusNode;
  late FocusNode activityFocusNode;
  late FocusNode birthDayFocusNode;

  String gender = '';
  String activityLevel = '';
  DateTime? selectedDate;

  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _birthDayController = TextEditingController();
    _genderController = TextEditingController();
    _activityController = TextEditingController();
    genderFocusNode = FocusNode();
    activityFocusNode = FocusNode();
    birthDayFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDayController.dispose();
    _genderController.dispose();
    _activityController.dispose();
    genderFocusNode.dispose();
    activityFocusNode.dispose();
    birthDayFocusNode.dispose();
    super.dispose();
  }

  void genderSheet() {
    openSheet(
      context: context,
      body: SelectRadioWidget(
        title: 'Select Gender',
        choices: [
          'Male',
          'Female',
        ],
        changeVal: (v) {
          setState(() {
            gender = v;
            _genderController.text = v;
          });
          context.pop();
          genderFocusNode.unfocus();
        },
        group: gender,
      ),
    );
  }

  // 'sedentary', 'lightly' 'active', 'moderately' 'active', 'very active', 'athletic'

  void activitySheet() {
    openSheet(
      context: context,
      body: SelectRadioWidget(
        title: "Select fitness/activity level",
        choices: [
          'sedentary',
          'lightly active',
          'moderately active',
          'very active',
          'athletic',
        ],
        changeVal: (v) {
          setState(() {
            activityLevel = v;
            _activityController.text = v;
          });
          activityFocusNode.unfocus();
          context.pop();
        },
        group: activityLevel,
      ),
    );
  }

  void birthDateSheet() {
    picker.DatePicker.showDatePicker(
      context,
      theme: picker.DatePickerTheme(
        backgroundColor: AppColors.scaffoldBackground,
        itemStyle: TextStyle(
          color: AppColors.whiteColor,
        ),
        cancelStyle: TextStyle(color: Colors.white60),
      ),
      showTitleActions: true,
      maxTime: DateTime.now().subtract(const Duration(days: 365 * 16)),
      onChanged: (date) {
        final d = DateFormat.yMMMMd('en_US').format(date);
        log(d);
        setState(() {
          _birthDayController.text = d;
          selectedDate = date;
        });
      },
      onConfirm: (date) {
        birthDayFocusNode.unfocus();
      },
      currentTime: DateTime.now(),
      locale: picker.LocaleType.en,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return OnboardingBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Form(
            key: _key,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                children: [
                  OnboardingTitle(),
                  const SizedBox(
                    height: kToolbarHeight - 10,
                  ),
                  NeonTextField(
                    controller: _nameController,
                    labelText: 'Full name',
                    glowColor: HexColor('7AD5FF'),
                    hintText: 'Player name ...',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  NeonTextField(
                    onTap: birthDateSheet,
                    controller: _birthDayController,
                    labelText: 'Birthday',
                    icon: LucideIcons.calendar,
                    glowColor: HexColor('7AD5FF'),
                    hintText: 'Player Birthday ...',
                    readOnly: true,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  NeonTextField(
                    focusNode: genderFocusNode,
                    onTap: genderSheet,
                    controller: _genderController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'please select your gender';
                      }
                      return null;
                    },
                    labelText: 'Gender',
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    readOnly: true,
                    hintText: 'Player Gender ...',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  NeonTextField(
                    onTap: activitySheet,
                    focusNode: activityFocusNode,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'please select your fitness/activity level';
                      }
                      return null;
                    },
                    controller: _activityController,
                    labelText: 'fitness/activity',
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    readOnly: true,
                    hintText: 'General fitness/activity level',
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: AccountSetupNextButton(
          next: widget.next,
          size: size,
        ),
      ),
    );
  }
}
