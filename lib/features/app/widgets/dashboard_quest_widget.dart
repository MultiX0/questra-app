import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';

class DashboardQuestWidget extends StatelessWidget {
  const DashboardQuestWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SystemCard(
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
            height: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                height: 5,
              ),
              Text(
                // glowColor: AppColors.whiteColor,
                "Forge the Core: Build the System Backbone",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontFamily: AppFonts.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          Column(
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
                height: 5,
              ),
              Text(
                "You are tasked with building the brain of the app—an AI-powered quest system that seamlessly personalizes user challenges. Like Sung Jin-Woo, you must wield your developer tools and “arise” a robust system that adapts to every user’s journey.",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: AppFonts.primary,
                  fontSize: 13,
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
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
