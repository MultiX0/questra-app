import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/events/controller/events_controller.dart';
import 'package:questra_app/features/quests/widgets/active_quests_page.dart';
import 'package:questra_app/features/quests/widgets/custom_quest_empty_widget.dart';
import 'package:questra_app/features/quests/widgets/events_caruosel.dart';
import 'package:questra_app/features/quests/widgets/loading_events_card.dart';
import 'package:questra_app/features/quests/widgets/new_quests_system_card.dart';
import 'package:questra_app/features/quests/widgets/quests_archive.dart';
import 'package:questra_app/imports.dart';

class QuestsPage extends ConsumerStatefulWidget {
  const QuestsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuestsPageState();
}

class _QuestsPageState extends ConsumerState<QuestsPage> {
  @override
  Widget build(BuildContext context) {
    final activeQuests = ref.watch(currentOngointQuestsProvider) ?? [];
    final size = MediaQuery.sizeOf(context);
    final user = ref.watch(authStateProvider);

    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).quests),
        body: RefreshIndicator(
          color: AppColors.whiteColor,
          backgroundColor: AppColors.primary.withValues(alpha: 0.5),
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300), () async {
              final quests = await ref
                  .read(questsRepositoryProvider)
                  .currentlyOngoingQuests(user!.id);
              ref.read(currentOngointQuestsProvider.notifier).state = quests;
              ref.invalidate(getQuestEventsProvider);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ListView(
              children: [
                buildEventsCarousel(),
                const SizedBox(height: 20),
                if (activeQuests.isEmpty) ...[
                  NewQuestsSystemCard(),
                ] else ...[
                  ActiveQuestsCarousel(quests: activeQuests),
                ],
                const SizedBox(height: 20),
                buildCustomQuests(user),
                SizedBox(height: size.height * 0.075),
                Center(
                  child: GlowText(
                    text: AppLocalizations.of(context).quests_archive,
                    spreadRadius: 0.5,
                    blurRadius: 20,
                    glowColor: AppColors.whiteColor,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      // fontFamily: AppFonts.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                QuestsArchiveWidget(),
                SizedBox(height: size.height * 0.025),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEventsCarousel() {
    return ref
        .watch(getQuestEventsProvider)
        .when(
          data: (events) {
            return EventsCaruosel(events: events);
            // return LoadingQuestsCard();
          },
          error: (error, _) => const SizedBox.shrink(),
          loading: () => LoadingQuestsCard(),
        );
  }

  Column buildCustomQuests(UserModel? user) {
    final customQuests = ref.watch(customQuestsProvider);

    return Column(
      children: [
        ref
            .watch(getCustomQuestsProvider(user!.id))
            .when(
              data: (quests) {
                if (customQuests.isNotEmpty) {
                  return ActiveQuestsCarousel(quests: customQuests, special: true);
                }
                return CustomQuestEmptyWidget();
              },
              error: (error, _) => Center(child: ErrorWidget(error)),
              loading: () => LoadingQuestsCard(),
            ),
      ],
    );
  }
}
