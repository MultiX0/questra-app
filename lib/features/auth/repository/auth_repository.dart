import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:questra_app/core/services/android_id_service.dart';
import 'package:questra_app/features/goals/models/user_goal_model.dart';
import 'package:questra_app/features/goals/providers/goals_provider.dart';
import 'package:questra_app/features/goals/repository/goals_repository.dart';
import 'package:questra_app/features/preferences/controller/user_preferences_controller.dart';
import 'package:questra_app/features/preferences/models/user_preferences_model.dart';
import 'package:questra_app/features/ranking/functions/ranking_functions.dart';
import 'package:questra_app/features/titles/models/player_title_model.dart';
import 'package:questra_app/features/wallet/models/wallet_model.dart';
import 'package:questra_app/features/wallet/repository/wallet_repository.dart';
import 'package:questra_app/imports.dart';
import 'package:rxdart/rxdart.dart';

final serverClientId = dotenv.env['SERVERCLIENTID'] ?? '';
final clientId = kDebugMode ? dotenv.env['CLIENTID'] ?? '' : releaseId;
final releaseId = '39700937787-d7prd0sk55q10bi2jffttm5e4c1rggnk.apps.googleusercontent.com';

final authStateProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref: ref);
});

final isLoggedInProvider = StateProvider<bool>((ref) {
  return false;
});

final validAccountProvider = StateProvider<bool>((ref) {
  return false;
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final Ref _ref;
  bool _isInitialized = false;
  Timer? _debounceTimer;

  late final StreamSubscription<AuthState> _authStateSubscription;
  StreamSubscription<List<dynamic>>? _userSubscription;

  final _stateStreamController = BehaviorSubject<UserModel?>();
  Stream<UserModel?> get stateStream => _stateStreamController.stream.distinct();

  SupabaseClient get _supabase => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _devicesTable => _supabase.from(TableNames.player_devices);

  AuthNotifier({required Ref ref}) : _ref = ref, super(null) {
    _initializeAuth();
  }

  void _initializeAuth() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Use a simple listener without debounce to avoid multiple triggers
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen(
      _handleAuthStateChange,
      onError: (error) {
        log('AuthState error: $error');
        _ref.read(isLoggedInProvider.notifier).state = false;
      },
    );
  }

  void _handleAuthStateChange(AuthState authState) {
    final userId = authState.session?.user.id;
    if (userId != null) {
      _ref.read(isLoggedInProvider.notifier).state = true;
      _initializeUserDataStream(userId);
    } else {
      _cleanup();
    }
  }

  void _initializeUserDataStream(String userId) {
    _userSubscription?.cancel();

    _userSubscription = CombineLatestStream.list([
      _supabase
          .from(TableNames.players)
          .stream(primaryKey: [KeyNames.id])
          .eq(KeyNames.id, userId)
          .debounceTime(const Duration(milliseconds: 300)),
      _supabase
          .from(TableNames.player_levels)
          .stream(primaryKey: [KeyNames.user_id])
          .eq(KeyNames.user_id, userId)
          .debounceTime(const Duration(milliseconds: 550)),
      _supabase
          .from(TableNames.wallet)
          .stream(primaryKey: [KeyNames.user_id])
          .eq(KeyNames.user_id, userId)
          .debounceTime(const Duration(milliseconds: 700)),
    ]).listen(
      (events) => _handleUserDataUpdate(events, userId),
      onError: (error) {
        log('User data stream error: $error');
        _retryUserDataStream(userId);
      },
    );
  }

  Future<void> _handleUserDataUpdate(List<List<dynamic>> events, String userId) async {
    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final userEvent = events[0].isNotEmpty ? events[0].first : null;
        final levelEvent = events[1].isNotEmpty ? events[1].first : null;
        final walletEvent = events[2].isNotEmpty ? events[2].first : null;

        final newState = await _buildUpdatedState(userEvent, levelEvent, walletEvent, userId);
        if (!_isEquivalentState(state, newState)) {
          state = newState;
          _stateStreamController.add(newState);
        }
      } catch (e) {
        log('Error handling user data update: $e');
        await ExceptionService.insertException(
          path: "/auth_repository",
          error: e.toString(),
          userId: userId,
        );
      }
    });
  }

  Future<UserModel?> _buildUpdatedState(
    Map<String, dynamic>? userEvent,
    Map<String, dynamic>? levelEvent,
    Map<String, dynamic>? walletEvent,
    String userId,
  ) async {
    if (userEvent == null) {
      return UserModel(
        id: userId,
        name: '',
        username: '',
        gender: '',
        joined_at: DateTime.now(),
        avatar: '',
        lang: 'en',
        is_online: false,
      );
    }

    var user = UserModel.fromMap(userEvent);

    log(
      "active title id ${userEvent[KeyNames.active_title]},\nactive title from the model ${user.activeTitleId}",
    );

    // Fetch additional user data

    final List<dynamic> results = await Future.wait<dynamic>([
      _ref.read(profileRepositoryProvider).getUserBirthDate(userId),
      _ref.read(profileRepositoryProvider).getActiveTitle(userEvent[KeyNames.active_title]),
      _ref.read(rankingFunctionsProvider).refreshRanking(userId),
    ]);

    final [String birthDate, PlayerTitleModel? activeTitle, _] = results;

    // Handle level data
    if (levelEvent == null) {
      final level = await _ref.read(levelingRepositoryProvider).insertNewLevelRow(userId);
      user = user.copyWith(level: level);
    } else {
      user = user.copyWith(level: LevelsModel.fromMap(levelEvent));
    }

    // Handle wallet data
    if (walletEvent != null) {
      user = user.copyWith(wallet: WalletModel.fromMap(walletEvent));
    } else {
      final wallet = await _ref.read(walletRepositoryProvider).getUserWallet(userId);
      user = user.copyWith(wallet: wallet);
    }

    // Only fetch preferences and goals if they're not already present
    if (state?.goals == null || state?.user_preferences == null) {
      final List<dynamic> combinePrefsAndGoals = await Future.wait([
        _ref.read(userPreferencesControllerProvider.notifier).getUserPreferences(userId),
        _ref.read(goalsRepositoryProvider).getUserGoals(userId),
      ]);

      final [UserPreferencesModel? prefs, List<UserGoalModel> goals] = combinePrefsAndGoals;

      _ref.read(playerGoalsProvider).clear();
      _ref.read(playerGoalsProvider).addAll(goals);

      user = user.copyWith(
        birth_date: DateTime.tryParse(birthDate),
        activeTitle: activeTitle,
        goals: goals,
        user_preferences: prefs,
      );
    } else {
      user = user.copyWith(birth_date: DateTime.tryParse(birthDate), activeTitle: activeTitle);
    }
    final currentLang = _ref.read(localeProvider).languageCode;
    if (currentLang != user.lang) {
      _ref.read(localeProvider.notifier).state = Locale(user.lang);
    }

    return user;
  }

  bool _isEquivalentState(UserModel? current, UserModel? next) {
    if (current == null || next == null) return current == next;

    // Compare only essential fields that should trigger a state update
    return current.id == next.id &&
        current.name == next.name &&
        current.username == next.username &&
        current.activeTitle == next.activeTitle &&
        current.level == next.level &&
        current.wallet == next.wallet &&
        current.avatar == next.avatar &&
        current.activeTitleId == next.activeTitleId &&
        current.religion == next.religion &&
        current.lang == next.lang;
  }

  void _retryUserDataStream(String userId) {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _initializeUserDataStream(userId);
      }
    });
  }

  Future<bool> googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: serverClientId,
        clientId: clientId,
        scopes: ["profile", "email"],
      );

      // Ensure clean state
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Failed to get Google auth tokens');
      }

      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user != null) {
        _ref.read(analyticsServiceProvider).logEvent('user_login', {
          'user_id': authResponse.user!.id,
          'login_method': 'google',
        });
        _ref.read(firebaseAnalyticsProvider).setUserId(id: authResponse.user!.id);
        return true;
      }

      return false;
    } catch (e) {
      log('Google sign in error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["profile", "email"]);
      await googleSignIn.signOut();
      await _supabase.auth.signOut();
      _cleanup();
    } catch (e) {
      log('Logout error: $e');
    }
  }

  void _cleanup() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _debounceTimer?.cancel();
    // state = null;
    _stateStreamController.add(null);
    _ref.read(isLoggedInProvider.notifier).state = false;
    _ref.read(hasValidAccountProvider.notifier).state = false;
  }

  Future<bool> hasValidAccount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final data =
          await _supabase.from(TableNames.players).select().eq(KeyNames.id, userId).maybeSingle();

      return data != null;
    } catch (e) {
      log('hasValidAccount error: $e');
      return false;
    }
  }

  Future<bool> insertNewUser(UserModel user) async {
    try {
      if (await hasValidAccount()) {
        _ref.read(hasValidAccountProvider.notifier).state = true;
        return true;
      }

      final data = await _supabase.from(TableNames.players).insert(user.toMap()).select().single();

      if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        final androidId = await androidIdPlugin.getId();
        if (androidId != null) {
          await _devicesTable.insert({KeyNames.device_id: androidId, KeyNames.user_id: user.id});
        }
      }

      state = UserModel.fromMap(data);
      _ref.read(hasValidAccountProvider.notifier).state = true;
      return true;
    } catch (e) {
      log('insertNewUser error: $e');
      return false;
    }
  }

  Future<bool> availableUsername(String username) async {
    try {
      final data = await _supabase
          .from(TableNames.players)
          .select()
          .eq(KeyNames.username, username.trim());
      return data.isEmpty;
    } catch (e) {
      log('availableUsername error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _cleanup();
    _authStateSubscription.cancel();
    _stateStreamController.close();
    super.dispose();
  }
}
