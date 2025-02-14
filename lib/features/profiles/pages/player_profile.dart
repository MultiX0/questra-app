import 'package:flutter/foundation.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/features/app/widgets/user_dashboard_widget.dart';
import 'package:questra_app/features/profiles/widgets/dashboard_grid.dart';
import 'package:questra_app/imports.dart';

class PlayerProfile extends ConsumerStatefulWidget {
  final String userId;
  final bool isMe;
  const PlayerProfile({
    super.key,
    required this.userId,
    this.isMe = false,
  });

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
          title: "Profile",
          actions: [
            if (kDebugMode) ...[
              IconButton(
                onPressed: () => ref.read(authStateProvider.notifier).logout(),
                icon: Icon(LucideIcons.log_out),
              ),
            ],
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: buildUserBody(isMe),
        ),
      ),
    );
  }

  Widget buildUserBody(bool isMe) {
    if (isMe) {
      return buildMe();
    }
    return const SizedBox();
  }

  ListView buildMe() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      children: [
        UserDashboardWidget(duration: Duration(milliseconds: 800)),
        const SizedBox(
          height: 15,
        ),
        BuildDashboardGrid(),
        const SizedBox(height: 15),
        buildGuildCard(),
        const SizedBox(height: 15),
        buildFriendsCard(),
      ],
    );
  }

  SystemCard buildGuildCard() {
    return SystemCard(
      duration: const Duration(milliseconds: 1200),
      onTap: soon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.building_2),
          const SizedBox(height: 10),
          Text("Guild"),
        ],
      ),
    );
  }

  SystemCard buildFriendsCard() {
    return SystemCard(
      duration: const Duration(milliseconds: 1500),
      onTap: soon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.users),
          const SizedBox(height: 10),
          Text("Friends"),
        ],
      ),
    );
  }

  void soon() {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    CustomToast.soon();
  }
}
