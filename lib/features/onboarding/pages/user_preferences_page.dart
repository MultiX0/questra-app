import 'package:animate_do/animate_do.dart';
import 'package:questra_app/features/preferences/models/user_preferences_model.dart';
import 'package:questra_app/imports.dart';

class UserPreferencesPage extends ConsumerStatefulWidget {
  const UserPreferencesPage({super.key, required this.next, required this.prev});

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

  Map<String, dynamic> socialInteractions = {};
  Map<String, dynamic> availability = {};
  Map<String, dynamic> difficulty = {};

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
            _socialInteractionsController.text = v['value'];
          });
          socialInteractionsNode.unfocus();
          context.pop();
        },
        group: socialInteractions,
        choices: [
          // 'Gamified Social Challenges',
          // 'Story-Driven Social Quests',
          // 'Community-Based Engagement',
          // 'Simulated Social Scenarios',
          // 'Virtual Collaboration',
          // 'Interactive Forums or Chatrooms',
          // 'Acts of Kindness',
          // 'Real-World Social Prompts',
          {
            'key': "Solo Explorer",
            'value': AppLocalizations.of(context).gamified_social_challenges,
          },

          {
            'key': "Friendly Collaborator",
            'value': AppLocalizations.of(context).community_based_engagement,
          },
          {
            'key': "Competitive Challenger",
            'value': AppLocalizations.of(context).simulated_social_scenarios,
          },
          {'key': "Casual Engager", 'value': AppLocalizations.of(context).virtual_collaboration},
          {
            'key': "Silent Observer",
            'value': AppLocalizations.of(context).interactive_forums_or_chatrooms,
          },
          {'key': "Troll Master", 'value': AppLocalizations.of(context).acts_of_kindness},
        ],
        title: AppLocalizations.of(context).select_social_interactions,
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
            _availabilityController.text = v['value'];
          });
          availabilityNode.unfocus();
          context.pop();
        },
        group: availability,
        choices: [
          // 'More than 1 hour', 'Less than 1 hour', 'Exactly 1 hour'
          {'key': "More than 1 hour", 'value': AppLocalizations.of(context).more_than_1_hour},
          {'key': "Less than 1 hour", 'value': AppLocalizations.of(context).less_than_1_hour},
          {'key': "Exactly 1 hour", 'value': AppLocalizations.of(context).exactly_1_hour},
        ],
        title: AppLocalizations.of(context).select_availability_per_day,
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
            _difficultyController.text = v['value'];
          });
          difficultyNode.unfocus();
          context.pop();
        },
        group: difficulty,
        choices: [
          // 'Easy', 'Medium', 'Hard'
          {'key': "Easy", 'value': AppLocalizations.of(context).easy},
          {'key': "Medium", 'value': AppLocalizations.of(context).medium},
          {'key': "Hard", 'value': AppLocalizations.of(context).hard},
        ],
        title: AppLocalizations.of(context).select_quests_difficulty,
      ),
    );
  }

  void handleNext() async {
    ref.read(soundEffectsServiceProvider).playMainButtonEffect();

    if (_key.currentState!.validate()) {
      final localUser = ref.read(localUserProvider);
      widget.next();
      final prefernces = UserPreferencesModel(
        id: -1,
        user_id: localUser?.id ?? "",
        difficulty: difficulty['key'],
        activity_level: null,
        preferred_times: null,
        motivation_level: null,
        time_availability: availability['key'],
        social_interactions: socialInteractions['key'],
      );

      ref.read(localUserProvider.notifier).state = localUser?.copyWith(
        user_preferences: prefernces,
      );
      return;
    }

    CustomToast.systemToast(
      AppLocalizations.of(context).please_fill_all_fields,
      systemMessage: true,
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  OnboardingTitle(title: AppLocalizations.of(context).preferences).swing(),
                  const SizedBox(height: kToolbarHeight - 10),
                  NeonTextField(
                    onTap: selectSocialInteractions,
                    controller: _socialInteractionsController,
                    labelText: AppLocalizations.of(context).social_interactions,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppLocalizations.of(context).please_select_your_social_interactions;
                      }

                      return null;
                    },
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    hintText: AppLocalizations.of(context).social_interactions_hint,
                    readOnly: true,
                    focusNode: socialInteractionsNode,
                  ).bounceIn(),
                  const SizedBox(height: 15),
                  NeonTextField(
                    onTap: selectAvailability,
                    controller: _availabilityController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context).please_select_your_availability;
                      }
                      return null;
                    },
                    labelText: AppLocalizations.of(context).availability,
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    readOnly: true,
                    hintText: AppLocalizations.of(context).availability_hint,
                    focusNode: availabilityNode,
                  ).bounceInLeft(duration: const Duration(milliseconds: 1200)),
                  const SizedBox(height: 15),
                  NeonTextField(
                    onTap: selectDifficulty,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context).please_select_fitness_activity_level;
                      }
                      return null;
                    },
                    controller: _difficultyController,
                    labelText: AppLocalizations.of(context).difficulty,
                    icon: LucideIcons.chevron_down,
                    glowColor: HexColor('7AD5FF'),
                    readOnly: true,
                    hintText: AppLocalizations.of(context).difficulty_hint,
                  ).bounceInRight(duration: const Duration(milliseconds: 1400)),
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
