import 'dart:developer';

import 'package:questra_app/core/enums/friends_status_enum.dart';
import 'package:questra_app/features/friends/models/friend_request_model.dart';
import 'package:questra_app/features/friends/models/friendship_model.dart';
import 'package:questra_app/features/friends/repository/friends_repository.dart';
import 'package:questra_app/imports.dart';

final friendsControllerProvider = StateNotifierProvider<FriendsController, bool>(
  (ref) => FriendsController(ref: ref),
);

final searchPlayers = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  final _controller = ref.watch(friendsControllerProvider.notifier);
  return await _controller.searchUsers(query);
});

class FriendsController extends StateNotifier<bool> {
  final Ref _ref;
  FriendsController({required Ref ref}) : _ref = ref, super(false);

  FriendsRepository get _repo => _ref.watch(friendsRepositoryProvider);

  Future<void> handleRequests({required String reciverId}) async {
    try {
      state = true;
      final user = _ref.read(authStateProvider)!;
      final request = FriendRequestModel(
        id: -1,
        senderId: user.id,
        receiverId: reciverId,
        requestDate: DateTime.now(),
        status: FriendsStatusEnum.pending,
      );
      await _repo.sendFriendRequest(request);
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(appError);
    }
    state = false;
  }

  Future<FriendRequestModel?> getFriendRequest(String otherUserId) async {
    try {
      state = true;
      final user = _ref.read(authStateProvider)!;
      return await _repo.getFriendRequest(user1: user.id, user2: otherUserId);
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(appError);
    }
    state = false;
    return null;
  }

  Future<FriendshipModel?> getFriend(String otherUserId) async {
    try {
      state = true;
      final user = _ref.read(authStateProvider)!;

      return await _repo.getFriend(user1: user.id, user2: otherUserId);
    } catch (e) {
      log(e.toString());
    }
    state = false;
    return null;
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      return await _repo.searchUsers(query);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
