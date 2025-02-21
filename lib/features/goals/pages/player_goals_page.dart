// ignore_for_file: deprecated_member_use

import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/goals/controller/goals_controller.dart';
import 'package:questra_app/features/goals/models/user_goal_model.dart';
import 'package:questra_app/features/goals/providers/goals_provider.dart';
import 'package:questra_app/imports.dart';

class PlayerGoalsPage extends ConsumerStatefulWidget {
  const PlayerGoalsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerGoalsPageState();
}

class _PlayerGoalsPageState extends ConsumerState<PlayerGoalsPage> {
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

  bool add = false;
  int? deleteId;

  void delete(int id) {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();

    setState(() {
      add = false;
      deleteId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(authStateProvider);
    final goals = ref.watch(playerGoalsProvider);
    return WillPopScope(
      onWillPop: () async {
        if (add) {
          setState(() {
            add = !add;
          });
          return false;
        }
        return true;
      },
      child: BackgroundWidget(
        child: Scaffold(
          floatingActionButton: add
              ? null
              : FloatingActionButton(
                  backgroundColor: AppColors.primary.withValues(alpha: .5),
                  elevation: 3,
                  child: Icon(LucideIcons.plus),
                  onPressed: () {
                    ref.read(soundEffectsServiceProvider).playSystemButtonClick();

                    setState(() {
                      add = true;
                    });
                  },
                ),
          appBar: TheAppBar(title: "Goals"),
          body: (!add)
              ? (deleteId != null)
                  ? buildDeleteDialog()
                  : GridView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: goals.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        return Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: HexColor('7AD5FF').withValues(alpha: .15),
                            border: Border.all(color: HexColor('7AD5FF')),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => delete(goal.id),
                                  icon: Icon(
                                    LucideIcons.minus,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
              : buildAddForm(),
        ),
      ),
    );
  }

  Future<void> finish() async {
    try {
      if (_controller.text.trim().length < 8) {
        CustomToast.systemToast("Goal should be contains at lease 8 characters");
        return;
      }
      final user = ref.read(authStateProvider);
      final goal = UserGoalModel(
        id: -1,
        created_at: DateTime.now(),
        user_id: user?.id ?? "",
        description: _controller.text.trim(),
        status: 'in_progress',
      );
      await ref.read(goalsControllerProvider.notifier).insertGoals(goal: goal);
      setState(() {
        _controller.clear();
        add = false;
      });
    } catch (e) {
      rethrow;
    }
  }

  Widget buildAddForm() {
    final size = MediaQuery.sizeOf(context);
    final isLoading = ref.watch(goalsControllerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        child: Center(
          child: SystemCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "NEW GOAL!",
                      style: TextStyle(
                        fontFamily: AppFonts.header,
                        fontSize: 18,
                      ),
                    ),
                    Icon(
                      LucideIcons.sparkles,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                buildGoalForm(size),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "hint: Your goals help the system to understand more about your needs to make better quests for you.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(
                  height: 15,
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
      ),
    );
  }

  Widget buildDeleteDialog() {
    final isLoading = ref.watch(goalsControllerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        child: Center(
          child: SystemCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delete Goal",
                      style: TextStyle(
                        fontFamily: AppFonts.header,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "readme: Your goals help the system to understand more about your needs to make better quests for you.\ndo you want to delete this goal?",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                if (isLoading) ...[
                  BeatLoader(),
                ] else ...[
                  SystemCardButton(
                    onTap: () {
                      ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                      ref.read(goalsControllerProvider.notifier).deleteGoal(deleteId!, () {
                        setState(() {
                          deleteId = null;
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  SystemCardButton(
                    doneButton: false,
                    onTap: () {
                      ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                      setState(() {
                        deleteId = null;
                      });
                    },
                    text: "cancel",
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox buildGoalForm(Size size) {
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
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 14,
            color: Colors.white.withValues(alpha: .86),
          ),
          hintText: "please enter your goal here ...",
        ),
      ),
    );
  }
}
