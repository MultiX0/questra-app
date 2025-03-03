import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/events/providers/players_registered_provider.dart';
import 'package:questra_app/features/events/providers/providers.dart';
import 'package:questra_app/features/events/repository/events_repository.dart';
import 'package:questra_app/imports.dart';

class PlayerRegisteredToEvent extends ConsumerStatefulWidget {
  const PlayerRegisteredToEvent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerRegisteredToEventState();
}

class _PlayerRegisteredToEventState extends ConsumerState<PlayerRegisteredToEvent> {
  final ScrollController _scrollController = ScrollController();
  int playersCount = 0;
  bool fetched = false;

  @override
  void initState() {
    super.initState();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!fetched) {
        getPlayersCount();
        ref.read(paginatedItemsProvider.notifier).fetchItems();
      }
    });

    // Add scroll listener for lazy loading
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(paginatedItemsProvider.notifier).fetchItems();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more when we're 200 pixels from the bottom
    return currentScroll >= (maxScroll - 200);
  }

  void getPlayersCount() async {
    log("player counting...");
    final eventId = ref.read(selectedQuestEvent)!.id;
    final count = await ref.read(eventsRepositoryProvider).getEventPlayersCount(eventId);
    setState(() {
      playersCount = count;
      fetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedItemsProvider);

    return AppRefreshIndicator(
      onRefresh: () async {
        ref.read(paginatedItemsProvider.notifier).refresh();
        await Future.delayed(const Duration(milliseconds: 400), () {
          getPlayersCount();
        });
      },
      child:
          state.users.isEmpty && state.isLoading
              ? const Center(child: BeatLoader())
              : state.hasError
              ? Center(child: Text('Error: ${state.errorMessage}'))
              : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.users.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${AppLocalizations.of(context).total_participants}:"),
                            GlowText(
                              text: playersCount.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: AppFonts.primary,
                              ),
                              glowColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.users.length + (state.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.users.length) {
                            return const Center(
                              child: Padding(padding: EdgeInsets.all(8.0), child: BeatLoader()),
                            );
                          }

                          final user = state.users[index];
                          return ListTile(
                            onTap: () {
                              ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                              ref.read(selectedEventPlayer.notifier).state = user;
                              Navs(context, ref).goToEventPlayerQuestCompletionPage(user.id);
                            },
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary.withValues(alpha: .25),
                                      backgroundImage: CachedNetworkImageProvider(user.avatar!),
                                      radius: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: [
                                        Text(user.name, style: TextStyle(color: AppColors.primary)),
                                        Text(
                                          "@${user.username}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.descriptionColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Divider(color: AppColors.descriptionColor.withValues(alpha: 0.25)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
