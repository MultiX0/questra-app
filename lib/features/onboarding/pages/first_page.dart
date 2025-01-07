// ignore_for_file: use_build_context_synchronously

import 'package:questra_app/core/providers/supabase_provider.dart';
import 'package:questra_app/features/auth/repository/auth_repository.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/constants/app_fonts.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';

class OnboardingFirstPage extends ConsumerWidget {
  const OnboardingFirstPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final size = MediaQuery.sizeOf(context);

    void handleLogin() async {
      final logged = await ref.read(authStateProvider.notifier).googleSignIn();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                fit: BoxFit.cover,
                Assets.getImage('onboarding_bg.png'),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      HexColor('22B2F4'),
                      HexColor('14688E'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * .15,
                horizontal: 15,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                    child: Text("Arise!"),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -5,
            left: 0,
            right: 0,
            child: Image.asset(
              fit: BoxFit.cover,
              width: size.width * 2,
              height: 528,
              Assets.getImage('jinwoo.png'),
            ),
          ),
        ],
      ),
    );
  }
}
