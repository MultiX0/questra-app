import 'package:questra_app/imports.dart';

class BeatLoader extends ConsumerWidget {
  const BeatLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: LoadingAnimationWidget.beat(
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}
