import 'package:flutter_glow/flutter_glow.dart' show GlowIcon;
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/quests/widgets/loading_events_card.dart';
import 'package:questra_app/features/shared_quests/controller/shared_quests_controller.dart';
import 'package:questra_app/features/shared_quests/widgets/shared_quest_card.dart';
import 'package:questra_app/imports.dart';

class SharedQuestsPage extends ConsumerStatefulWidget {
  const SharedQuestsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SharedQuestsPageState();
}

class _SharedQuestsPageState extends ConsumerState<SharedQuestsPage> {
  Future<void> refresh() async {
    final visitedUser = ref.watch(selectedFriendProvider)!;
    final sharedQuestsRef = getAllSharedQuestsProvider(visitedUser.id);
    await Future.delayed(const Duration(milliseconds: 800), () {
      ref.invalidate(sharedQuestsRef);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visitedUser = ref.watch(selectedFriendProvider)!;
    final sharedQuestsRef = ref.watch(getAllSharedQuestsProvider(visitedUser.id));

    return BackgroundWidget(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(Routes.addSharedQuestPage),
          backgroundColor: AppColors.primary.withValues(alpha: .5),
          elevation: 3,

          child: GlowIcon(LucideIcons.plus, glowColor: AppColors.primary),
        ),
        appBar: TheAppBar(title: AppLocalizations.of(context).shared_quests),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: sharedQuestsRef.when(
            data: (quests) {
              if (quests.isEmpty) {
                return buildEmptyState();
              }
              return AppRefreshIndicator(
                onRefresh: refresh,
                child: ListView.builder(
                  itemCount: quests.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return buildRequestsCard();
                    }
                    final quest = quests.elementAt(i - 1);
                    return SharedQuestCard(quest: quest);
                  },
                ),
              );
            },
            error: (error, _) => Center(child: ErrorWidget(error)),
            loading:
                () => ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, i) {
                    return LoadingQuestsCard();
                  },
                ),
          ),
        ),
      ),
    );
  }

  Widget buildRequestsCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SystemCard(
        onTap: () {
          ref.read(soundEffectsServiceProvider).playSystemButtonClick();
          context.push(Routes.questRequestsPage);
        },
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        isButton: true,
        child: Row(
          children: [
            Icon(LucideIcons.hexagon),
            const SizedBox(width: 15),
            Text(
              AppLocalizations.of(context).quest_requests,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return AppRefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: buildRequestsCard()),
          SliverFillRemaining(hasScrollBody: false, child: Center()),
        ],
      ),
    );
  }
}
