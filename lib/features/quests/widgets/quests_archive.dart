import 'package:questra_app/features/quests/pages/quests_archive_provider.dart';
import 'package:questra_app/imports.dart';

class QuestsArchiveWidget extends ConsumerWidget {
  const QuestsArchiveWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmpty = ref.watch(isArchiveEmptyProvider);
    final archiveData = ref.watch(questArchiveProvider);
    final partData = archiveData.length < 7 ? archiveData : archiveData.getRange(0, 6).toList();
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
                "Title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // const Spacer(),
              Text(
                "Status",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (isEmpty == true) ...[
            buildEmptyState(),
          ] else if (isEmpty == false) ...[
            ...partData.asMap().entries.map((entry) {
              final i = entry.key + 1;
              final quest = entry.value;

              return buildArchiveItem(
                title: "$i - ${quest.title}",
                status: getStatusFromString(quest.status),
              );
            })
          ],
          if (isEmpty == null) ...[
            Center(
              child: LoadingAnimationWidget.beat(
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ],
          if (archiveData.length > 7) ...[
            GestureDetector(
              onTap: () {
                ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                CustomToast.soon();
              },
              child: Text(
                "view more...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.descriptionColor,
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  Padding buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.hexagon,
              color: AppColors.primary,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "There is no quests in the archive for now",
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

  Row buildArchiveItem({required String title, required StatusEnum status}) {
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
        Text(
          status.name,
          style: TextStyle(
            fontWeight: FontWeight.w200,
            color: color,
          ),
        ),
      ],
    );
  }
}
