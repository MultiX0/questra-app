import 'package:questra_app/features/friends/pages/friend_requests_page.dart';
import 'package:questra_app/features/friends/pages/friends_page.dart';
import 'package:questra_app/imports.dart';

class FriendsControllerPage extends ConsumerStatefulWidget {
  const FriendsControllerPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendsControllerPageState();
}

class _FriendsControllerPageState extends ConsumerState<FriendsControllerPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authStateProvider)!;
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(
          title: AppLocalizations.of(context).profile_friends,
          actions: [
            IconButton(
              onPressed: () => context.push(Routes.addFriendsPage),

              icon: Icon(LucideIcons.user_plus),
            ),
          ],
        ),
        body: Column(
          children: [
            buildCategoryChange(),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [FriendsPage(userId: me.id), FriendRequestsPage()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryChange() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Row(
      spacing: 10,
      children: [
        Expanded(
          child: buildCategoryCard(
            duration: const Duration(milliseconds: 300),
            index: 0,
            text: AppLocalizations.of(context).friends,
          ),
        ),
        Expanded(
          child: buildCategoryCard(
            duration: const Duration(milliseconds: 300),
            index: 1,
            text: AppLocalizations.of(context).requests,
          ),
        ),
      ],
    ),
  );

  GestureDetector buildCategoryCard({
    required Duration duration,
    required int index,
    required String text,
  }) {
    // bool isArabic = ref.watch(localeProvider).languageCode == 'ar';

    bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(soundEffectsServiceProvider).playSystemButtonClick();
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          color:
              isActive
                  ? Colors.purpleAccent.withValues(alpha: .15)
                  : AppColors.primary.withValues(alpha: 0.15),
          border: Border.all(color: isActive ? Colors.purpleAccent : AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Center(child: Text(text)),
      ),
    );
  }
}
