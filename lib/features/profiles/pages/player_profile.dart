import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/features/app/widgets/user_dashboard_widget.dart';
import 'package:questra_app/features/profiles/widgets/dashboard_grid.dart';
import 'package:questra_app/imports.dart';

class PlayerProfile extends ConsumerStatefulWidget {
  final String userId;
  const PlayerProfile({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerProfileState();
}

class _PlayerProfileState extends ConsumerState<PlayerProfile> {
  @override
  Widget build(BuildContext context) {
    final _myData = ref.watch(authStateProvider);
    bool isMe = _myData?.id == widget.userId;
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: "Profile"),
        body: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: buildUserBody(isMe),
        ),
      ),
    );
  }

  Widget buildUserBody(bool isMe) {
    if (isMe) {
      return buildMe();
    }
    return const SizedBox();
  }

  ListView buildMe() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      children: [
        UserDashboardWidget(),
        const SizedBox(
          height: 15,
        ),
        BuildDashboardGrid(),
        const SizedBox(height: 15),
        buildGuildCard(),
        const SizedBox(height: 15),
        buildFriendsCard(),
      ],
    );
  }

  SystemCard buildGuildCard() {
    return SystemCard(
      onTap: soon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.building_2),
          const SizedBox(height: 10),
          Text("Guild"),
        ],
      ),
    );
  }

  SystemCard buildFriendsCard() {
    return SystemCard(
      onTap: soon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.users),
          const SizedBox(height: 10),
          Text("Friends"),
        ],
      ),
    );
  }

  void soon() => CustomToast.soon();
}
