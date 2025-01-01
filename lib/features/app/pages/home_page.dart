import 'package:flutter_glow/flutter_glow.dart' show GlowIcon;
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/constants/app_fonts.dart';
import 'package:questra_app/shared/widgets/background_widget.dart';
import 'package:questra_app/shared/widgets/glow_text.dart';
import 'package:questra_app/shared/widgets/system_card.dart';
import 'package:questra_app/theme/app_theme.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            SizedBox(
              height: kToolbarHeight / 2,
            ),
            Center(
              child: GlowText(
                glowColor: HexColor('7AD5FF').withValues(alpha: 0.8),
                text: "Questra",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: HexColor('7AD5FF'),
                  fontFamily: AppFonts.header,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.025,
            ),
            SystemCard(
              child: Center(
                child: GlowText(
                  text: "Sun Dec 29",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: AppFonts.digitalFont,
                    color: AppColors.whiteColor,
                  ),
                  glowColor: AppColors.whiteColor,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SystemCard(
              padding: EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: HexColor('224F63'),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: HexColor('43A7D5'),
                            width: 0.75,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: HexColor('43A7D5').withValues(alpha: .5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: GlowIcon(
                            LucideIcons.user,
                            color: HexColor('43A7D5'),
                            glowColor: HexColor('43A7D5'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlowText(
                            glowColor: Colors.white,
                            text: 'Mohammed',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: AppFonts.primary,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          GlowText(
                            glowColor: Colors.white.withValues(alpha: .57),
                            text: "LvL 15",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: .57),
                              fontFamily: AppFonts.primary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GlowText(
                        glowColor: Colors.white.withValues(alpha: .57),
                        text: 'Coins: 100\$',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .57),
                          fontSize: 12,
                          fontFamily: AppFonts.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GlowText(
                    glowColor: Colors.white.withValues(alpha: .85),
                    text: "JOB: The System Developer",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: .85),
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GlowText(
                    glowColor: Colors.white.withValues(alpha: .85),
                    text: "Title: System Designer",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: .85),
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlowText(
                        glowColor: Colors.white.withValues(alpha: .85),
                        text: "Rank: #1",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: .85),
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primary,
                        ),
                      ),
                      GlowText(
                        glowColor: Colors.white.withValues(alpha: .85),
                        text: "Streak: #5",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: .85),
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Stack(
                    children: [
                      Container(
                        width: size.width,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          color: Colors.transparent,
                          border: Border.all(
                            color: HexColor('43A7D5'),
                            width: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        width: size.width * .4,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(1),
                            bottomLeft: Radius.circular(1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 1,
                              blurRadius: 8,
                              color: HexColor('7AD5FF').withValues(alpha: .3),
                            ),
                          ],
                          color: HexColor('7AD5FF'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "100/",
                        style: TextStyle(
                          fontFamily: AppFonts.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: '300',
                            style: TextStyle(
                              fontFamily: AppFonts.primary,
                              fontWeight: FontWeight.w300,
                              color: Colors.white54,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SystemCard(
              padding: EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: size.width * .15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: HexColor('43A7D5'),
                            width: 0.75,
                          ),
                        ),
                        child: Center(
                          child: GlowText(
                            glowColor: AppColors.whiteColor,
                            text: "Quest",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w200,
                              fontFamily: AppFonts.primary,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      GlowText(
                        glowColor: AppColors.whiteColor,
                        text: "Quest Title:",
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: GlowText(
                          glowColor: AppColors.whiteColor,
                          text: "Forge the Core: Build the System Backbone",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontFamily: AppFonts.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlowText(
                        glowColor: AppColors.whiteColor,
                        text: "Description:",
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          "You are tasked with building the brain of the app—an AI-powered quest system that seamlessly personalizes user challenges. Like Sung Jin-Woo, you must wield your developer tools and “arise” a robust system that adapts to every user’s journey.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: AppFonts.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  GlowText(
                    glowColor: Colors.white54,
                    text: "Reward: +500 XP, +250 Coins, “Architect of Innovation” Badge",
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: AppFonts.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
