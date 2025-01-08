import 'package:questra_app/features/preferences/models/user_preferences_model.dart';
import 'package:questra_app/imports.dart';

class UserPreferencesPage extends ConsumerStatefulWidget {
  const UserPreferencesPage({
    super.key,
    required this.next,
    required this.prev,
  });

  final VoidCallback next;
  final VoidCallback prev;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends ConsumerState<UserPreferencesPage> {
  late TextEditingController _socialInteractionsController;
  late TextEditingController _availabilityController;
  late TextEditingController _difficultyController;

  late FocusNode socialInteractionsNode;
  late FocusNode difficultyNode;
  late FocusNode availabilityNode;

  String socialInteractions = '';
  String availability = '';
  String difficulty = '';

  DateTime? selectedDate;

  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _socialInteractionsController = TextEditingController();
    _availabilityController = TextEditingController();
    _difficultyController = TextEditingController();

    // _learningStyle

    socialInteractionsNode = FocusNode();
    difficultyNode = FocusNode();
    availabilityNode = FocusNode();
  }

  @override
  void dispose() {
    _socialInteractionsController.dispose();
    _availabilityController.dispose();
    _difficultyController.dispose();

    socialInteractionsNode.dispose();
    difficultyNode.dispose();
    availabilityNode.dispose();

    super.dispose();
  }

  void selectSocialInteractions() {
    openSheet(
      context: context,
      body: SelectRadioWidget(
        changeVal: (v) {
          setState(() {
            socialInteractions = v;
            _socialInteractionsController.text = v;
          });
          socialInteractionsNode.unfocus();
          context.pop();
        },
        group: socialInteractions,
        choices: [
          'Gamified Social Challenges',
          'Story-Driven Social Quests',
          'Community-Based Engagement',
          'Simulated Social Scenarios',
          'Virtual Collaboration',
          'Interactive Forums or Chatrooms',
          'Acts of Kindness',
          'Real-World Social Prompts',
        ],
        title: "Select social interactions",
      ),
    );
  }

  void selectAvailability() {
    openSheet(
      context: context,
      body: SelectRadioWidget(
        changeVal: (v) {
          setState(() {
            availability = v;
            _availabilityController.text = v;
          });
          availabilityNode.unfocus();
          context.pop();
        },
        group: availability,
        choices: [
          'More than 1 hour',
          'Less than 1 hour',
          'Exactly 1 hour',
        ],
        title: 'Select availability per day',
      ),
    );
  }

  void selectDifficulty() {
    openSheet(
      context: context,
      body: SelectRadioWidget(
        changeVal: (v) {
          setState(() {
            difficulty = v;
            _difficultyController.text = v;
          });
          difficultyNode.unfocus();
          context.pop();
        },
        group: difficulty,
        choices: [
          'Easy',
          'Medium',
          'Hard',
        ],
        title: 'Select quests difficulty',
      ),
    );
  }

  void handleNext() async {
    if (_key.currentState!.validate()) {
      final localUser = ref.read(localUserProvider);
      widget.next();
      final prefernces = UserPreferencesModel(
        id: -1,
        user_id: localUser?.id ?? "",
        difficulty: difficulty,
        activity_level: null,
        preferred_times: null,
        motivation_level: null,
        time_availability: availability,
        social_interactions: socialInteractions,
      );

      ref.read(localUserProvider.notifier).state = localUser?.copyWith(
        user_preferences: prefernces,
      );
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
                  OnboardingTitle(
                    title: "Preferences",
                  ),
                  const SizedBox(
                    height: kToolbarHeight - 10,
                  ),
                  NeonTextField(
                    onTap: selectSocialInteractions,
                    controller: _socialInteractionsController,
                    labelText: 'social interactions',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'please select your social interactions';
                      }

                      return null;
                    },
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    hintText: 'e.g (Cooperative)',
                    readOnly: true,
                    focusNode: socialInteractionsNode,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  NeonTextField(
                    onTap: selectAvailability,
                    controller: _availabilityController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'please select your gender';
                      }
                      return null;
                    },
                    labelText: 'availability',
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    readOnly: true,
                    hintText: 'e.g (1 hour per day)',
                    focusNode: availabilityNode,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  NeonTextField(
                    onTap: selectDifficulty,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'please select your fitness/activity level';
                      }
                      return null;
                    },
                    controller: _difficultyController,
                    labelText: 'difficulty',
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    readOnly: true,
                    hintText: 'e.g (Medium)',
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: AccountSetupNextButton(next: handleNext, size: size),
      ),
    );
  }
}
