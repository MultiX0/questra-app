import 'dart:developer';

import 'package:questra_app/core/enums/friends_status_enum.dart';
import 'package:questra_app/features/friends/models/friend_request_model.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
import 'package:questra_app/features/friends/repository/friends_repository.dart';
import 'package:questra_app/imports.dart';

class FriendRequestsState {
  final List<UserModel> users;
  final List<Map<String, dynamic>> friendsRequests;
  final bool isLoading;
  final bool hasError;
  final bool hasReachedEnd;
  final String? errorMessage;
  final Set<String> loadingActionsUsers;

  FriendRequestsState({
    required this.users,
    required this.isLoading,
    required this.hasError,
    required this.hasReachedEnd,
    required this.friendsRequests,
    this.errorMessage,
    required this.loadingActionsUsers,
  });

  // Initial state
  factory FriendRequestsState.initial() {
    return FriendRequestsState(
      users: [],
      isLoading: false,
      hasError: false,
      hasReachedEnd: false,
      friendsRequests: [],
      loadingActionsUsers: {},
    );
  }

  // Create a new state by copying the current one with some changes
  FriendRequestsState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? hasError,
    bool? hasReachedEnd,
    String? errorMessage,
    Set<String>? loadingActionsUsers,
    List<Map<String, dynamic>>? friendsRequests,
  }) {
    return FriendRequestsState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage ?? this.errorMessage,
      friendsRequests: friendsRequests ?? this.friendsRequests,
      loadingActionsUsers: loadingActionsUsers ?? this.loadingActionsUsers,
    );
  }
}

class FriendRequeststateNotifier extends StateNotifier<FriendRequestsState> {
  final Ref _ref;

  FriendRequeststateNotifier({required Ref ref}) : _ref = ref, super(FriendRequestsState.initial());

  FriendsRepository get _repo => _ref.watch(friendsRepositoryProvider);

  static const int _pageSize = 20;

  void removeUserFromState(String userId) async {
    final users = state.users;
    final newUsers = users.where((user) => user.id != userId).toList();
    state = state.copyWith(users: newUsers);
  }

  Future<void> acceptFriend(String userId) async {
    state = state.copyWith(loadingActionsUsers: {...state.loadingActionsUsers, userId});
    try {
      final request = getFriendRequestById(userId);
      await _repo.accpetFriendRequest(request);
      _ref.read(friendsStateProvider.notifier).addUser(getUserFromState(userId));
      removeUserFromState(userId);
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
    }
    state = state.copyWith(
      loadingActionsUsers: state.loadingActionsUsers.where((id) => id != userId).toSet(),
    );
  }

  Future<void> declineFriend(String userId) async {
    state = state.copyWith(loadingActionsUsers: {...state.loadingActionsUsers, userId});
    try {
      final request = getFriendRequestById(userId);
      await _repo.updateFriendRequest(request.copyWith(status: FriendsStatusEnum.rejected));
      removeUserFromState(userId);
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
    }
    state = state.copyWith(
      loadingActionsUsers: state.loadingActionsUsers.where((id) => id != userId).toSet(),
    );
  }

  UserModel getUserFromState(String sender_id) {
    return state.users.where((u) => u.id == sender_id).first;
  }

  FriendRequestModel getFriendRequestById(String sender_id) {
    final _me = _ref.read(authStateProvider)!;
    final user = state.friendsRequests.where((r) => r[KeyNames.sender_id] == sender_id).toList();

    log("request_id: ${user[0]['data'][KeyNames.request_id]}");
    log("founded users in the state: $user");
    return FriendRequestModel(
      id: user[0]['data'][KeyNames.request_id],
      senderId: sender_id,
      receiverId: _me.id,
      requestDate: DateTime.now(),
      status: friendsEnumStringToEnum(user[0]['data'][KeyNames.status]),
    );
  }

  Future<void> fetchItems({bool refresh = false}) async {
    // If we're already loading or we've reached the end and we're not refreshing, don't fetch
    if ((state.isLoading || state.hasReachedEnd) && !refresh) {
      return;
    }

    try {
      // final userId = _ref.read(authStateProvider)!.id;
      state = state.copyWith(isLoading: true, hasError: false);
      final userId = _ref.read(authStateProvider)!.id;

      final startIndex = refresh ? 0 : state.users.length;

      // Fetch data from Supabase
      final response = await _repo.getAllFriendRequests(
        userId: userId,
        startIndex: startIndex,
        pageSize: _pageSize,
      );

      log("response ids data: ${response['ids']}");

      // Determine if we've reached the end
      final hasReachedEnd = response.length < _pageSize;
      List<Map<String, dynamic>> _usersMap = response['users'];
      List<UserModel> _users = _usersMap.map((user) => UserModel.fromMap(user)).toList();
      // Update state
      state = state.copyWith(
        users: refresh ? _users : [...state.users, ..._users],
        friendsRequests: refresh ? response['ids'] : [...state.friendsRequests, ...response['ids']],
        isLoading: false,
        hasReachedEnd: hasReachedEnd,
      );

      log("response ids data (in state): ${state.friendsRequests}");
    } catch (e) {
      // Handle error
      state = state.copyWith(isLoading: false, hasError: true, errorMessage: e.toString());
    }
  }

  void refresh() {
    fetchItems(refresh: true);
  }
}

// Provider for our paginated items
final friendsRequestsProvider =
    StateNotifierProvider<FriendRequeststateNotifier, FriendRequestsState>((ref) {
      return FriendRequeststateNotifier(ref: ref);
    });
