import 'package:cached_network_image/cached_network_image.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
import 'package:questra_app/features/friends/repository/friends_repository.dart';
import 'package:questra_app/imports.dart';

class FriendsPage extends ConsumerStatefulWidget {
  final String userId;
  const FriendsPage({super.key, required this.userId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => FriendsPageState();
}

class FriendsPageState extends ConsumerState<FriendsPage> {
  final ScrollController _scrollController = ScrollController();
  bool fetched = false;
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
      ref.read(friendsStateProvider.notifier).fetchItems(userId: widget.userId);
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
    ref.read(friendsStateProvider.notifier).fetchItems(userId: widget.userId);
    final _count = await ref.read(friendsRepositoryProvider).getFriendsCount(widget.userId);
    setState(() {
      fetched = true;
    });
    ref.read(getUserLengthProvider.notifier).state = _count;
  }

  void refresh() async {
    await Future.delayed(const Duration(milliseconds: 800), () async {
      ref.read(friendsStateProvider.notifier).refresh(widget.userId);
      final _count = await ref.read(friendsRepositoryProvider).getFriendsCount(widget.userId);
      final friendsCount = ref.read(getUserLengthProvider);

      if (friendsCount != _count) {
        ref.read(getUserLengthProvider.notifier).state = _count;
      }
      setState(() {
        btnLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendsStateProvider);
    // final friendsCount = ref.watch(getUserLengthProvider);

    // final me = ref.watch(authStateProvider);

    return AppRefreshIndicator(
      child:
          state.users.isEmpty && state.isLoading
              ? BeatLoader()
              : state.hasError
              ? buildError(state)
              : state.users.isEmpty
              ? buildEmptyState()
              : buildBody(state),
      onRefresh: () async => refresh(),
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
                AppLocalizations.of(context).no_friends,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
              if (btnLoading) ...[
                BeatLoader(),
              ] else ...[
                MainAppButton(
                  onTap: () {
                    setState(() {
                      btnLoading = true;
                    });
                    refresh();
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
  Widget buildBody(FriendsState state) {
    final friendsCount = ref.watch(getUserLengthProvider);

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
                  AppLocalizations.of(context).total_friends_count,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  friendsCount.toString(),
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
                final user = state.users.elementAt(i);
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SystemCard(
                    onTap: () {
                      ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                      ref.read(selectedFriendProvider.notifier).state = user;
                      context.push("${Routes.player}/${user.id}");
                    },
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            user.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(user.username, style: TextStyle(fontSize: 16)),

                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                            backgroundImage: CachedNetworkImageProvider(user.avatar!),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Center buildError(FriendsState state) => Center(child: Text('Error: ${state.errorMessage}'));
}
