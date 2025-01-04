import 'package:questra_app/imports.dart';

void openSheet({
  required BuildContext context,
  required Widget body,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.scaffoldBackground,
    barrierColor: Colors.black54,
    builder: (context) {
      return body;
    },
  );
}
