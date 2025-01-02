import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_bg.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_title.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/widgets/glow_button.dart';
import 'package:questra_app/shared/widgets/neaon_textfield.dart';

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

  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _birthDayController = TextEditingController();
    _genderController = TextEditingController();
    _activityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDayController.dispose();
    _genderController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return OnboardingBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: _key,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: 35,
              ),
              children: [
                OnboardingTitle(),
                const SizedBox(
                  height: kToolbarHeight,
                ),
                NeonTextField(
                  controller: _nameController,
                  labelText: 'Full name',
                  glowColor: HexColor('7AD5FF'),
                  hintText: 'Player name ...',
                ),
                const SizedBox(
                  height: 25,
                ),
                NeonTextField(
                  controller: _birthDayController,
                  labelText: 'Birthday',
                  icon: LucideIcons.calendar,
                  glowColor: HexColor('7AD5FF'),
                  hintText: 'Player Birthday ...',
                  readOnly: true,
                ),
                const SizedBox(
                  height: 25,
                ),
                NeonTextField(
                  controller: _birthDayController,
                  labelText: 'Gender',
                  icon: LucideIcons.chevron_down,
                  glowColor: HexColor('7AD5FF'),
                  readOnly: true,
                  hintText: 'Player Gender ...',
                ),
                const SizedBox(
                  height: 25,
                ),
                NeonTextField(
                  controller: _birthDayController,
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
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(35),
          child: GlowButton(
            glowColor: HexColor('002333').withValues(alpha: 0.15),
            color: Color.fromARGB(151, 99, 206, 255),
            onPressed: () => context.push(Routes.homePage),
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: size.width * .35,
            ),
            child: Text("Next"),
          ),
        ),
      ),
    );
  }
}
