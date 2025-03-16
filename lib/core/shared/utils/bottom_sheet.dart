import 'package:questra_app/imports.dart';

void openSheet({
  required BuildContext context,
  required Widget body,
  bool? isScrollControlled,
  double? elevation,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: isScrollControlled ?? false,
    elevation: elevation ?? 1.5,
    backgroundColor: AppColors.scaffoldBackground,
    barrierColor: Colors.black54,
    builder: (context) {
      return body;
    },
  );
}
