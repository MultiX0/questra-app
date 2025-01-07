import 'package:questra_app/features/auth/models/user_model.dart';
import 'package:questra_app/imports.dart';

final hasValidAccountProvider = StateProvider<bool>((ref) {
  return false;
});

final localUserProvider = StateProvider<UserModel?>((ref) => null);
