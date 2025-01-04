import 'dart:developer';

import 'package:questra_app/features/onboarding/pages/user_data_page.dart';
import 'package:questra_app/features/onboarding/pages/user_preferences_page.dart';
import 'package:questra_app/imports.dart';

class OnboardingController extends ConsumerStatefulWidget {
  const OnboardingController({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingControllerState();
}

class _OnboardingControllerState extends ConsumerState<OnboardingController> {
  late PageController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  void next() {
    log("next");
    setState(() {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void prevs() {
    setState(() {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: NeverScrollableScrollPhysics(),
      children: [
        UserDataPage(
          next: next,
        ),
        UserPreferencesPage(
          next: next,
          prev: prevs,
        ),
      ],
    );
  }
}
