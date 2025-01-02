import 'package:questra_app/imports.dart';

class OnboardingBg extends ConsumerWidget {
  const OnboardingBg({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
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
        child,
      ],
    );
  }
}
