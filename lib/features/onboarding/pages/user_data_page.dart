import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:questra_app/imports.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController _usernameController;
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
    _usernameController = TextEditingController();
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
    _usernameController.dispose();

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
        final d = DateFormat.yMMMMd('en_US').format(date);
        log(d);
        setState(() {
          _birthDayController.text = d;
          selectedDate = date;
        });
        birthDayFocusNode.unfocus();
      },
      currentTime: DateTime.now(),
      locale: picker.LocaleType.en,
    );
  }

  void handleNext() async {
    ref.read(soundEffectsServiceProvider).playMainButtonEffect();
    if (_key.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final availableUsername =
          await ref.read(authStateProvider.notifier).availableUsername(username);

      if (!availableUsername) {
        // TODO
        // later make a temp table on the database to store the user data temporary becuase when we have two users signup in the same time
        // and by any chanse take the same username we do not want to get an error , so we need to save the current data until the user finish signup.

        CustomToast.systemToast("the username ($username) is already taken");
        return;
      }

      final auth = ref.read(supabaseProvider).auth;
      final userId = auth.currentUser?.id;
      final joined_at = auth.currentUser?.createdAt;

      ref.read(localUserProvider.notifier).state = UserModel(
        id: userId ?? '',
        joined_at: DateTime.parse(joined_at ?? DateTime.now().toIso8601String()),
        name: _nameController.text.trim(),
        username: username,
        is_online: true,
        birth_date: selectedDate,
        gender: gender.toLowerCase(),
        avatar: "",
      );

      widget.next();
      return;
    }

    if (_nameController.text.trim().length < 4 || _usernameController.text.trim().length < 4) {
      CustomToast.systemToast("name and username should be more than 4 characters",
          systemMessage: true);
      return;
    }

    CustomToast.systemToast("please fill all the fields!", systemMessage: true);
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
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'please enter valid name';
                      }
                      if (val.length < 4) {
                        return 'the name should contains at least 4 characters';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  NeonTextField(
                    controller: _usernameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')), // Deny any whitespace
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-z_.]')), // Allow only lowercase, underscore, dot
                    ],
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Enter valid username please';
                      }

                      if (val.length < 4) {
                        return 'the username should contains at least 4 characters';
                      }

                      return null;
                    },
                    labelText: 'Username',
                    glowColor: HexColor('7AD5FF'),
                    maxLength: 20,
                    hintText: 'Player usernname (unique) e.g: multix...',
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
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'please enter your birth date';
                      }
                      return null;
                    },
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
          next: handleNext,
          size: size,
        ),
      ),
    );
  }
}
