import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:questra_app/core/providers/rewards_providers.dart';
import 'package:questra_app/features/lootbox/pages/lootbox_page.dart' show LootboxPage;
import 'package:questra_app/features/onboarding/pages/define_religion_page.dart';
import 'package:questra_app/imports.dart';

// import '../pages/new_version_page.dart';

class MyNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MyNavBar({super.key, required this.navigationShell});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyNavBarState();
}

class _MyNavBarState extends ConsumerState<MyNavBar> {
  final Color navigationBarColor = AppColors.primary.withValues(alpha: 0.05);
  int page = 0;

  void onTap(BuildContext context, int index) {
    ref.read(soundEffectsServiceProvider).playSystemButtonClick();
    setState(() {
      page = index;
    });

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // return NewVersionPage();
    final hasLootBox = ref.watch(hasLootBoxProvider);
    final user = ref.watch(authStateProvider);
    final isLoading = ref.watch(appLoading);

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: BackgroundWidget(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: widget.navigationShell,
            ),
          ),
          bottomNavigationBar: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              double navBarHeight;

              if (screenWidth < 600) {
                // Mobile
                navBarHeight = 60;
              } else if (screenWidth < 1024) {
                // Tablet
                navBarHeight = 90;
              } else if (screenWidth < 1440) {
                // Laptop
                navBarHeight = 100;
              } else {
                // Desktop
                navBarHeight = 120;
              }
              return CupertinoTabBar(
                height: navBarHeight,
                backgroundColor: navigationBarColor.withValues(alpha: .15),
                currentIndex: widget.navigationShell.currentIndex,
                onTap: (int index) => onTap(context, index),
                activeColor: HexColor('7AD5FF'),
                inactiveColor: navigationBarColor.withValues(alpha: .25),
                items: [
                  BottomNavigationBarItem(icon: Icon(LucideIcons.book_text)),
                  BottomNavigationBarItem(icon: Icon(LucideIcons.diamond)),
                  BottomNavigationBarItem(icon: Icon(LucideIcons.crown)),
                  BottomNavigationBarItem(icon: Icon(LucideIcons.user)),
                ],
              );
            },
          ),
        ),
        if (hasLootBox && user?.religion != null) LootboxPage(),
        if (user?.religion == null) DefineReligionPage().fadeIn(),
        if (isLoading)
          Positioned.fill(child: Container(color: Colors.black54, child: BeatLoader())),
      ],
    );
  }
}
