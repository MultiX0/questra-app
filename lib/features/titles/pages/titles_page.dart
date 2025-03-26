import 'dart:developer';

import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/titles/controller/titles_controller.dart';
import 'package:questra_app/imports.dart';

import '../models/player_title_model.dart';

class TitlesPage extends ConsumerStatefulWidget {
  const TitlesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TitlesPageState();
}

class _TitlesPageState extends ConsumerState<TitlesPage> {
  bool refreshLoading = false;

  void changeSheet(String userId, String titleId) {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();

    openSheet(
      context: context,
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    shrinkWrap: true,
                    children: [
                      Icon(LucideIcons.hexagon, color: AppColors.primary, size: 40),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context).titles_change_title_message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SystemCardButton(
                      onTap: () {
                        context.pop();
                        ref
                            .read(titlesControllerProvider.notifier)
                            .handleTitleChange(userId: userId, id: titleId);
                      },
                      text: AppLocalizations.of(context).yes,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SystemCardButton(
                      onTap: () => context.pop(),
                      text: AppLocalizations.of(context).cancel.toLowerCase(),
                      doneButton: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final isLoading = ref.watch(titlesControllerProvider);
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).profile_titles),
        body:
            isLoading
                ? BeatLoader()
                : ref
                    .watch(getAllTitlesProvider(user!.id))
                    .when(
                      data: (titles) {
                        if (titles.isEmpty) {
                          return Center(child: buildEmptyTitels(user.id));
                        }

                        return buildTitles(titles);
                      },
                      error: (error, _) => Center(child: Text(error.toString())),
                      loading: () => BeatLoader(),
                    ),
      ),
    );
  }

  Widget buildTitles(List<PlayerTitleModel> titles) {
    final user = ref.watch(authStateProvider);
    log("${user?.activeTitleId}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 2),
      child: AppRefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800), () {
            ref.invalidate(getAllTitlesProvider(user!.id));
          });
        },
        child: ListView.builder(
          itemCount: titles.length,
          itemBuilder: (context, i) {
            final title = titles[i];
            final isActive = title.id == user?.activeTitleId;
            final color =
                isActive ? AppColors.primary : AppColors.descriptionColor.withValues(alpha: .7);

            return ListTile(
              onTap: () => changeSheet(user!.id, title.id),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title.title,
                          style: TextStyle(fontWeight: FontWeight.w600, color: color),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => changeSheet(user!.id, title.id),
                        icon: Icon(LucideIcons.crown, color: color),
                      ),
                    ],
                  ),
                  Text(
                    "${AppLocalizations.of(context).owned_at} ${appDateFormat(title.owned_at)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.descriptionColor.withValues(alpha: .5),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              subtitle: Divider(
                height: 0,
                color: AppColors.descriptionColor.withValues(alpha: .15),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildEmptyTitels(String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        child: SystemCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.hexagon, color: AppColors.primary, size: 40),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context).titles_empty,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  color: AppColors.descriptionColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              if (refreshLoading) ...[
                BeatLoader(),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    backgroundColor: HexColor("7AD5FF").withValues(alpha: .35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: HexColor('7AD5FF')),
                    ),
                    foregroundColor: AppColors.whiteColor,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                    setState(() {
                      refreshLoading = true;
                    });
                    await Future.delayed(const Duration(milliseconds: 800));
                    ref.invalidate(getAllTitlesProvider(userId));

                    await Future.delayed(const Duration(milliseconds: 1500), () {
                      setState(() {
                        refreshLoading = false;
                      });
                    });
                  },
                  child: Text(AppLocalizations.of(context).titles_empty_refresh),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
