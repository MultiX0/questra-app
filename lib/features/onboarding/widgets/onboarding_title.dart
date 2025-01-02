import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/constants/app_fonts.dart';
import 'package:questra_app/shared/widgets/glow_text.dart';

class OnboardingTitle extends ConsumerWidget {
  const OnboardingTitle({
    super.key,
    this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Center(
          child: GlowText(
            textAlign: TextAlign.center,
            text: title ?? "Be a player now!",
            glowColor: HexColor('7AD5FF'),
            style: TextStyle(
              fontSize: 28,
              fontFamily: AppFonts.header,
              fontWeight: FontWeight.bold,
              color: HexColor('7AD5FF'),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
          ),
          child: Center(
            child: GlowText(
              text:
                  "Join the adventure! Share your details to get personalized quests and start leveling up!",
              textAlign: TextAlign.center,
              glowColor: Colors.white,
              style: TextStyle(
                fontSize: 18,
                fontFamily: AppFonts.primary,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              blurRadius: 3,
            ),
          ),
        ),
      ],
    );
  }
}
