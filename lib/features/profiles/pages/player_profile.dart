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
          padding: const EdgeInsets.only(top: 10),
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
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      children: [
        UserDashboardWidget(),
        const SizedBox(
          height: 20,
        ),
        BuildDashboardGrid(),
      ],
    );
  }
}
