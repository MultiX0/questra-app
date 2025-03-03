// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:questra_app/features/ads/ads_service.dart';
import 'package:questra_app/features/quests/ai/ai_functions.dart';
import 'package:questra_app/imports.dart';

class NewQuestsSystemCard extends ConsumerStatefulWidget {
  const NewQuestsSystemCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewQuestsSystemCardState();
}

class _NewQuestsSystemCardState extends ConsumerState<NewQuestsSystemCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 15),
          Text(
            AppLocalizations.of(context).empty_quests,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (isLoading) ...[
            Center(child: LoadingAnimationWidget.beat(color: AppColors.primary, size: 30)),
          ] else ...[
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
                setState(() {
                  isLoading = true;
                });
                if (!kDebugMode) {
                  await ref.read(adsServiceProvider.notifier).showAd();
                }
                CustomToast.systemToast(
                  "${AppLocalizations.of(context).quest_generation_toast}...",
                  systemMessage: true,
                );
                await ref.read(aiFunctionsProvider).generateQuests();
                await ref.read(aiFunctionsProvider).generateQuests();
                if (!mounted) return;
                setState(() {
                  isLoading = false;
                });
              },
              child: Text(AppLocalizations.of(context).add_quest),
            ),
          ],
        ],
      ),
    );
  }
}
