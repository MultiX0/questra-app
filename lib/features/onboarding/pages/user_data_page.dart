import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_bg.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_title.dart';
import 'package:questra_app/features/onboarding/widgets/select_gender_widget.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/utils/bottom_sheet.dart';

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

  String gender = '';

  final _key = GlobalKey<FormState>();

  void change(v) {
    setState(() {
      gender = v;
      _genderController.text = v == 'm' ? "Male" : "Female";
    });
    context.pop();
    genderFocusNode.unfocus();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _birthDayController = TextEditingController();
    _genderController = TextEditingController();
    _activityController = TextEditingController();
    genderFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDayController.dispose();
    _genderController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  void genderSheet() {
    openSheet(
      context: context,
      body: SelectGenderWidget(
        changeVal: (v) => change(v),
        group: gender,
      ),
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
                    // onTap: genderSheet,
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
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(35),
          child: GlowButton(
            glowColor: HexColor('002333').withValues(alpha: 0.15),
            color: Color.fromARGB(151, 99, 206, 255),
            onPressed: () => context.push(Routes.homePage),
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: size.width * .35,
            ),
            child: Text("Next"),
          ),
        ),
      ),
    );
  }
}
