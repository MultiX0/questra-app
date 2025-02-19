import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/quests/widgets/active_quests_page.dart';
import 'package:questra_app/features/quests/widgets/custom_quest_empty_widget.dart';
import 'package:questra_app/features/quests/widgets/new_quests_system_card.dart';
import 'package:questra_app/features/quests/widgets/quests_archive.dart';
import 'package:questra_app/imports.dart';

import '../repository/quests_repository.dart';

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
        appBar: TheAppBar(
          title: "Quests",
        ),
        body: RefreshIndicator(
          color: AppColors.whiteColor,
          backgroundColor: AppColors.primary.withValues(alpha: 0.5),
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300), () async {
              final quests =
                  await ref.read(questsRepositoryProvider).currentlyOngoingQuests(user!.id);
              ref.read(currentOngointQuestsProvider.notifier).state = quests;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ListView(
              children: [
                const SizedBox(
                  height: 15,
                ),
                if (activeQuests.isEmpty) ...[
                  NewQuestsSystemCard(),
                ] else ...[
                  ActiveQuestsCarousel(quests: activeQuests),
                ],
                const SizedBox(height: 20),
                buildCustomQuests(user),
                SizedBox(
                  height: size.height * 0.075,
                ),
                Center(
                  child: GlowText(
                    text: "Quests Archive",
                    spreadRadius: 0.5,
                    blurRadius: 20,
                    glowColor: AppColors.whiteColor,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontFamily: AppFonts.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                QuestsArchiveWidget(),
                SizedBox(
                  height: size.height * 0.025,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column buildCustomQuests(UserModel? user) {
    final customQuests = ref.watch(customQuestsProvider);

    return Column(
      children: [
        ref.watch(getCustomQuestsProvider(user!.id)).when(
              data: (quests) {
                if (customQuests.isNotEmpty) {
                  return ActiveQuestsCarousel(
                    quests: customQuests,
                    special: true,
                  );
                }
                return CustomQuestEmptyWidget();
              },
              error: (error, _) => Center(
                child: ErrorWidget(error),
              ),
              loading: () => SystemCard(
                child: BeatLoader(),
              ),
            ),
      ],
    );
  }
}
