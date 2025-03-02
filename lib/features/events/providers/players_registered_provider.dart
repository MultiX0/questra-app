import 'package:questra_app/features/events/repository/events_repository.dart';
import 'package:questra_app/imports.dart';

class PaginatedItemsState {
  final List<UserModel> users;
  final bool isLoading;
  final bool hasError;
  final bool hasReachedEnd;
  final String? errorMessage;

  PaginatedItemsState({
    required this.users,
    required this.isLoading,
    required this.hasError,
    required this.hasReachedEnd,
    this.errorMessage,
  });

  // Initial state
  factory PaginatedItemsState.initial() {
    return PaginatedItemsState(users: [], isLoading: false, hasError: false, hasReachedEnd: false);
  }

  // Create a new state by copying the current one with some changes
  PaginatedItemsState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? hasError,
    bool? hasReachedEnd,
    String? errorMessage,
  }) {
    return PaginatedItemsState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PaginatedItemsNotifier extends StateNotifier<PaginatedItemsState> {
  final Ref _ref;

  PaginatedItemsNotifier({required Ref ref}) : _ref = ref, super(PaginatedItemsState.initial());

  EventsRepository get _repo => _ref.watch(eventsRepositoryProvider);

  static const int _pageSize = 20;

  Future<void> fetchItems({bool refresh = false}) async {
    // If we're already loading or we've reached the end and we're not refreshing, don't fetch
    if ((state.isLoading || state.hasReachedEnd) && !refresh) {
      return;
    }

    try {
      final event = _ref.watch(selectedQuestEvent)!;
      // Set loading state
      state = state.copyWith(isLoading: true, hasError: false);

      final startIndex = refresh ? 0 : state.users.length;

      // Fetch data from Supabase
      final response = await _repo.getAllRegisteredUser(
        eventId: event.id,
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

  void refresh() {
    fetchItems(refresh: true);
  }
}

// Provider for our paginated items
final paginatedItemsProvider = StateNotifierProvider<PaginatedItemsNotifier, PaginatedItemsState>((
  ref,
) {
  return PaginatedItemsNotifier(ref: ref);
});
