import 'dart:developer';

import 'package:questra_app/imports.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) => AuthController(ref: ref));

class AuthController extends StateNotifier<bool> {
  final Ref _ref;
  AuthController({required Ref ref})
      : _ref = ref,
        super(false);

  AuthNotifier get _auth => _ref.watch(authStateProvider.notifier);

  Future<void> login() async {
    try {
      state = true;
      await _auth.googleSignIn();
      state = false;
    } catch (e) {
      state = false;

      log(e.toString());
      CustomToast.systemToast(appError);
      throw Exception(e);
    }
  }
}
