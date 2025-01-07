import 'dart:async';

import 'package:questra_app/core/shared/constants/app_fonts.dart';
import 'package:questra_app/features/onboarding/widgets/onboarding_bg.dart';
import 'package:questra_app/imports.dart';

class SetupAccountPage extends ConsumerStatefulWidget {
  const SetupAccountPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends ConsumerState<SetupAccountPage> {
  late Timer _timer;
  late Timer _opacityTimer;

  double opacity = 1;

  @override
  void initState() {
    _opacityTimer = Timer.periodic(
      const Duration(milliseconds: 600),
      (_) {
        setState(() {
          if (opacity == 1) {
            opacity = 0;
          } else {
            opacity = 1;
          }
        });
      },
    );
    _timer = Timer(
      const Duration(seconds: 2),
      () {
        context.go(Routes.homePage);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _opacityTimer.cancel();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return OnboardingBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.width * .15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: opacity,
                  child: Image.asset(
                    Assets.getImage('app_logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: AppFonts.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                  text: 'settings up ',
                  children: [
                    TextSpan(
                      text: 'your ',
                      style: TextStyle(
                        color: HexColor('7AD5FF'),
                      ),
                    ),
                    TextSpan(text: 'account'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
