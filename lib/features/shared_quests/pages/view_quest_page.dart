import 'package:questra_app/imports.dart';

class SharedQuestViewPage extends ConsumerStatefulWidget {
  const SharedQuestViewPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewQuestPageState();
}

class _ViewQuestPageState extends ConsumerState<SharedQuestViewPage> {
  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Scaffold(appBar: TheAppBar(title: AppLocalizations.of(context).view_quest)),
    );
  }
}
