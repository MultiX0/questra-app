import 'package:questra_app/core/shared/utils/levels_calc.dart';
import 'package:questra_app/core/shared/utils/xp_bar_calc.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';
import 'package:flutter_glow/flutter_glow.dart' show GlowIcon;

class UserDashboardWidget extends ConsumerWidget {
  const UserDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final user = ref.watch(authStateProvider)!;
    final barSize = totalXpBarWidth(
      current: user.level?.xp.toDouble() ?? 0.0,
      max: calculateXpForLevel(user.level?.level ?? 1).toDouble(),
      width: size.width,
    );
    return SystemCard(
      duration: const Duration(seconds: 2),
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
                    text: user.name,
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
                    text: "LvL ${user.level?.level}",
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
                text: 'Coins: ${user.wallet?.balance ?? 0}\$',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .57),
                  fontSize: 12,
                  fontFamily: AppFonts.primary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 850),
                width: barSize,
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
                text: "${user.level?.xp ?? 0}/",
                style: TextStyle(
                  fontFamily: AppFonts.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: '${calculateXpForLevel(user.level?.level ?? 1)}',
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
    );
  }
}
