import 'dart:async';
import 'dart:developer';

import 'package:questra_app/core/providers/rewards_providers.dart';
import 'package:questra_app/core/services/device_service.dart';
import 'package:questra_app/core/shared/utils/notifications_subs.dart';
import 'package:questra_app/features/app/widgets/daily_quests_card.dart';
import 'package:questra_app/features/app/widgets/dashboard_quest_widget.dart';
// import 'package:questra_app/features/app/widgets/dashboard_quest_widget.dart';
import 'package:questra_app/features/app/widgets/user_dashboard_widget.dart';
import 'package:questra_app/features/daily_quests/providers/daily_quest_state.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
import 'package:questra_app/features/friends/providers/friends_requests_provider.dart';
import 'package:questra_app/features/lootbox/lootbox_manager.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:questra_app/imports.dart';
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
    handleFCMInsert(user.id);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkDevice();
      await NotificationsRepository.insertLog(user.id);
      handleStartUp(user.id);

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

  void handleStartUp(String userId) {
    ref.read(dailyQuestStateProvider);
    ref.read(friendsStateProvider);
    ref.read(friendsStateProvider.notifier).fetchItems(userId: userId);
    ref.read(friendsRequestsProvider.notifier).fetchItems();
  }

  void handleFCMInsert(String userId) async {
    try {
      await NotificationsRepository.insertFCMToken(userId);
    } catch (e) {
      log("Error in handleFCMInsert: ${e.toString()}");
      rethrow;
    }
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

  void changeLang() async {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    final currentLang = ref.read(localeProvider).languageCode;
    Locale newLang;
    if (currentLang == 'ar') {
      newLang = Locale('en');
      fcmUnSubscribe('ar');
      fcmSubscribe('en');
    } else {
      newLang = Locale('ar');
      fcmUnSubscribe('en');
      fcmSubscribe('ar');
    }
    final user = ref.read(authStateProvider);
    ref.read(localeProvider.notifier).state = newLang;
    await ref
        .read(profileRepositoryProvider)
        .updateAccountLang(userId: user!.id, lang: newLang.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final duration = const Duration(milliseconds: 800);
    final me = ref.watch(authStateProvider);

    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TheAppBar(
          title: AppLocalizations.of(context).appTitle,
          actions: [IconButton(onPressed: changeLang, icon: Icon(LucideIcons.languages))],
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 2),
            children: [
              const SizedBox(height: 5),
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
                      glowColor: AppColors.whiteColor,
                      text: AppLocalizations.of(context).marketplace_title,
                      style: TextStyle(
                        fontSize: 20,
                        // fontFamily: AppFonts.header,
                        color: AppColors.whiteColor,
                      ),
                      // glowColor: AppColors.whiteColor,
                    ),
                    const SizedBox(height: 5),
                    GlowText(
                      glowColor: AppColors.whiteColor,
                      text: AppLocalizations.of(context).marketplace_subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        // fontFamily: AppFonts.primary,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              UserDashboardWidget(duration: const Duration(milliseconds: 1400), user: me!),
              const SizedBox(height: 15),
              DailyQuestsCard(
                title: AppLocalizations.of(context).daily_quest,
                descirption: AppLocalizations.of(context).daily_quest_hint,
                icon: LucideIcons.hexagon,
                onTap: () => context.push(Routes.dailyQuestsPage),
              ),
              const SizedBox(height: 15),
              DashboardQuestWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
