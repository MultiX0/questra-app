import 'dart:developer';

import 'package:questra_app/core/shared/widgets/beat_loader.dart';
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
            Center(child: buildActions(user)),
          ],
        ),
      ),
    );
  }

  Widget buildStatusText() {
    String statusText = 'Not Friend';
    Color statusColor = AppColors.whiteColor;
    final _hasActiveRequest = ref.watch(usersWithActiveRequestFromMe).contains(user);
    final isAlreadyFrined = ref.watch(friendsStateProvider).users.contains(user);
    final isRequestingMe = ref.watch(friendsRequestsProvider).users.contains(user);

    if (isAlreadyFrined) {
      statusText = "Friend";
      statusColor = Colors.green[300]!;
    }

    if (_hasActiveRequest) {
      statusText = "Pending";
      statusColor = AppColors.primary;
    }

    if (isRequestingMe) {
      statusText = "Requesting You";
      statusColor = Colors.orange[300]!;
    }

    return Text(
      statusText,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
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
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    if (accept) {
      ref.read(friendsRequestsProvider.notifier).acceptFriend(userId);
      return;
    }
    ref.read(friendsRequestsProvider.notifier).declineFriend(userId);
  }

  void handleRemoveFriend(String userId) async {
    log("friend removing...");
    ref.read(friendsControllerProvider.notifier).handleRemoveFriend(userId);
  }

  Widget buildActions(UserModel user) {
    final isUserLoading = ref.watch(friendRequestLoadingProvider(user.id));
    final _hasActiveRequest = ref.watch(usersWithActiveRequestFromMe).contains(user);
    final isAlreadyFrined = ref.watch(friendsStateProvider).users.contains(user);
    final isRequestingMe = ref.watch(friendsRequestsProvider).users.contains(user);
    return !isUserLoading
        ? _hasActiveRequest
            ?
            //  buildActionButton(
            //   icon: LucideIcons.minus,
            //   onTap: () => handleSendriendRequest(user),
            //   color: Colors.red[500]!,
            // )
            SystemCardButton(
              onTap: () => handleSendriendRequest(user),
              text: "Cancel Request",
              doneButton: false,
            )
            : isAlreadyFrined
            ? buildRemoveFriendButton(user)
            : isRequestingMe
            ? buildRequestForMe(user.id)
            : buildActionButton(
              icon: LucideIcons.user_plus,
              onTap: () => handleSendriendRequest(user),
              color: Colors.green.shade300,
            )
        : BeatLoader();
  }

  Widget buildRemoveFriendButton(UserModel user) {
    final isLoading = ref.watch(friendsControllerProvider);
    if (isLoading) return BeatLoader();
    return SystemCardButton(
      onTap: () => handleRemoveFriend(user.id),
      text: "Remove Friend",
      doneButton: false,
    );
  }

  Widget buildRequestForMe(String userId) {
    final isLoading = ref.watch(friendsRequestsProvider).loadingActionsUsers.contains(userId);
    return !isLoading
        ? Row(
          children: [
            SystemCardButton(
              onTap: () => handleRequestForMe(true, userId),
              text: "Reject",
              doneButton: false,
            ),
            SystemCardButton(
              onTap: () => handleRequestForMe(false, userId),
              text: "Accpet",
              color: Colors.green[300],
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
