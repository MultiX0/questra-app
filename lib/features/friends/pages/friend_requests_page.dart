import 'package:cached_network_image/cached_network_image.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/friends/providers/friends_requests_provider.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/friends/repository/friends_repository.dart';
import 'package:questra_app/imports.dart';

class FriendRequestsPage extends ConsumerStatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends ConsumerState<FriendRequestsPage> {
  final ScrollController _scrollController = ScrollController();
  bool fetched = false;
  int requestsCount = 0;
  bool btnLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!fetched) {
        fetchData();
      }
      _scrollController.addListener(_onScroll);
    });
    super.initState();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(friendsRequestsProvider.notifier).fetchItems();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more when we're 200 pixels from the bottom
    return currentScroll >= (maxScroll - 200);
  }

  void fetchData() async {
    final me = ref.read(authStateProvider)!;

    ref.read(friendsRequestsProvider.notifier).fetchItems();
    final _count = await ref.read(friendsRepositoryProvider).getFriendRequestsCount(me.id);
    setState(() {
      fetched = true;
      requestsCount = _count;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void refresh(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800), () async {
      ref.read(friendsRequestsProvider.notifier).refresh();
      final _count = await ref.read(friendsRepositoryProvider).getFriendRequestsCount(userId);
      if (requestsCount != _count) {
        setState(() {
          requestsCount = _count;
        });
      }
      setState(() {
        btnLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authStateProvider)!;
    final state = ref.watch(friendsRequestsProvider);
    // final isLoading = ref.watch(friendsControllerProvider);
    // final me = ref.watch(authStateProvider);

    return AppRefreshIndicator(
      child:
          state.users.isEmpty && state.isLoading
              ? BeatLoader()
              : state.hasError
              ? buildError(state)
              : state.users.isEmpty
              ? buildEmptyState(me.id)
              : buildBody(state, me.id),
      onRefresh: () async => refresh(me.id),
    );
  }

  Widget buildEmptyState(String userId) => Center(
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
                AppLocalizations.of(context).no_friend_requests,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
              if (btnLoading)
                BeatLoader()
              else
                MainAppButton(
                  onTap: () {
                    setState(() {
                      btnLoading = true;
                    });
                    refresh(userId);
                  },
                  title: AppLocalizations.of(context).refresh,
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget buildBody(FriendRequestsState state, String userId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).total_friend_requests_count,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  requestsCount.toString(),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.users.length + (state.isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == state.users.length) {
                  return const Center(
                    child: Padding(padding: EdgeInsets.all(8.0), child: BeatLoader()),
                  );
                }
                final user = state.users[i];
                return buildPlayerCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding buildPlayerCard(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SystemCard(
        onTap: () {
          ref.read(soundEffectsServiceProvider).playSystemButtonClick();
          ref.read(selectedFriendProvider.notifier).state = user;

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
            buildActions(user.id),
          ],
        ),
      ),
    );
  }

  void handleAction(bool accept, String userId) async {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    if (accept) {
      ref.read(friendsRequestsProvider.notifier).acceptFriend(userId);
      return;
    }
    ref.read(friendsRequestsProvider.notifier).declineFriend(userId);
  }

  Widget buildActions(String userId) {
    final isLoading = ref.watch(friendsRequestsProvider).loadingActionsUsers.contains(userId);
    return !isLoading
        ? Row(
          children: [
            buildActionButton(
              icon: LucideIcons.plus,
              onTap: () => handleAction(true, userId),
              color: Colors.green.shade300,
            ),
            const SizedBox(width: 15),
            buildActionButton(
              icon: LucideIcons.minus,
              onTap: () => handleAction(false, userId),
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

  Center buildError(FriendRequestsState state) =>
      Center(child: Text('Error: ${state.errorMessage}'));
}
