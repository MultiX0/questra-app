import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/imports.dart';

class OnboardingBg extends ConsumerWidget {
  const OnboardingBg({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundWidget(child: child);
  }
}
