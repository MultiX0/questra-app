import 'dart:async';
import 'dart:developer';

import 'package:questra_app/features/auth/models/user_model.dart';
import 'package:questra_app/features/auth/repository/auth_repository.dart';
import 'package:questra_app/imports.dart';

import '../onboarding/widgets/onboarding_bg.dart';

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
    log("here  is  test");
    _userSubscription = ref.read(authStateProvider.notifier).stateStream.listen((user) async {
      log("the user data is $user");
      if (mounted) {
        if (user!.id.isNotEmpty) {
          final valid = await ref.read(authStateProvider.notifier).hasValidAccount();

          if (!valid) {
            if (mounted) {
              context.go(Routes.onboardingController);
              return;
            }
          }

          if (mounted) {
            context.go(Routes.homePage);
          }
        } else {
          ref.watch(isLoggedInProvider.notifier).state = false;
          // context.go(Routes.onboardingPage);
        }
      }
    });
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
            Assets.getImage('app_logo.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
