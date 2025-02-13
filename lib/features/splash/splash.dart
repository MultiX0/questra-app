import 'dart:async';
import 'dart:developer';

import 'package:questra_app/features/quests/repository/quests_repository.dart';
import 'package:questra_app/imports.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  StreamSubscription<UserModel?>? _userSubscription;
  bool _isNavigationDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  void _startListening() {
    _userSubscription = ref.read(authStateProvider.notifier).stateStream.listen(
      (user) async {
        if (_isNavigationDone || !mounted) return;

        log("User data: $user");

        if (user != null && user.id.isNotEmpty) {
          final valid = await ref.read(authStateProvider.notifier).hasValidAccount();
          if (!mounted) return;

          if (!valid) {
            _isNavigationDone = true;
            if (mounted) context.go(Routes.onboardingController);
            return;
          }

          final quests = await ref.read(questsRepositoryProvider).currentlyOngoingQuests(user.id);
          if (!mounted) return;

          ref.read(currentOngointQuestsProvider.notifier).state = quests;
          _isNavigationDone = true;
          if (mounted) context.go(Routes.homePage);
        } else {
          ref.read(isLoggedInProvider.notifier).state = false;
          _isNavigationDone = true;
          if (mounted) context.go(Routes.onboardingPage);
        }
      },
      onError: (error) {
        log("Auth state error: $error");
        _isNavigationDone = true;
        if (mounted) context.go(Routes.onboardingPage);
      },
    );
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
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
