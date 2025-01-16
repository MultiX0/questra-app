import 'package:questra_app/imports.dart';

class QuestsArchiveWidget extends StatelessWidget {
  const QuestsArchiveWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
          buildArchiveItem(
            title: "1 - Build the System Backbone",
            status: StatusEnum.completed,
          ),
          buildArchiveItem(
            title: "2 - Code Crunch",
            status: StatusEnum.skipped,
          ),
          buildArchiveItem(
            title: "3 - Productivity Boost",
            status: StatusEnum.failed,
          ),
        ],
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
