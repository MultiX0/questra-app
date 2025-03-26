// ignore_for_file: deprecated_member_use

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/core/shared/widgets/refresh_indicator.dart';
import 'package:questra_app/features/events/controller/events_controller.dart';
import 'package:questra_app/features/events/models/view_quest_model.dart';
import 'package:questra_app/features/events/providers/providers.dart';
import 'package:questra_app/features/quests/widgets/loading_events_card.dart';
import 'package:questra_app/imports.dart';

class SubmissionViewWidget extends ConsumerStatefulWidget {
  const SubmissionViewWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SubmissionViewWidgetState();
}

class _SubmissionViewWidgetState extends ConsumerState<SubmissionViewWidget> {
  Map<String, dynamic> group = {};
  int _finishLogsId = 0;
  bool refresh = false;

  List<Map<String, dynamic>> get reportReasons => [
    // "False completion claim",
    // "Unrelated proof image",
    // "Cheating or unfair play",
    // "Inappropriate content",
    // "Spam or fake quest",
    // "Harassment or abuse",
    {'key': "False completion claim", 'value': AppLocalizations.of(context).false_completion_claim},
    {'key': "Unrelated proof image", 'value': AppLocalizations.of(context).unrelated_proof_image},
    {
      'key': "Cheating or unfair play",
      'value': AppLocalizations.of(context).cheating_or_unfair_play,
    },
    {'key': "Inappropriate content", 'value': AppLocalizations.of(context).inappropriate_content},
    {'key': "Spam or fake quest", 'value': AppLocalizations.of(context).spam_or_fake_quest},
    {'key': "Harassment or abuse", 'value': AppLocalizations.of(context).harassment_or_abuse},
  ];

  void selectReportType() {
    openSheet(
      context: context,
      body: SelectRadioWidget(
        changeVal: (v) {
          setState(() {
            group = v;
          });
          context.pop();
        },
        group: group,
        choices: reportReasons,
        title: AppLocalizations.of(context).report_quest,
      ),
    );
  }

  void report() async {
    if (_finishLogsId == 0 || group.isEmpty) {
      CustomToast.systemToast(appError);
      return;
    }
    await ref
        .read(eventsControllerProvider.notifier)
        .insertQuestReport(reason: group['key'], finishLogId: _finishLogsId);

    setState(() {
      group = {};
    });
  }

  bool get isArabic => ref.watch(localeProvider).languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(selectedEventPlayer)!;

    void showImages(List images) {
      ref.read(soundEffectsServiceProvider).playSystemButtonClick();

      if (images.length == 1) {
        final imageProvider = CachedNetworkImageProvider(images.first);
        showImageViewer(
          context,
          imageProvider,
          onViewerDismissed: () {},
          useSafeArea: true,
          closeButtonColor: Colors.black,
          doubleTapZoomable: true,
        );
      } else {
        MultiImageProvider multiImageProvider = MultiImageProvider(
          images.map((image) => CachedNetworkImageProvider(image)).toList(),
        );

        showImageViewerPager(
          context,
          multiImageProvider,
          useSafeArea: true,
          onPageChanged: (page) {},
          onViewerDismissed: (page) {},
          closeButtonColor: Colors.black,
          doubleTapZoomable: true,
        );
      }
    }

    return IndexedStack(
      index: group.isNotEmpty ? 1 : 0,
      children: [
        Column(
          children: [
            buildUserCard(user),
            Expanded(
              child: ref
                  .watch(getPlyaerQuestSubmissionProvider(user.id))
                  .when(
                    data: (submissions) {
                      if (submissions.isEmpty) {
                        return buildEmptyState();
                      }

                      return AppRefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(const Duration(milliseconds: 800), () {
                            ref.invalidate(getPlyaerQuestSubmissionProvider(user.id));
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ListView.builder(
                            itemCount: submissions.length,
                            itemBuilder: (context, i) {
                              final submission = submissions[i];
                              return buildImageCard(submission, showImages);
                            },
                          ),
                        ),
                      );
                    },
                    error: (error, _) => Center(child: ErrorWidget(error)),
                    loading:
                        () => ListView.builder(
                          itemCount: 4,
                          itemBuilder: (context, i) => LoadingQuestsCard(),
                        ),
                  ),
            ),
          ],
        ),
        buildReportCard(),
      ],
    );
  }

  Widget buildImageCard(
    ViewEventQuestModel submission,
    void Function(List<dynamic> images) showImages,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            buildPopMenu(submission.finishLogId),
            Flexible(child: Text(submission.questDescription)),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          // "submitted at ${appDateFormat(submission.submittedAt)}",
          AppLocalizations.of(context).submitted_at(appDateFormat(submission.submittedAt)),
          style: TextStyle(fontSize: 12, color: AppColors.descriptionColor),
        ),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: () => showImages(submission.images ?? []),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(
                    image: CachedNetworkImageProvider(submission.images!.first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (submission.images!.length > 1) ...[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withValues(alpha: .7),
                    ),
                    child: Center(
                      child: Text(
                        "+${submission.images!.length - 1}",
                        style: TextStyle(
                          fontFamily: isArabic ? null : AppFonts.header,
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Divider(color: AppColors.descriptionColor.withValues(alpha: 0.15)),
      ],
    ).fadeInDown();
  }

  Widget buildUserCard(UserModel user) {
    return ListTile(
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
                    style: TextStyle(fontSize: 12, color: AppColors.descriptionColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Divider(color: AppColors.descriptionColor.withValues(alpha: 0.15)),
        ],
      ),
    ).fadeInUp();
  }

  Widget buildEmptyState() {
    final user = ref.watch(selectedEventPlayer)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.hexagon, color: AppColors.primary, size: 120, fill: 0.1).swing(),
            const SizedBox(height: 10),
            GlowText(
              text: AppLocalizations.of(context).nothing_here,
              glowColor: AppColors.primary,
              style: TextStyle(
                fontFamily: isArabic ? null : AppFonts.header,
                color: AppColors.primary,
                fontSize: 24,
              ),
            ).tada(),
            const SizedBox(height: 15),
            Text(
              AppLocalizations.of(context).no_mission_completed,
              textAlign: TextAlign.center,
            ).fadeInDown(duration: const Duration(milliseconds: 600)),
            const SizedBox(height: 20),
            if (refresh)
              BeatLoader()
            else
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
                  setState(() {
                    refresh = true;
                  });
                  await Future.delayed(const Duration(milliseconds: 800), () {
                    ref.invalidate(getPlyaerQuestSubmissionProvider(user.id));
                  });
                  setState(() {
                    refresh = false;
                  });
                },
                child: Text(AppLocalizations.of(context).refresh),
              ).swing(),
          ],
        ),
      ),
    );
  }

  Widget buildPopMenu(int finishLogsId) {
    return MenuAnchor(
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              ref.read(soundEffectsServiceProvider).playSystemButtonClick();
              controller.open();
            }
          },
          icon: const Icon(LucideIcons.info),
          tooltip: AppLocalizations.of(context).show_menu,
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            ref.read(soundEffectsServiceProvider).playSystemButtonClick();
            setState(() {
              _finishLogsId = finishLogsId;
            });
            selectReportType();
          },
          child: Text(AppLocalizations.of(context).report),
        ),
      ],
    );
  }

  Widget buildReportCard() {
    final isLoading = ref.watch(eventsControllerProvider);
    return Center(
      child: SystemCard(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).confirm_report,
              style: TextStyle(
                fontFamily: isArabic ? null : AppFonts.header,
                color: AppColors.primary,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              textAlign: TextAlign.center,
              AppLocalizations.of(context).report_confirmation_message,
              style: TextStyle(color: AppColors.descriptionColor),
            ),
            const SizedBox(height: 25),
            if (isLoading) ...[
              BeatLoader(),
            ] else ...[
              SystemCardButton(
                onTap: report,
                text: AppLocalizations.of(context).confirm_and_report,
              ),
              const SizedBox(height: 15),

              SystemCardButton(
                onTap: () {
                  setState(() {
                    group = {};
                  });
                },
                text: AppLocalizations.of(context).cancel,
                doneButton: false,
              ),
            ],

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
