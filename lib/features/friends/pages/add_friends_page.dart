import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:questra_app/core/shared/utils/debounce.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/friends/controller/friends_controller.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
import 'package:questra_app/features/friends/providers/friends_requests_provider.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/imports.dart';

class AddFriendsPage extends ConsumerStatefulWidget {
  const AddFriendsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends ConsumerState<AddFriendsPage> {
  late TextEditingController _controller;
  final Debouncer<String> _debouncer = Debouncer<String>(duration: Duration(milliseconds: 500));
  String query = '';

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String val) {
    _debouncer.call(val);
    _debouncer.action = (val2) {
      setState(() {
        query = val2;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).add_friends_btn),
        body: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: buildField(context)),
            const SizedBox(height: 25),
            Expanded(
              child: ref
                  .watch(searchPlayers(query))
                  .when(
                    data: (players) {
                      if (players.isEmpty) {
                        return buildEmptyState();
                      }
                      return ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, i) {
                          final player = players[i];
                          return buildPlayerCard(player);
                        },
                      );
                    },
                    error: (e, _) => Center(child: ErrorWidget(e)),
                    loading: () => BeatLoader(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  TextField buildField(BuildContext context) {
    return TextField(
      controller: _controller,
      cursorColor: AppColors.primary,

      decoration: InputDecoration(
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
        hintText: AppLocalizations.of(context).add_friends_search_hint,
        labelText: AppLocalizations.of(context).search,
        hintStyle: TextStyle(fontSize: 13),
        filled: true,
        fillColor: Colors.black.withValues(alpha: .25),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp("[^0-9a-z_]"))],
      onChanged: (value) => _search(value.trim()),
    );
  }

  Padding buildPlayerCard(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: SystemCard(
        onTap: () {
          ref.read(soundEffectsServiceProvider).playSystemButtonClick();
          context.push("${Routes.player}/${user.id}");
        },
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(user.username, style: TextStyle(fontSize: 16)),

                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                  backgroundImage: CachedNetworkImageProvider(user.avatar!),
                ),
              ),
            ),
            buildActions(user),
          ],
        ),
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
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    if (accept) {
      ref.read(friendsRequestsProvider.notifier).acceptFriend(userId);
      return;
    }
    ref.read(friendsRequestsProvider.notifier).declineFriend(userId);
  }

  Widget buildActions(UserModel user) {
    final isUserLoading = ref.watch(friendRequestLoadingProvider(user.id));
    final _hasActiveRequest = ref.watch(usersWithActiveRequestFromMe).contains(user);

    final isAlreadyFrined = ref.watch(friendsStateProvider).users.contains(user);
    final isRequestingMe = ref.watch(friendsRequestsProvider).users.contains(user);
    return !isUserLoading
        ? _hasActiveRequest
            ? buildActionButton(
              icon: LucideIcons.minus,
              onTap: () => handleSendriendRequest(user),
              color: Colors.red[500]!,
            )
            : isAlreadyFrined
            ? buildFriendBadge()
            : isRequestingMe
            ? buildRequestForMe(user.id)
            : buildActionButton(
              icon: LucideIcons.user_plus,
              onTap: () => handleSendriendRequest(user),
              color: Colors.green.shade300,
            )
        : BeatLoader();
  }

  Widget buildFriendBadge() {
    return SystemCard(
      isButton: true,
      borderRadius: 4,
      onTap: () => ref.read(soundEffectsServiceProvider).playSystemButtonClick(),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Center(
        child: Text(
          AppLocalizations.of(context).already_friend,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget buildRequestForMe(String userId) {
    final isLoading = ref.watch(friendsRequestsProvider).loadingActionsUsers.contains(userId);
    return !isLoading
        ? Row(
          children: [
            buildActionButton(
              icon: LucideIcons.plus,
              onTap: () => handleRequestForMe(true, userId),
              color: Colors.green.shade300,
            ),
            const SizedBox(width: 15),
            buildActionButton(
              icon: LucideIcons.minus,
              onTap: () => handleRequestForMe(false, userId),
              color: Colors.red.shade600,
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

  Widget buildEmptyState() => Center(
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
                AppLocalizations.of(context).add_friends_empty_state,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    ),
  );
}
