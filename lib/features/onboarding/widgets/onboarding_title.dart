import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';

class OnboardingTitle extends ConsumerWidget {
  const OnboardingTitle({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Center(
          child: GlowText(
            text: title ?? AppLocalizations.of(context).on_boarding_title,
            glowColor: HexColor('7AD5FF'),
            blurRadius: 25,
            spreadRadius: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontFamily: AppFonts.header,
              fontWeight: FontWeight.bold,
              color: HexColor('7AD5FF'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Center(
            child: GlowText(
              text: AppLocalizations.of(context).on_boarding_subtitle,
              textAlign: TextAlign.center,
              glowColor: Colors.white,
              spreadRadius: 1,
              style: TextStyle(
                fontSize: 15,
                fontFamily: AppFonts.primary,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              blurRadius: 20,
            ),
          ),
        ),
      ],
    );
  }
}
