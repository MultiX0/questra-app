import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:questra_app/core/shared/utils/debounce.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/friends/controller/friends_controller.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
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
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Search"),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp("[^0-9a-z_]"))],
              onChanged: (value) => _search(value.trim()),
            ),
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

  Padding buildPlayerCard(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SystemCard(
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
            buildActions(user.id),
          ],
        ),
      ),
    );
  }

  void handleAddFriend(String userId) async {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
  }

  void handleCancelFriendRequest(String userId) async {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
  }

  Widget buildActions(String userId) {
    final isLoading = ref.watch(friendsControllerProvider);
    final _hasActiveRequest = ref
        .watch(usersWithActiveRequestFromMe)
        .any((user) => user.id == userId);

    final isAlreadyFrined = ref.watch(friendsStateProvider).users.any((user) => user.id == userId);
    return !isLoading
        ? _hasActiveRequest
            ? buildActionButton(
              icon: LucideIcons.minus,
              onTap: () => handleCancelFriendRequest(userId),
              color: Colors.red[500]!,
            )
            : isAlreadyFrined
            ? const SizedBox.shrink()
            : buildActionButton(
              icon: LucideIcons.user_plus,
              onTap: () => handleAddFriend(userId),
              color: Colors.green.shade300,
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

  Widget buildEmptyState() {
    return Center();
  }
}
