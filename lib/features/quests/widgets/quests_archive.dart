import 'package:questra_app/features/quests/pages/quests_archive_provider.dart';
import 'package:questra_app/imports.dart';

class QuestsArchiveWidget extends ConsumerWidget {
  const QuestsArchiveWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmpty = ref.watch(isArchiveEmptyProvider);
    final archiveData = ref.watch(questArchiveProvider);
    final partData = archiveData.length < 7 ? archiveData : archiveData.getRange(0, 6).toList();
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    return SystemCard(
      padding: EdgeInsets.all(15),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textDirection: textDirection,
              ),
              // const Spacer(),
              Text(
                AppLocalizations.of(context).quest_status,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textDirection: textDirection,
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (isEmpty == true) ...[
            buildEmptyState(context),
          ] else if (isEmpty == false) ...[
            ...partData.asMap().entries.map((entry) {
              final i = entry.key + 1;
              final quest = entry.value;

              return buildArchiveItem(
                title: "$i - ${isArabic ? quest.ar_title ?? quest.title : quest.title}",
                ref: ref,
                status: getStatusFromString(quest.status),
              );
            }),
          ],
          if (isEmpty == null) ...[
            Center(child: LoadingAnimationWidget.beat(color: AppColors.primary, size: 30)),
          ],
          if (archiveData.length > 7) ...[
            GestureDetector(
              onTap: () {
                ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                CustomToast.soon(isArabic);
              },
              child: Text(
                "${AppLocalizations.of(context).view_more}...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.descriptionColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Padding buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.hexagon, color: AppColors.primary),
            const SizedBox(height: 15),
            Text(
              AppLocalizations.of(context).empty_quest_archive,
              style: TextStyle(
                fontWeight: FontWeight.w200,
                color: AppColors.descriptionColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row buildArchiveItem({
    required String title,
    required StatusEnum status,
    required WidgetRef ref,
  }) {
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';

    String statusString = '';
    Color? color;
    switch (status) {
      case StatusEnum.completed:
        color = AppColors.primary;
        break;

      case StatusEnum.failed:
        color = HexColor('FF7A7C');
        break;

      case StatusEnum.skipped:
        color = HexColor('877AFF');
        break;

      default:
        color = Colors.grey;
        break;
    }

    switch (status) {
      case StatusEnum.completed:
        statusString = isArabic ? "مكتمل" : StatusEnum.completed.name;
        break;

      case StatusEnum.failed:
        statusString = isArabic ? "لم تنجح" : StatusEnum.completed.name;

        break;

      case StatusEnum.skipped:
        statusString = isArabic ? "تم التخطي" : StatusEnum.completed.name;

        break;

      default:
        statusString = isArabic ? "غير معروف" : StatusEnum.completed.name;

        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w200))),
        Text(statusString, style: TextStyle(fontWeight: FontWeight.w200, color: color)),
      ],
    );
  }
}
