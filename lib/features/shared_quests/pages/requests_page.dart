import 'package:flutter_glow/flutter_glow.dart';
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/shared_quests/models/request_model.dart';
import 'package:questra_app/features/shared_quests/providers/quest_requests_provider.dart';
import 'package:questra_app/features/shared_quests/widgets/request_details_widget.dart';
import 'package:questra_app/imports.dart';

class SharedQuestRequestsPage extends ConsumerStatefulWidget {
  const SharedQuestRequestsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SharedQuestRequestsStatePage();
}

class SharedQuestRequestsStatePage extends ConsumerState<SharedQuestRequestsPage> {
  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    ref.read(questRequestsProvider.notifier).getAllRequests();
    setState(() {
      btnLoading = false;
    });
  }

  bool btnLoading = false;

  @override
  Widget build(BuildContext context) {
    final middleware = ref.watch(questRequestsProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).quest_requests),
        body:
            middleware.isLoading
                ? BeatLoader()
                : (middleware.requests.isEmpty)
                ? buildEmptyState()
                : AppRefreshIndicator(
                  onRefresh: refresh,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: ListView.builder(
                      itemCount: middleware.requests.length,
                      itemBuilder: (context, i) {
                        final request = middleware.requests.elementAt(i);
                        return SystemCard(
                          onTap: () => detailsSheet(request),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).description,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  GlowIcon(
                                    LucideIcons.hexagon,
                                    color: AppColors.primary,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isArabic ? request.arContent : request.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontSize: 13,

                                  color: AppColors.descriptionColor,
                                ),
                              ),

                              const SizedBox(height: 10),
                              Text(
                                "· · ─ ·𖥸· ─ · ·\n${AppLocalizations.of(context).sent_at(appDateFormat(request.sentAt))}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontSize: 11,
                                  color: AppColors.descriptionColor,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Center(
                                child: Text(
                                  "[ ${AppLocalizations.of(context).see_details} ]",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
      ),
    );
  }

  void detailsSheet(RequestModel request, {bool? reOpen}) {
    if (reOpen != true) ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    openSheet(
      elevation: 5,
      context: context,
      body: RequestDetailsWidget(
        request: request,
        reOpen: (_reOpen) => detailsSheet(request, reOpen: _reOpen),
      ),
    );
  }

  Widget buildEmptyState() => AppRefreshIndicator(
    onRefresh: refresh,
    child: CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
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
                        AppLocalizations.of(context).quest_requests_empty_state,
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
                            refresh();
                          },
                          title: AppLocalizations.of(context).refresh,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
