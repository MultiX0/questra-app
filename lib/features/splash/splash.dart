import 'dart:async';
import 'dart:developer';

import 'package:questra_app/core/services/exception_service.dart';
import 'package:questra_app/features/quests/repository/quests_repository.dart';
import 'package:questra_app/imports.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late final StreamSubscription<UserModel?> _userSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  void _startListening() {
    try {
      _userSubscription = ref.read(authStateProvider.notifier).stateStream.listen((user) async {
        log("the user data is $user");
        if (mounted) {
          if (user != null && user.id.isNotEmpty) {
            ref.read(isLoggedInProvider.notifier).state = true;
            final valid = await ref.read(authStateProvider.notifier).hasValidAccount();
            ref.read(validAccountProvider.notifier).state = valid;

            if (!valid) {
              if (mounted) {
                context.go(Routes.onboardingController);
                return;
              }
            }

            final quests = await ref.read(questsRepositoryProvider).currentlyOngoingQuests(user.id);
            ref.read(currentOngointQuestsProvider.notifier).state = quests;

            if (mounted && valid) {
              context.go(Routes.homePage);
            }
          } else {
            ref.read(isLoggedInProvider.notifier).state = false;
            context.go(Routes.onboardingPage);
          }
        }
      });
    } catch (e) {
      log(e.toString());
      ExceptionService.insertException(
        path: "/splash",
        error: e.toString(),
        userId: Supabase.instance.client.auth.currentUser?.id ?? "",
      );
    }
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Image.asset(
            Assets.getImage('splash_icon.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
