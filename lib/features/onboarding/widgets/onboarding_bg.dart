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
          child: Image.asset(
            fit: BoxFit.cover,
            Assets.getImage('onboarding_bg.png'),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.85,
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
        child,
      ],
    );
  }
}
