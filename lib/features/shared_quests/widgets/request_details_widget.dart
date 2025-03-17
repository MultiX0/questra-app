import 'package:questra_app/features/shared_quests/controller/shared_quests_controller.dart';
import 'package:questra_app/features/shared_quests/models/request_model.dart';
import 'package:questra_app/imports.dart';

class RequestDetailsWidget extends ConsumerWidget {
  const RequestDetailsWidget({super.key, required this.request, required this.reOpen});

  final RequestModel request;
  final Function(bool) reOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(sharedQuestsControllerProvider.notifier);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    void check(bool isAccept) {
      context.pop();
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
                          isAccept
                              ? AppLocalizations.of(context).quest_accept_confirmation
                              : AppLocalizations.of(context).quest_reject_confirmation,
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
                          controller.handleRequest(
                            id: request.requestId,
                            isAccpeted: isAccept,
                            senderId: request.senderId,
                            context: context,
                          );
                        },
                        text: AppLocalizations.of(context).yes,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: SystemCardButton(
                        onTap: () {
                          context.pop();
                          reOpen(true);
                        },
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

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).details,
                    style: TextStyle(fontSize: 18, color: AppColors.primary),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        AppLocalizations.of(context).description,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isArabic ? request.arContent : request.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "· · ─ ·𖥸· ─ · ·",
                        style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 12,
                          color: AppColors.descriptionColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        AppLocalizations.of(
                          context,
                        ).request_deadline_text(appDateFormat(request.deadLine)),
                        style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 12,
                          color: AppColors.descriptionColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "· · ─ ·𖥸· ─ · ·",
                        style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 12,
                          color: AppColors.descriptionColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context).request_type_title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        request.firstCompleteWin
                            ? AppLocalizations.of(context).request_type_1
                            : AppLocalizations.of(context).request_type_2,
                        style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              // SliverFloatingHeader(child: Text("data")),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SystemCardButton(
                onTap: () => check(true),
                text: AppLocalizations.of(context).accept,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SystemCardButton(
                onTap: () => check(false),
                text: AppLocalizations.of(context).reject,
                doneButton: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
