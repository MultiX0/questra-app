import 'package:flutter_glow/flutter_glow.dart';
import 'package:questra_app/imports.dart';

class CustomQuestEmptyWidget extends ConsumerWidget {
  const CustomQuestEmptyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final user = ref.watch(authStateProvider);
    return Stack(
      children: [
        SystemCard(
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
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context).custom_quest_empty,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  backgroundColor: HexColor("7AD5FF").withValues(alpha: .35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: HexColor('7AD5FF')),
                  ),
                  foregroundColor: AppColors.whiteColor,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                  context.push(Routes.customQuestsPage);
                },
                child: Text(AppLocalizations.of(context).add_quest),
              ),
            ],
          ),
        ),
        if (user!.level!.level < 5) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                CustomToast.systemToast(AppLocalizations.of(context).custom_quest_requirements);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withValues(alpha: .75),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).custom_quest_level_locked,
                    style: TextStyle(fontFamily: AppFonts.header, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
