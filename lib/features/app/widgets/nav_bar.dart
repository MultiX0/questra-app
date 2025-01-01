import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/widgets/background_widget.dart';
import 'package:questra_app/theme/app_theme.dart';

class MyNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MyNavBar({super.key, required this.navigationShell});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyNavBarState();
}

class _MyNavBarState extends ConsumerState<MyNavBar> {
  bool _isNavBarVisible = true;
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
      body: BackgroundWidget(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: _isNavBarVisible
          ? LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                double navBarHeight;

                if (screenWidth < 600) {
                  // Mobile
                  navBarHeight = 110;
                } else if (screenWidth < 1024) {
                  // Tablet
                  navBarHeight = 140;
                } else if (screenWidth < 1440) {
                  // Laptop
                  navBarHeight = 100;
                } else {
                  // Desktop
                  navBarHeight = 120;
                }
                return SizedBox(
                  height: navBarHeight,
                  child: BottomNavigationBar(
                    selectedItemColor: AppColors.whiteColor,
                    unselectedItemColor: Colors.grey[600],
                    backgroundColor: Colors.black,
                    currentIndex: widget.navigationShell.currentIndex,
                    onTap: (int index) => onTap(context, index),
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(LucideIcons.book_text),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(LucideIcons.diamond),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          LucideIcons.user,
                        ),
                        label: '',
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
      floatingActionButton: !_isNavBarVisible
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isNavBarVisible = true;
                });
              },
              child: const Icon(Icons.menu),
            )
          : null,
    );
  }
}
