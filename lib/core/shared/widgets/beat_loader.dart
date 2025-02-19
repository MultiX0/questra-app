import 'package:questra_app/imports.dart';

class BeatLoader extends ConsumerWidget {
  final double size;
  const BeatLoader({super.key, this.size = 30});

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
