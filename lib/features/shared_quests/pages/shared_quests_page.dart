import 'package:flutter_glow/flutter_glow.dart' show GlowIcon;
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/quests/widgets/loading_events_card.dart';
import 'package:questra_app/features/shared_quests/controller/shared_quests_controller.dart';
import 'package:questra_app/imports.dart';

class SharedQuestsPage extends ConsumerStatefulWidget {
  const SharedQuestsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SharedQuestsPageState();
}

class _SharedQuestsPageState extends ConsumerState<SharedQuestsPage> {
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
        body: sharedQuestsRef.when(
          data: (quests) {
            if (quests.isEmpty) {
              return buildEmptyState();
            }
            return ListView.builder(itemCount: quests.length, itemBuilder: (context, i) {});
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
    );
  }

  Widget buildEmptyState() {
    return Center();
  }
}
