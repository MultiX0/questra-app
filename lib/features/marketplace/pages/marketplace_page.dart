// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:questra_app/core/services/sound_effects_service.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/marketplace/controller/marketplace_controller.dart';
import 'package:questra_app/features/marketplace/models/item_model.dart';
import 'package:questra_app/features/marketplace/widgets/buy_item_widget.dart';
import 'package:questra_app/features/marketplace/widgets/item_card_loading.dart';
import 'package:questra_app/imports.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  String? selected;
  ItemModel? selectedItem;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedItem != null) {
          setState(() {
            selectedItem = null;
          });
          return false;
        }

        return true;
      },
      child: BackgroundWidget(
        child: Scaffold(
          appBar: TheAppBar(
            title: "Marketplace",
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(LucideIcons.shopping_cart),
                ),
              ),
            ],
          ),
          body: SafeArea(child: buildBody()),
        ),
      ),
    );
  }

  Widget buildBody() {
    final size = MediaQuery.sizeOf(context);

    if (selectedItem != null) {
      return BuyItemWidget(item: selectedItem!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: size.width * .08,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GlowText(
            text: "Categories",
            glowColor: AppColors.whiteColor,
            spreadRadius: 0.5,
            blurRadius: 15,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontFamily: AppFonts.primary,
              fontSize: 20,
            ),
          ),
        ),
        buildCategories(),
        buildItems(),
      ],
    );
  }

  Widget buildItems() {
    return Expanded(
      child: ref.watch(getAllItemsProvider).when(
            data: (items) {
              var filteredItems = items
                  .where((item) => (item.image_url != null && item.image_url!.isNotEmpty))
                  .toList();

              if (selected != null) {
                filteredItems = filteredItems.where((item) => item.type == selected).toList();
              }

              if (filteredItems.isEmpty) {
                return SizedBox(child: Center(child: buildEmptyItems()));
              }

              return AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, i) {
                    final item = filteredItems[i];
                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 900),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        // horizontalOffset: 20,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: i != 0 ? 15 : 0,
                                bottom: i >= (filteredItems.length - 1) ? 30 : 0),
                            child: buildCard(item),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            error: (error, _) => Center(
              // TODO
              // in the future change this fucking error handle and make it good idiot;
              child: Text(error.toString()),
            ),
            loading: () => buildLoadingCard(),
          ),
    );
  }

  ListView buildLoadingCard() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10),
      itemCount: 4,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: LoadingCard(),
        );
      },
    );
  }

  Widget buildCard(ItemModel item) {
    return GestureDetector(
      onTap: () {
        ref.read(soundEffectsServiceProvider).playEffectWithCache('click1.ogg');
      },
      child: Stack(
        children: [
          SystemCard(
            onTap: () {
              setState(() {
                selectedItem = item;
              });
            },
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
          ),
          if (item.locked) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => CustomToast.systemToast("this item is locked for now"),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withValues(
                        alpha: 0.8,
                      )),
                  child: Center(
                    child: Text(
                      "Locked",
                      style: TextStyle(
                        fontFamily: AppFonts.header,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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

  SingleChildScrollView buildCategories() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 25),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: marketPlaceItemsCategories.asMap().entries.map((e) {
          final c = e.value;
          final i = e.key;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected == c) {
                  selected = null;
                } else {
                  selected = c;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: (selected == c)
                    ? Colors.purpleAccent.withValues(alpha: .15)
                    : AppColors.primary.withValues(alpha: .15),
                border: Border.all(
                  color: (selected == c) ? Colors.purpleAccent : AppColors.primary,
                ),
              ),
              margin: EdgeInsets.only(
                left: i == 0 ? 20 : 10,
                right: i >= (marketPlaceItemsCategories.length - 1) ? 20 : 0,
              ),
              child: Center(
                child: Text(c),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildEmptyItems() {
    return SystemCard(
      isButton: true,
      padding: EdgeInsets.all(16),
      child: Text(
        "There is no items",
        style: TextStyle(fontFamily: AppFonts.header, fontSize: 20),
      ),
    );
  }
}
