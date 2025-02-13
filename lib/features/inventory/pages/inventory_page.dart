import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/features/inventory/controller/inventory_controller.dart';
import 'package:questra_app/imports.dart';

import '../../marketplace/models/item_model.dart';
import '../../marketplace/widgets/item_card_loading.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: "Inventory"),
        body: ref.watch(getAllInventoryProvider(user!.id)).when(
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Text("no items"),
                );
              }
              return AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 900),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        // horizontalOffset: 20,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: i != 0 ? 15 : 0, bottom: i >= (items.length - 1) ? 30 : 0),
                            child: buildCard(item.item!),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            error: (e, _) => Center(
                  child: Text("error"),
                ),
            loading: () => buildLoadingCard()),
      ),
    );
  }

  ListView buildLoadingCard() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10),
      itemCount: 2,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: LoadingCard(),
        );
      },
    );
  }

  Widget buildCard(ItemModel item) {
    return SystemCard(
      duration: null,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildImage(item),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: AppFonts.header,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        item.description ?? "comming soon...",
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: AppColors.descriptionColor,
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${item.price}\$",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox buildImage(ItemModel item) {
    return SizedBox(
      height: 80,
      width: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(item.image_url!),
        ),
      ),
    );
  }
}
