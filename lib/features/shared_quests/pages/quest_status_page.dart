import 'package:questra_app/imports.dart';

class SharedQuestStatusPage extends ConsumerWidget {
  const SharedQuestStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundWidget(
      child: Scaffold(appBar: TheAppBar(title: AppLocalizations.of(context).shared_quest_status)),
    );
  }
}
