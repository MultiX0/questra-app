import 'package:flutter_glow/flutter_glow.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:questra_app/features/ads/ads_service.dart';
import 'package:questra_app/features/quests/ai/ai_functions.dart';
import 'package:questra_app/imports.dart';

class NewQuestsSystemCard extends ConsumerWidget {
  const NewQuestsSystemCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isLoading = ref.watch(adsServiceProvider);

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
          if (isLoading) ...[
            Center(
              child: LoadingAnimationWidget.beat(
                color: AppColors.primary,
                size: 30,
              ),
            )
          ] else ...[
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
              onPressed: () async {
                await ref.read(adsServiceProvider.notifier).showAd();
                CustomToast.systemToast("making new quest for you...", systemMessage: true);
                await ref.read(aiFunctionsProvider).generateQuests();
                await ref.read(aiFunctionsProvider).generateQuests();
              },
              child: Text("new quests"),
            ),
          ],
        ],
      ),
    );
  }
}
