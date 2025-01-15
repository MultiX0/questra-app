import 'package:questra_app/imports.dart';

class SystemCardButton extends StatelessWidget {
  const SystemCardButton({
    super.key,
    this.isCenter = true,
    this.doneButton = true,
    required this.onTap,
    this.text = "done",
  });

  final String? text;
  final bool? doneButton;
  final Function() onTap;
  final bool? isCenter;

  @override
  Widget build(BuildContext context) {
    if (isCenter != null && isCenter == false) {
      return buildText();
    }

    return Center(
      child: buildText(),
    );
  }

  GestureDetector buildText() {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        "[ $text ]",
        style: TextStyle(
          fontSize: 16,
          color: doneButton == false ? AppColors.redColor : AppColors.primary,
        ),
      ),
    );
  }
}
