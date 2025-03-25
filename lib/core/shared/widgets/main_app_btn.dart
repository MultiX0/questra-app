import 'package:questra_app/imports.dart';

class MainAppButton extends ConsumerWidget {
  const MainAppButton({super.key, required this.onTap, required this.title});

  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        backgroundColor: AppColors.primary.withValues(alpha: .35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.primary),
        ),
        foregroundColor: AppColors.whiteColor,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        onTap();
      },
      child: Text(title),
    );
  }
}
