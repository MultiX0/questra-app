import 'package:flutter_glow/flutter_glow.dart';
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/shared_quests/controller/shared_quests_controller.dart';
import 'package:questra_app/features/shared_quests/models/request_model.dart';
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
    ref.invalidate(getAllSharedRequestsFromUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final requestsRef = ref.watch(getAllSharedRequestsFromUserProvider);
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).quest_requests),
        body: requestsRef.when(
          data: (requests) {
            if (requests.isEmpty) {
              return buildEmptyState();
            }

            return AppRefreshIndicator(
              onRefresh: refresh,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, i) {
                    final request = requests[i];
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
                            request.content,
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
            );
          },
          error: (e, _) => Center(child: ErrorWidget(e)),
          loading: () => BeatLoader(),
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

  Widget buildEmptyState() {
    return AppRefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(slivers: [SliverFillRemaining()]),
    );
  }
}
