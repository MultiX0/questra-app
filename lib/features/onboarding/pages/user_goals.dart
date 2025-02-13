import 'dart:async';

import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/goals/models/user_goal_model.dart';
import 'package:questra_app/imports.dart';

class UserGoalsSetup extends ConsumerStatefulWidget {
  const UserGoalsSetup({
    super.key,
    required this.next,
    required this.prev,
  });

  final VoidCallback next;
  final VoidCallback prev;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserGoalsSetupState();
}

class _UserGoalsSetupState extends ConsumerState<UserGoalsSetup> {
  final List<String> goals = [];

  final Map<String, bool> _showGoals = {};
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void addGoal() {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      goals.add(text);
      _showGoals[text] = false;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() => _showGoals[text] = true);
    });

    _controller.clear();
  }

  void handleNext() {
    ref.read(soundEffectsServiceProvider).playMainButtonEffect();

    if (goals.length < 4) {
      CustomToast.systemToast(
        "add at least 4 clear goals with specific content, (you can edit or add new goals later)",
        systemMessage: true,
      );
      return;
    }

    final localUser = ref.read(localUserProvider);

    final goalsList = goals
        .map(
          (goal) => UserGoalModel(
            id: -1,
            created_at: DateTime.now(),
            user_id: localUser?.id ?? "",
            description: goal,
            status: "in_progress",
          ),
        )
        .toList();

    ref.read(localUserProvider.notifier).state = localUser?.copyWith(
      goals: goalsList,
    );

    context.go(Routes.setupAccountPage);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return OnboardingBg(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: widget.prev,
          ),
        ),
        backgroundColor: Colors.transparent,
        bottomNavigationBar: AccountSetupNextButton(
          next: handleNext,
          size: size,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.05,
                ),
                OnboardingTitle(
                  title: "Preferences",
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                GlowText(
                  text: "Your Goals",
                  spreadRadius: 1,
                  blurRadius: 25,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: AppFonts.primary,
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  glowColor: Colors.white,
                ),
                SizedBox(
                  height: size.height * 0.025,
                ),
                Row(
                  children: [
                    Expanded(
                      child: NeonTextField(
                        controller: _controller,
                        labelText: "Goal",
                        hintText: "enter your goals (very importnant)",
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: addGoal,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: HexColor('7AD5FF'),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 0.5,
                              blurRadius: 20,
                              color: HexColor('7AD5FF').withValues(alpha: .4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons.plus,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.025,
                ),
                Expanded(
                  child: GridView.builder(
                    itemCount: goals.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return AnimatedScale(
                        scale: _showGoals[goal] == true ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: HexColor('7AD5FF').withValues(alpha: .15),
                            border: Border.all(color: HexColor('7AD5FF')),
                          ),
                          child: Text(
                            goal,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
