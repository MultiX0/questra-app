import 'dart:developer';

import 'package:questra_app/features/friends/controller/friends_controller.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
import 'package:questra_app/features/friends/providers/friends_requests_provider.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/imports.dart';

class FriendshipStatusWidget extends ConsumerStatefulWidget {
  const FriendshipStatusWidget({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendshipStatusWidgetState();
}

class _FriendshipStatusWidgetState extends ConsumerState<FriendshipStatusWidget> {
  UserModel get user => widget.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SystemCard(
        duration: const Duration(milliseconds: 1600),
        padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.users),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).friendship_status,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    buildStatusText(),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(padding: const EdgeInsets.only(top: 15), child: buildActions(user)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusText() {
    String statusText = AppLocalizations.of(context).notFriend;
    Color statusColor = AppColors.whiteColor;
    final _hasActiveRequest = ref.watch(usersWithActiveRequestFromMe).contains(user);
    final isAlreadyFrined = ref.watch(friendsStateProvider).users.contains(user);
    final isRequestingMe = ref.watch(friendsRequestsProvider).users.contains(user);

    if (isAlreadyFrined) {
      statusText = AppLocalizations.of(context).friend;
      statusColor = Colors.green[300]!;
    } else if (_hasActiveRequest) {
      statusText = AppLocalizations.of(context).pending;
      statusColor = AppColors.primary;
    } else if (isRequestingMe) {
      statusText = AppLocalizations.of(context).requestingYou;
      statusColor = Colors.orange[300]!;
    } else {
      statusColor = AppColors.descriptionColor.withValues(alpha: .75);
    }

    return Text(
      statusText,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
    );
  }

  void removeFriendSheet(String userId) {
    // ref.read(soundEffectsServiceProvider).playSystemButtonClick();

    openSheet(
      context: context,
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    shrinkWrap: true,
                    children: [
                      Icon(LucideIcons.hexagon, color: AppColors.primary, size: 40),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context).remove_friend_alert,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SystemCardButton(
                      onTap: () {
                        context.pop();
                        log("friend removing...");
                        ref.read(friendsControllerProvider.notifier).handleRemoveFriend(userId);
                      },
                      text: AppLocalizations.of(context).yes,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SystemCardButton(
                      onTap: () => context.pop(),
                      text: AppLocalizations.of(context).cancel.toLowerCase(),
                      doneButton: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  void handleSendriendRequest(UserModel user) async {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    ref.read(friendsControllerProvider.notifier).handleRequests(reciver: user);
  }

  void handleCancelFriendRequest(String userId) async {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
  }

  void handleRequestForMe(bool accept, String userId) {
    // ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    if (accept) {
      ref.read(friendsRequestsProvider.notifier).acceptFriend(userId);
      return;
    }
    ref.read(friendsRequestsProvider.notifier).declineFriend(userId);
  }

  void handleRemoveFriend(String userId) async {
    removeFriendSheet(userId);
  }

  Widget buildActions(UserModel user) {
    final isUserLoading = ref.watch(friendRequestLoadingProvider(user.id));
    final _hasActiveRequest = ref.watch(usersWithActiveRequestFromMe).contains(user);
    final isAlreadyFrined = ref.watch(friendsStateProvider).users.contains(user);
    final isRequestingMe = ref.watch(friendsRequestsProvider).users.contains(user);
    if (!isUserLoading) {
      if (isAlreadyFrined) {
        return buildRemoveFriendButton(user);
      } else {
        if (_hasActiveRequest) {
          return SystemCardButton(
            onTap: () => handleSendriendRequest(user),
            text: AppLocalizations.of(context).cancelRequest,
            doneButton: false,
          );
        } else {
          if (isAlreadyFrined) {
            return buildRemoveFriendButton(user);
          } else {
            if (isRequestingMe) {
              return buildRequestForMe(user.id);
            } else {
              return buildActionButton(
                icon: LucideIcons.user_plus,
                onTap: () => handleSendriendRequest(user),
                color: Colors.green.shade300,
              );
            }
          }
        }
      }
    } else {
      return BeatLoader();
    }
  }

  Widget buildRemoveFriendButton(UserModel user) {
    final isLoading = ref.watch(friendsControllerProvider);
    if (isLoading) return BeatLoader();
    return SystemCardButton(
      onTap: () => handleRemoveFriend(user.id),
      text: AppLocalizations.of(context).removeFriend,
      doneButton: false,
    );
  }

  Widget buildRequestForMe(String userId) {
    final isLoading = ref.watch(friendsRequestsProvider).loadingActionsUsers.contains(userId);
    return !isLoading
        ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SystemCardButton(
              onTap: () => handleRequestForMe(true, userId),
              text: AppLocalizations.of(context).accept,
              color: Colors.green[300],
            ),
            const SizedBox(width: 50),
            SystemCardButton(
              onTap: () => handleRequestForMe(false, userId),
              text: AppLocalizations.of(context).reject,
              doneButton: false,
            ),
          ],
        )
        : BeatLoader();
  }

  SystemCard buildActionButton({
    required IconData icon,
    required Function() onTap,
    required Color color,
  }) {
    return SystemCard(
      color: color,
      isButton: true,
      onTap: onTap,
      padding: EdgeInsets.all(8),
      child: Center(child: Icon(icon)),
    );
  }
}
