import 'package:questra_app/imports.dart';

class BuildDashboardGrid extends ConsumerWidget {
  const BuildDashboardGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void play() {
      ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    }

    List<Map<String, dynamic>> buttons = [
      {
        'name': "Goals",
        "icon": LucideIcons.sparkles,
        "onTap": () {
          play();
          context.push(Routes.goalsPage);
        },
      },
      {
        'name': "Titels",
        "icon": LucideIcons.crown,
        "onTap": () {
          play();
          // CustomToast.soon();
          context.push(Routes.titlesPage);
        },
      },
      {
        'name': "Achivment",
        "icon": LucideIcons.archive,
        "onTap": () {
          play();
          CustomToast.soon();
        },
      },
    ];
    return Row(
      children: buttons.asMap().entries.map((e) {
        final btn = e.value;
        final i = e.key;

        return Expanded(
          child: SystemCard(
            onTap: btn["onTap"],
            duration: const Duration(milliseconds: 950),
            margin: i == 1 ? EdgeInsets.symmetric(horizontal: 15) : null,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            isButton: true,
            child: Column(
              children: [
                Icon(btn["icon"] as IconData),
                const SizedBox(
                  height: 10,
                ),
                Text(btn["name"]),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
