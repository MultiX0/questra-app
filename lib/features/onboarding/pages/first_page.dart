// ignore_for_file: use_build_context_synchronously

import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';

class OnboardingFirstPage extends ConsumerWidget {
  const OnboardingFirstPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);

    void handleLogin() async {
      await ref.read(authStateProvider.notifier).googleSignIn();
    }

    return OnboardingBg(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.getImage('splash_icon.png'),
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 30,
              ),
              GlowText(
                text: "Level Up Your Life!",
                textAlign: TextAlign.center,
                glowColor: HexColor('7AD5FF'),
                spreadRadius: .75,
                blurRadius: 30,
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: AppFonts.header,
                  fontWeight: FontWeight.bold,
                  color: HexColor('7AD5FF'),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              GlowText(
                text: "Embark on your personalized\nquest journey now",
                textAlign: TextAlign.center,
                glowColor: Colors.white,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppFonts.primary,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                blurRadius: 3,
              ),
              const SizedBox(
                height: 35,
              ),
              GlowButton(
                spreadRadius: 1.5,
                blurRadius: 20,
                glowColor: HexColor('7AD5FF').withValues(alpha: 0.4),
                color: Color.fromARGB(151, 99, 206, 255),
                onPressed: handleLogin,
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: size.width * .35,
                ),
                child: Text("Level up!"),
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
