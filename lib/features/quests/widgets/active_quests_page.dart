import 'dart:developer';

import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:questra_app/core/shared/widgets/quest_card.dart';
import 'package:questra_app/features/quests/providers/quests_providers.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/navs/navs.dart';

class ActiveQuestsCarousel extends ConsumerWidget {
  const ActiveQuestsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(currentOngointQuestsProvider) ?? [];

    log(quests.length.toString());

    if (quests.isEmpty) {
      return const SizedBox.shrink(); // Or a placeholder widget
    }

    return ExpandableCarousel.builder(
      key: ValueKey('quest-carousel-${quests.length}'),
      options: ExpandableCarouselOptions(
        autoPlay: quests.length > 1,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 1,
        autoPlayCurve: Curves.ease,
        enableInfiniteScroll: quests.length > 1,
        enlargeCenterPage: true,
        floatingIndicator: true,
        showIndicator: false,
      ),
      itemCount: quests.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        final quest = quests[itemIndex];
        return KeyedSubtree(
          key: ValueKey('quest-${quest.id}'), // Assuming quest has an id field
          child: QuestCard(
            questModel: quest,
            onTap: () => Navs(context, ref).viewQuest(quest),
          ),
        );
      },
    );
  }
}
