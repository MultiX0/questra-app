import 'dart:developer';

import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/app/widgets/user_dashboard_widget.dart';
import 'package:questra_app/features/profiles/controller/profile_controller.dart';
import 'package:questra_app/imports.dart';

class OtherProfile extends ConsumerStatefulWidget {
  const OtherProfile({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtherProfileState();
}

class _OtherProfileState extends ConsumerState<OtherProfile> {
  String userId = '';
  @override
  void initState() {
    super.initState();
    userId = widget.userId;
  }

  @override
  Widget build(BuildContext context) {
    log(userId);
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).profile),
        body: ref
            .watch(getUserProfileProvider(userId))
            .when(
              data: (user) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: ListView(children: [UserDashboardWidget(user: user)]),
                );
              },
              error: (e, _) => Center(child: ErrorWidget(e)),
              loading: () => BeatLoader(),
            ),
      ),
    );
  }
}
