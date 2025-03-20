import 'dart:developer';

import 'package:questra_app/features/shared_quests/providers/shared_quests_provider.dart';
import 'package:questra_app/features/shared_quests/repository/shared_quests_repository.dart';
import 'package:questra_app/imports.dart';

class SharedQuestsMiddleware extends ConsumerStatefulWidget {
  const SharedQuestsMiddleware({super.key, required this.questId});
  final int questId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SharedQuestsMiddlewareState();
}

class _SharedQuestsMiddlewareState extends ConsumerState<SharedQuestsMiddleware> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => checkQuestState());
    super.initState();
  }

  Future<void> checkQuestState() async {
    try {
      final me = ref.read(authStateProvider)!;
      final now = DateTime.now();
      final quest = await getQuestById(widget.questId);
      ref.read(selectedSharedQuestProvider.notifier).state = quest;
      if (!mounted) return;
      if (quest.playersCompleted.isNotEmpty) {
        if (quest.playersCompleted.contains(me.id) ||
            quest.request!.deadLine.isBefore(now) ||
            quest.request!.firstCompleteWin) {
          context.pushReplacement(Routes.sharedQuestStatusPage);
          return;
        }

        context.pushReplacement(Routes.sharedQuestViewPage);
        return;
      } else {
        context.pushReplacement(Routes.sharedQuestViewPage);
        return;
      }
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(e.toString(), systemMessage: true);
      context.pop();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(child: BeatLoader());
  }
}
