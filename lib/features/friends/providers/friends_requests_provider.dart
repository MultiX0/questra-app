import 'package:questra_app/features/friends/repository/friends_repository.dart';
import 'package:questra_app/imports.dart';

class FriendRequestsState {
  final List<UserModel> users;
  final bool isLoading;
  final bool hasError;
  final bool hasReachedEnd;
  final String? errorMessage;

  FriendRequestsState({
    required this.users,
    required this.isLoading,
    required this.hasError,
    required this.hasReachedEnd,
    this.errorMessage,
  });

  // Initial state
  factory FriendRequestsState.initial() {
    return FriendRequestsState(users: [], isLoading: false, hasError: false, hasReachedEnd: false);
  }

  // Create a new state by copying the current one with some changes
  FriendRequestsState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? hasError,
    bool? hasReachedEnd,
    String? errorMessage,
  }) {
    return FriendRequestsState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FriendRequeststateNotifier extends StateNotifier<FriendRequestsState> {
  final Ref _ref;

  FriendRequeststateNotifier({required Ref ref}) : _ref = ref, super(FriendRequestsState.initial());

  FriendsRepository get _repo => _ref.watch(friendsRepositoryProvider);

  static const int _pageSize = 20;

  Future<void> fetchItems({bool refresh = false, required String userId}) async {
    // If we're already loading or we've reached the end and we're not refreshing, don't fetch
    if ((state.isLoading || state.hasReachedEnd) && !refresh) {
      return;
    }

    try {
      // final userId = _ref.read(authStateProvider)!.id;
      state = state.copyWith(isLoading: true, hasError: false);

      final startIndex = refresh ? 0 : state.users.length;

      // Fetch data from Supabase
      final response = await _repo.getAllFriendRequests(
        userId: userId,
        startIndex: startIndex,
        pageSize: _pageSize,
      );

      // Determine if we've reached the end
      final hasReachedEnd = response.length < _pageSize;

      // Update state
      state = state.copyWith(
        users: refresh ? response : [...state.users, ...response],
        isLoading: false,
        hasReachedEnd: hasReachedEnd,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(isLoading: false, hasError: true, errorMessage: e.toString());
    }
  }

  void refresh(String userId) {
    fetchItems(refresh: true, userId: userId);
  }
}

// Provider for our paginated items
final friendsRequestsProvider =
    StateNotifierProvider<FriendRequeststateNotifier, FriendRequestsState>((ref) {
      return FriendRequeststateNotifier(ref: ref);
    });
