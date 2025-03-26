import 'package:questra_app/core/shared/widgets/quest_card.dart';
import 'package:questra_app/imports.dart';

class CustomQuestsPage extends ConsumerStatefulWidget {
  const CustomQuestsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomQuestsPageState();
}

class _CustomQuestsPageState extends ConsumerState<CustomQuestsPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authStateProvider)?.id ?? "";
      ref.invalidate(getCustomQuestsProvider(userId));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final customQuests = ref.watch(customQuestsProvider);
    return BackgroundWidget(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary.withValues(alpha: .5),
          elevation: 3,
          child: Icon(LucideIcons.plus),
          onPressed: () {
            ref.read(soundEffectsServiceProvider).playSystemButtonClick();
            context.push(Routes.addCustomQuestPage);
          },
        ),
        appBar: TheAppBar(title: AppLocalizations.of(context).profile_custom_quests),
        body: ref
            .watch(getCustomQuestsProvider(user!.id))
            .when(
              data: (quests) {
                if (quests.isEmpty) {
                  return buildEmptyTitels();
                }

                return ListView.builder(
                  itemCount: customQuests.length,
                  itemBuilder: (context, i) {
                    final _quest = customQuests[i];
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: QuestCard(
                        special: true,
                        questModel: _quest,
                        onTap: () {
                          ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                          Navs(context, ref).viewQuest(_quest, true);
                        },
                      ),
                    );
                  },
                );
              },
              error: (error, _) => Center(child: ErrorWidget(error)),
              loading: () => BeatLoader(),
            ),
      ),
    );
  }

  Widget buildEmptyTitels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: SizedBox(
          child: SystemCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.hexagon, color: AppColors.primary, size: 40),
                const SizedBox(height: 15),
                Text(
                  AppLocalizations.of(context).empty_quests,
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: AppColors.descriptionColor,
                    fontFamily: AppFonts.header,
                    fontSize: 16,
                  ),
                ),
                // const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
