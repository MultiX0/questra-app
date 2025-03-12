import 'dart:developer';

import 'package:questra_app/core/enums/friends_status_enum.dart';
import 'package:questra_app/features/friends/models/friend_request_model.dart';
import 'package:questra_app/features/friends/models/friendship_model.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
import 'package:questra_app/features/friends/providers/friends_requests_provider.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
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

  Future<void> handleRequests({required UserModel reciver}) async {
    _ref.read(friendRequestLoadingProvider(reciver.id).notifier).state = true;

    try {
      state = true;
      final user = _ref.read(authStateProvider)!;
      final request = FriendRequestModel(
        id: -1,
        senderId: user.id,
        receiverId: reciver.id,
        requestDate: DateTime.now(),
        status: FriendsStatusEnum.pending,
      );

      await _repo.sendFriendRequest(request);
      final _currentRequests = _ref.read(usersWithActiveRequestFromMe);
      if (_currentRequests.any((user) => user.id == reciver.id)) {
        _ref.read(usersWithActiveRequestFromMe.notifier).state =
            _currentRequests.where((u) => u.id != reciver.id).toList();
      } else {
        _ref.read(usersWithActiveRequestFromMe.notifier).state = [..._currentRequests, reciver];
      }
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(appError);
    }
    _ref.read(friendRequestLoadingProvider(reciver.id).notifier).state = false;
    state = false;
  }

  Future<void> handleRemoveFriend(String userId) async {
    state = true;

    try {
      final me = _ref.read(authStateProvider)!;
      await _repo.removeFriend(user1: me.id, user2: userId);
      _ref.read(friendsStateProvider.notifier).removeUser(userId);
      _ref.read(friendsRequestsProvider.notifier).removeUserFromState(userId);
      CustomToast.systemToast("friend is succefully removed");
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      CustomToast.systemToast(appError);
      await ExceptionService.insertException(
        path: "/friends_controller",
        error: "$e\ntrace:$trace",
        userId: userId,
      );
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
