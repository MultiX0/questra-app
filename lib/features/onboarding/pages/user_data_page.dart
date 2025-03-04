// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:questra_app/imports.dart';
import 'package:intl/intl.dart';

class UserDataPage extends ConsumerStatefulWidget {
  const UserDataPage({super.key, required this.next});

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

  Map<String, dynamic> gender = {};
  Map<String, dynamic> activityLevel = {};
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
        title: AppLocalizations.of(context).select_gender,
        choices: [
          {'key': 'male', 'value': AppLocalizations.of(context).male},
          {'key': 'female', 'value': AppLocalizations.of(context).female},
        ],
        changeVal: (v) {
          setState(() {
            gender = v;
            _genderController.text = v['value'];
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
        title: AppLocalizations.of(context).select_fitness_activity_level,
        choices: [
          {'key': 'sedentary', 'value': AppLocalizations.of(context).sedentary},
          {'key': 'lightly_active', 'value': AppLocalizations.of(context).lightly_active},
          {'key': 'moderately_active', 'value': AppLocalizations.of(context).moderately_active},
          {'key': 'very_active', 'value': AppLocalizations.of(context).very_active},
          {'key': 'athletic', 'value': AppLocalizations.of(context).athletic},
        ],
        changeVal: (v) {
          setState(() {
            activityLevel = v;
            _activityController.text = v['value'];
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
        itemStyle: TextStyle(color: AppColors.whiteColor),
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
      final availableUsername = await ref
          .read(authStateProvider.notifier)
          .availableUsername(username);

      if (!availableUsername) {
        // TODO
        // later make a temp table on the database to store the user data temporary becuase when we have two users signup in the same time
        // and by any chanse take the same username we do not want to get an error , so we need to save the current data until the user finish signup.

        CustomToast.systemToast(AppLocalizations.of(context).the_username_is_taken(username));
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
        gender: gender['key'].toLowerCase(),
        lang: ref.read(localeProvider).languageCode,
        avatar: "",
      );

      widget.next();
      return;
    }

    if (_nameController.text.trim().length < 4 || _usernameController.text.trim().length < 4) {
      CustomToast.systemToast(
        AppLocalizations.of(context).username_should_be_more_than_4_characters,
        systemMessage: true,
      );
      return;
    }

    CustomToast.systemToast(
      AppLocalizations.of(context).please_fill_all_fields,
      systemMessage: true,
    );
  }

  void changeLang() {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    final currentLang = ref.read(localeProvider).languageCode;
    Locale newLang;
    if (currentLang == 'ar') {
      newLang = Locale('en');
    } else {
      newLang = Locale('ar');
    }
    ref.read(localeProvider.notifier).state = newLang;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return OnboardingBg(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
              icon: Icon(LucideIcons.log_out),
            ),
            IconButton(onPressed: changeLang, icon: Icon(LucideIcons.languages)),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Form(
            key: _key,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  OnboardingTitle().swing(),
                  const SizedBox(height: kToolbarHeight - 10),
                  NeonTextField(
                    controller: _nameController,
                    labelText: AppLocalizations.of(context).full_name,
                    glowColor: HexColor('7AD5FF'),
                    hintText: AppLocalizations.of(context).player_name_hint,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppLocalizations.of(context).please_enter_valid_name;
                      }
                      if (val.length < 4) {
                        return AppLocalizations.of(context).name_should_be_more_than_4_characters;
                      }

                      return null;
                    },
                    maxLength: 20,
                  ),
                  const SizedBox(height: 15),
                  NeonTextField(
                    controller: _usernameController,

                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')), // Deny any whitespace
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-z0-9_.]'),
                      ), // Allow only lowercase, underscore, dot
                    ],
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppLocalizations.of(context).enter_valid_username;
                      }

                      if (val.length < 4) {
                        return AppLocalizations.of(
                          context,
                        ).username_should_be_more_than_4_characters;
                      }

                      return null;
                    },
                    labelText: AppLocalizations.of(context).username,
                    glowColor: HexColor('7AD5FF'),
                    maxLength: 20,
                    hintText: AppLocalizations.of(context).player_username_hint,
                  ).bounceIn(),
                  const SizedBox(height: 15),
                  NeonTextField(
                    onTap: birthDateSheet,
                    controller: _birthDayController,
                    labelText: AppLocalizations.of(context).birthday,
                    icon: LucideIcons.calendar,
                    glowColor: HexColor('7AD5FF'),
                    hintText: AppLocalizations.of(context).player_birthday_hint,
                    readOnly: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppLocalizations.of(context).please_enter_birth_date;
                      }
                      return null;
                    },
                  ).bounceInRight(duration: const Duration(milliseconds: 1200)),
                  const SizedBox(height: 15),
                  NeonTextField(
                    focusNode: genderFocusNode,
                    onTap: genderSheet,
                    controller: _genderController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context).please_select_gender;
                      }
                      return null;
                    },
                    labelText: AppLocalizations.of(context).gender,
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    readOnly: true,
                    hintText: AppLocalizations.of(context).player_gender_hint,
                  ).bounceInLeft(duration: const Duration(milliseconds: 1400)),
                  const SizedBox(height: 15),
                  NeonTextField(
                    onTap: activitySheet,
                    focusNode: activityFocusNode,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context).please_select_fitness_activity_level;
                      }
                      return null;
                    },
                    controller: _activityController,
                    labelText: AppLocalizations.of(context).fitness_activity,
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    readOnly: true,
                    hintText: AppLocalizations.of(context).general_fitness_activity_hint,
                  ).bounceInDown(duration: const Duration(milliseconds: 1600)),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: AccountSetupNextButton(next: handleNext, size: size).tada(),
      ),
    );
  }
}
