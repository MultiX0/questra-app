import 'dart:developer';

import 'package:questra_app/features/app/widgets/user_dashboard_widget.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/profiles/controller/profile_controller.dart';
import 'package:questra_app/features/profiles/providers/profile_providers.dart';
import 'package:questra_app/features/profiles/widgets/friendship_status_widget.dart';
import 'package:questra_app/features/profiles/widgets/shared_quests_card.dart';
import 'package:questra_app/features/profiles/widgets/user_streak_card.dart';
import 'package:questra_app/imports.dart';

class OtherProfile extends ConsumerStatefulWidget {
  const OtherProfile({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtherProfileState();
}

class _OtherProfileState extends ConsumerState<OtherProfile> {
  String userId = '';
  @override
  void initState() {
    refreshStreak();
    super.initState();
    userId = widget.userId;
  }

  void refreshStreak() async {
    final streak = await ref.read(profileRepositoryProvider).getUserStreak(widget.userId);
    ref.read(selectedProfileStreak.notifier).state = streak;
  }

  @override
  Widget build(BuildContext context) {
    log(userId);
    final _user = ref.watch(selectedFriendProvider)!;
    final isAlreadyFrined = ref.watch(friendsStateProvider).users.contains(_user);
    final userStreak = ref.watch(selectedProfileStreak);

    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).profile),
        body: ref
            .watch(getUserProfileProvider(userId))
            .when(
              data: (user) {
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: ListView(
                    children: [
                      UserDashboardWidget(user: user, duration: const Duration(seconds: 1)),
                      UserStreakCard(userStreak: userStreak),
                      FriendshipStatusWidget(user: _user),
                      if (isAlreadyFrined) SharedQuestsCard(),
                    ],
                  ),
                );
              },
              error: (e, _) => Center(child: ErrorWidget(e)),
              loading: () => BeatLoader(),
            ),
      ),
    );
  }
}
