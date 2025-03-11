import 'package:questra_app/imports.dart';

final getUserLengthProvider = StateProvider<int>((ref) {
  return 0;
});

final usersWithActiveRequestFromMe = StateProvider<List<UserModel>>((ref) {
  return [];
});

final friendRequestLoadingProvider = StateProvider.family<bool, String>((ref, userId) => false);

final selectedFriendProvider = StateProvider<UserModel?>((ref) => null);
