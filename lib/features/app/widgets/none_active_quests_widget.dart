import 'package:questra_app/imports.dart';
import 'package:flutter_glow/flutter_glow.dart' show GlowIcon;
import 'package:questra_app/router.dart';

class NoneActiveQuestsWidget extends ConsumerWidget {
  const NoneActiveQuestsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);

    return SystemCard(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: size.width * .15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlowIcon(
            LucideIcons.hexagon,
            size: 50,
            glowColor: HexColor('7AD5FF'),
            color: HexColor('7AD5FF'),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "You don’t have any active quests right now. Would you like to embark on a new quest?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              backgroundColor: HexColor("7AD5FF").withValues(alpha: .35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: HexColor('7AD5FF'),
                ),
              ),
              foregroundColor: AppColors.whiteColor,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              ref.read(navigationShellProvider).goBranch(1);
            },
            child: Text("Details"),
          )
        ],
      ),
    );
  }
}
