import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:questra_app/core/shared/widgets/quest_card.dart';
import 'package:questra_app/features/quests/models/quest_model.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/navs/navs.dart';

class ActiveQuestsCarousel extends ConsumerWidget {
  const ActiveQuestsCarousel({
    super.key,
    required this.quests,
  });

  final List<QuestModel> quests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = quests.length;

    return ExpandableCarousel.builder(
      options: ExpandableCarouselOptions(
        autoPlay: length > 1 ? true : false,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        // aspectRatio: 1,
        viewportFraction: 1,
        // enlargeFactor: 0.8,
        autoPlayCurve: Curves.ease,
        enableInfiniteScroll: length > 1 ? true : false,
        enlargeCenterPage: true,
        floatingIndicator: true,
        showIndicator: false,
      ),
      itemCount: quests.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        final quest = quests[itemIndex];
        return QuestCard(
          questModel: quest,
          onTap: () {
            Navs(context, ref).viewQuest(quest);
          },
        );
      },
    );
  }
}
