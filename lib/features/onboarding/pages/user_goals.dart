import 'dart:async';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:questra_app/core/shared/constants/app_fonts.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/onboarding/widgets/next_button.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_bg.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_title.dart';
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
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      goals.add(text);
      _showGoals[text] = false;
    });

    Future.microtask(() {
      setState(() => _showGoals[text] = true);
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return OnboardingBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: AccountSetupNextButton(
          next: () {
            // widget.next
            context.go(Routes.homePage);
          },
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
                      final goal = goals[goals.length - 1 - index];
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
