import 'package:questra_app/imports.dart';
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
                vertical: size.width * .35,
                horizontal: 15,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GlowText(
                    text: "Level Up Your Life!",
                    glowColor: HexColor('7AD5FF'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GlowButton(
                    glowColor: HexColor('002333').withValues(alpha: 0.15),
                    color: Color.fromARGB(151, 99, 206, 255),
                    child: Text("Arise!"),
                    onPressed: () {},
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
// ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color.fromARGB(151, 99, 206, 255),
//         textStyle: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 18,
//         ),
//         padding: EdgeInsets.symmetric(
//           vertical: 20,
//           horizontal: size.width * .35,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         foregroundColor: AppColors.whiteColor,
//       ),
//       onPressed: () {},
//       child: Text(
//         "Arise!",
//       ),
//     );
