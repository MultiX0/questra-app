import 'dart:async';

import 'package:questra_app/core/providers/rewards_providers.dart';
import 'package:questra_app/core/services/device_service.dart';
import 'package:questra_app/features/app/widgets/dashboard_quest_widget.dart';
import 'package:questra_app/features/app/widgets/user_dashboard_widget.dart';
import 'package:questra_app/features/lootbox/lootbox_manager.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Timer _timer;
  @override
  void initState() {
    final user = ref.read(authStateProvider);
    handleLootBoxes(user!.id);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkDevice();
      await NotificationsRepository.insertLog(user.id);

      // ref.read(soundEffectsServiceProvider).playBackgroundMusic();
      _timer = Timer.periodic(const Duration(minutes: 10), (_) async {
        final lootBoxManager = LootBoxManager();

        bool lootBoxDropped = await lootBoxManager.checkLootBoxDrop();
        if (lootBoxDropped) {
          ref.read(hasLootBoxProvider.notifier).state = true;
        }
      });
    });
    super.initState();
  }

  void handleLootBoxes(String userId) async {
    final user = ref.read(authStateProvider);
    if (user == null) return;
    if (user.username.isEmpty) return;
    final lootBoxManager = LootBoxManager();
    bool hasUntakenLootBox = await lootBoxManager.unTakenLootBox(userId);
    if (hasUntakenLootBox) {
      ref.read(hasLootBoxProvider.notifier).state = true;
      return;
    }
  }

  void _checkDevice() {
    final user = ref.read(authStateProvider);
    DeviceService.checkDevice(user!.id);
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = const Duration(milliseconds: 800);

    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TheAppBar(title: 'Questra'),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 2),
            children: [
              const SizedBox(height: 15),
              SystemCard(
                duration: duration,
                onTap: () {
                  ref.read(soundEffectsServiceProvider).playSystemButtonClick();

                  // CustomToast.systemToast("the shop is comming soon!");
                  context.push(Routes.marketPlace);
                },
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlowText(
                      blurRadius: 20,
                      spreadRadius: 0.75,
                      glowColor: AppColors.whiteColor,
                      text: "Marketplace",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: AppFonts.header,
                        color: AppColors.whiteColor,
                      ),
                      // glowColor: AppColors.whiteColor,
                    ),
                    const SizedBox(height: 5),
                    GlowText(
                      blurRadius: 20,
                      spreadRadius: 0.5,
                      glowColor: AppColors.whiteColor,
                      text:
                          "Discover exclusive items, power-ups, and gear to level up your journey. Spend your coins and enhance your adventure!",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: AppFonts.primary,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              UserDashboardWidget(duration: const Duration(milliseconds: 1400)),
              const SizedBox(height: 15),
              DashboardQuestWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
