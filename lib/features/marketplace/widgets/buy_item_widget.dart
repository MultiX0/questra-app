import 'package:questra_app/features/marketplace/controller/marketplace_controller.dart';
import 'package:questra_app/features/marketplace/models/item_model.dart';
import 'package:questra_app/imports.dart';

class BuyItemWidget extends ConsumerStatefulWidget {
  const BuyItemWidget({
    super.key,
    required this.item,
  });

  final ItemModel item;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BuyItemWidgetState();
}

class _BuyItemWidgetState extends ConsumerState<BuyItemWidget> {
  int amount = 1;

  void increase() {
    setState(() {
      amount++;
    });
  }

  void decrease() {
    if (amount > 1) {
      setState(() {
        amount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(marketPlaceControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: SystemCard(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          isButton: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Buy ${widget.item.name}",
                style: TextStyle(
                  fontFamily: AppFonts.header,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.item.description ?? "",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "cost: ${amount * widget.item.price}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground.withValues(alpha: .5),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .5),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    IconButton(
                      onPressed: decrease,
                      icon: Icon(
                        LucideIcons.minus,
                      ),
                    ),
                    Text(
                      amount.toString(),
                      style: TextStyle(
                        fontFamily: AppFonts.header,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: increase,
                      icon: Icon(
                        LucideIcons.plus,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (isLoading) ...[
                Center(
                  child: LoadingAnimationWidget.beat(
                    color: AppColors.primary,
                    size: 30,
                  ),
                )
              ] else ...[
                SystemCard(
                  onTap: () => ref.read(marketPlaceControllerProvider.notifier).buyItem(
                        widget.item,
                        amount,
                        context,
                      ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  isButton: true,
                  child: Text("Buy"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
