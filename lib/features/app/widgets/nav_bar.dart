import 'package:flutter/cupertino.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';

class MyNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MyNavBar({super.key, required this.navigationShell});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyNavBarState();
}

class _MyNavBarState extends ConsumerState<MyNavBar> {
  final Color navigationBarColor = HexColor('22B2F4').withValues(alpha: 0.15);
  int page = 0;

  void onTap(BuildContext context, int index) {
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
    return Scaffold(
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
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.book_text),
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.diamond),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    LucideIcons.user,
                  ),
                ),
              ],
            );
          },
        ));
  }
}
