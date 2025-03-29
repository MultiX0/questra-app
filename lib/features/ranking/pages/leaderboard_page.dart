import 'package:cached_network_image/cached_network_image.dart';
import 'package:questra_app/features/ranking/controller/ranking_controller.dart';
import 'package:questra_app/features/ranking/providers/ranking_providers.dart';
import 'package:questra_app/imports.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  int selectedIndex = 0;
  bool btnLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final userRank = ref.watch(playerRankingProvider) ?? -1;
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).leaderboard),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 15),
              buildCategoryChange(),
              if (selectedIndex == 0) ...[
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary),
                    color: AppColors.primary.withValues(alpha: .2),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).your_rank),
                      const SizedBox(height: 10),
                      buildCard(userRank, AppColors.primary, user!, true),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 15),
              Expanded(
                child: IndexedStack(
                  index: selectedIndex,
                  children: [
                    ref
                        .watch(getAllRankingLeaderboardProvider)
                        .when(
                          data: (players) {
                            return leaderboardBody(players, user!);
                          },
                          error: (error, _) => Center(child: Text(error.toString())),
                          loading: () => BeatLoader(),
                        ),
                    ref
                        .watch(getFriendsLeaderboard)
                        .when(
                          data: (players) {
                            if (players.isEmpty) {
                              return friendsEmptyState();
                            }
                            return leaderboardBody(players, user!);
                          },
                          error: (error, _) => Center(child: Text(error.toString())),
                          loading: () => BeatLoader(),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget friendsEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        child: SystemCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.shield_alert, color: AppColors.primary, size: 45),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context).no_friends,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
              if (btnLoading) ...[
                BeatLoader(),
              ] else ...[
                MainAppButton(
                  onTap: () async {
                    setState(() {
                      btnLoading = true;
                    });
                    await Future.delayed(const Duration(milliseconds: 500), () {
                      ref.invalidate(getFriendsLeaderboard);
                    });
                  },
                  title: AppLocalizations.of(context).refresh,
                ),
                const SizedBox(height: 15),
                MainAppButton(
                  onTap: () => context.push(Routes.addFriendsPage),
                  title: AppLocalizations.of(context).add_friends_btn,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  RefreshIndicator leaderboardBody(List<UserModel> players, UserModel me) {
    return RefreshIndicator(
      color: AppColors.whiteColor,
      backgroundColor: AppColors.primary.withValues(alpha: 0.5),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 300), () {
          if (selectedIndex == 0) {
            ref.invalidate(getAllRankingLeaderboardProvider);
          } else {
            ref.invalidate(getFriendsLeaderboard);
          }
        });
      },
      child: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, i) {
          Color playerColor;
          switch (i + 1) {
            case 1:
              playerColor = AppColors.primary;
            case 2:
              playerColor = Colors.green[300]!;
            case 3:
              playerColor = Colors.blueGrey[200]!;

            default:
              playerColor = AppColors.whiteColor;
          }
          final player = players[i];
          if (player.id == me.id && selectedIndex != 1) {
            return const SizedBox();
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCard(i, playerColor, player, false),
                const SizedBox(height: 15),
                Divider(color: AppColors.descriptionColor.withValues(alpha: .15)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildCard(int i, Color playerColor, UserModel player, bool header) {
    return GestureDetector(
      onTap: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        Navs(context, ref).goPlayerProfile(player);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${header ? i : i + 1} - ",
            style: TextStyle(fontFamily: AppFonts.header, fontSize: 16, color: playerColor),
          ),
          const SizedBox(width: 15),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            backgroundImage: CachedNetworkImageProvider(player.avatar!),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: TextStyle(color: playerColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  player.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: AppColors.descriptionColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // const Spacer(),
          if (!header)
            Text(
              "LVL ${player.level?.level}\n${player.level?.xp == 0 ? "Zero " : player.level?.xp}XP",
              style: TextStyle(fontFamily: AppFonts.header, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Row buildCategoryChange() => Row(
    spacing: 10,
    children: [
      Expanded(
        child: buildCategoryCard(
          duration: const Duration(milliseconds: 300),
          index: 0,
          text: AppLocalizations.of(context).leaderboard_buttons1,
        ),
      ),
      Expanded(
        child: buildCategoryCard(
          duration: const Duration(milliseconds: 300),
          index: 1,
          text: AppLocalizations.of(context).leaderboard_buttons2,
        ),
      ),
    ],
  );

  GestureDetector buildCategoryCard({
    required Duration duration,
    required int index,
    required String text,
  }) {
    // bool isArabic = ref.watch(localeProvider).languageCode == 'ar';

    bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          color:
              isActive
                  ? Colors.purpleAccent.withValues(alpha: .15)
                  : AppColors.primary.withValues(alpha: 0.15),
          border: Border.all(color: isActive ? Colors.purpleAccent : AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Center(child: Text(text)),
      ),
    );
  }
}
