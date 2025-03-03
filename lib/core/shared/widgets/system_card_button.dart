import 'package:questra_app/imports.dart';

class SystemCardButton extends ConsumerWidget {
  const SystemCardButton({
    super.key,
    this.isCenter = true,
    this.doneButton = true,
    required this.onTap,
    this.text,
    this.defaultSound = true,
  });

  final String? text;
  final bool? doneButton;
  final Function() onTap;
  final bool? isCenter;
  final bool defaultSound;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isCenter != null && isCenter == false) {
      return buildText(ref, context);
    }

    return Center(child: buildText(ref, context));
  }

  GestureDetector buildText(WidgetRef ref, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (defaultSound) {
          ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        }

        onTap();
      },
      child: Text(
        "[ ${text ?? AppLocalizations.of(context).done} ]",
        style: TextStyle(
          fontSize: 16,
          color: doneButton == false ? AppColors.redColor : AppColors.primary,
        ),
      ),
    );
  }
}
