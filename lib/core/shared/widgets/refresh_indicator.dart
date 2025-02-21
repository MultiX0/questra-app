import 'package:questra_app/imports.dart';

class AppRefreshIndicator extends ConsumerWidget {
  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.whiteColor,
      backgroundColor: AppColors.primary.withValues(alpha: 0.5),
      onRefresh: onRefresh,
      child: child,
    );
  }
}
