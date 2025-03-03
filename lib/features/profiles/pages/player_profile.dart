import 'package:flutter/foundation.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/features/app/widgets/user_dashboard_widget.dart';
import 'package:questra_app/features/profiles/widgets/dashboard_grid.dart';
import 'package:questra_app/imports.dart';

class PlayerProfile extends ConsumerStatefulWidget {
  final String userId;
  final bool isMe;
  const PlayerProfile({super.key, required this.userId, this.isMe = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerProfileState();
}

class _PlayerProfileState extends ConsumerState<PlayerProfile> {
  @override
  Widget build(BuildContext context) {
    bool isMe;
    if (widget.isMe) {
      isMe = true;
    } else {
      isMe = false;
    }

    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(
          title: AppLocalizations.of(context).profile,
          actions: [
            IconButton(
              onPressed: () {
                ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                Navs(context, ref).goToAboutUs();
              },
              icon: Icon(LucideIcons.badge_info),
            ),
            if (kDebugMode) ...[
              IconButton(
                onPressed: () => ref.read(authStateProvider.notifier).logout(),
                icon: Icon(LucideIcons.log_out),
              ),
            ],
          ],
        ),
        body: Padding(padding: const EdgeInsets.only(top: 5), child: buildUserBody(isMe)),
      ),
    );
  }

  Widget buildUserBody(bool isMe) {
    if (isMe) {
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: buildMe());
    }
    return const SizedBox();
  }

  ListView buildMe() {
    return ListView(
      children: [
        const SizedBox(height: 10),
        UserDashboardWidget(duration: Duration(milliseconds: 800), profilePage: true),
        const SizedBox(height: 15),
        BuildDashboardGrid(),
        const SizedBox(height: 15),
        buildSpecialQuestsCard(),
        const SizedBox(height: 15),
        buildGuildCard(),
        const SizedBox(height: 15),
        buildFriendsCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  SystemCard buildSpecialQuestsCard() {
    final user = ref.watch(authStateProvider);
    return SystemCard(
      duration: const Duration(milliseconds: 1200),
      onTap: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        if (user!.level!.level < 5) {
          CustomToast.systemToast(AppLocalizations.of(context).custom_quest_level_locked);
          return;
        }

        context.push(Routes.customQuestsPage);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.diamond),
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context).profile_custom_quests),
        ],
      ),
    );
  }

  SystemCard buildGuildCard() {
    return SystemCard(
      duration: const Duration(milliseconds: 1500),
      onTap: soon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.building_2),
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context).profile_guild),
        ],
      ),
    );
  }

  SystemCard buildFriendsCard() {
    return SystemCard(
      duration: const Duration(milliseconds: 1700),
      onTap: soon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.users),
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context).profile_friends),
        ],
      ),
    );
  }

  void soon() {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    CustomToast.soon(isArabic);
  }
}
