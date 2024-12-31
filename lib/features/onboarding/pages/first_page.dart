import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/constants/app_fonts.dart';
import 'package:questra_app/shared/widgets/glow_button.dart';
import 'package:questra_app/shared/widgets/glow_text.dart';

class OnboardingFirstPage extends ConsumerWidget {
  const OnboardingFirstPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              fit: BoxFit.cover,
              Assets.getImage('onboarding_bg.png'),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      HexColor('22B2F4'),
                      Colors.black,
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
                    glowColor: HexColor('7AD5FF'),
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
                    glowColor: HexColor('002333').withValues(alpha: 0.15),
                    color: Color.fromARGB(151, 99, 206, 255),
                    onPressed: () => context.push(Routes.homePage),
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
