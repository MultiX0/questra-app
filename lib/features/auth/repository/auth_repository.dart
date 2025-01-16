import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:questra_app/features/goals/repository/goals_repository.dart';
import 'package:questra_app/features/preferences/controller/user_preferences_controller.dart';
import 'package:questra_app/features/profiles/repository/profile_repository.dart';
import 'package:questra_app/imports.dart';
import 'package:rxdart/rxdart.dart';

final serverClientId = dotenv.env['SERVERCLIENTID'] ?? '';
final clientId = dotenv.env[kDebugMode ? 'CLIENTID' : 'CLIENTID_RELEASE'] ?? '';

final authStateProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref: ref);
});

final isLoggedInProvider = StateProvider<bool>((ref) {
  return true;
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final Ref _ref;

  late final StreamSubscription<AuthState> _authStateSubscription;
  late StreamSubscription<List<dynamic>> _userSubscription;

  final StreamController<UserModel?> _stateStreamController =
      StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get stateStream => _stateStreamController.stream;

  SupabaseClient get _supabase => _ref.watch(supabaseProvider);

  AuthNotifier({required Ref ref})
      : _ref = ref,
        super(null) {
    _initListener();
  }

  void _initListener() {
    _authStateSubscription =
        _supabase.auth.onAuthStateChange.debounceTime(const Duration(seconds: 1)).listen(
      (session) {
        final userId = session.session?.user.id;
        if (userId != null) {
          _listenToUserData(userId);
        } else {
          state = null;
          _stateStreamController.add(state);
        }
      },
      onError: (error) {
        log('AuthState error: $error');
      },
    );
  }

  void _listenToUserData(String userId) {
    _userSubscription = CombineLatestStream.list([
      _supabase
          .from(TableNames.players)
          .stream(primaryKey: [KeyNames.id])
          .eq(KeyNames.id, userId)
          .debounceTime(const Duration(seconds: 1)),

      _supabase
          .from(TableNames.player_levels)
          .stream(primaryKey: [KeyNames.user_id])
          .eq(KeyNames.user_id, userId)
          .debounceTime(
            const Duration(milliseconds: 600),
          )

      // _ref.watch(levelingRepositoryProvider).playerLevelStream(userId),
    ]).listen((events) async {
      final userEvent = events[0].isNotEmpty ? events[0].first : null;
      final levelEvent = events[1].isNotEmpty ? events[1].first : null;
      LevelsModel? _level;

      log("the user event is $userEvent");

      if (userEvent == null) {
        state = UserModel(
          id: _supabase.auth.currentUser?.id ?? '',
          name: '',
          username: '',
          gender: '',
          joined_at: DateTime.now(),
          avatar: '',
          is_online: false,
        );
        _stateStreamController.add(state);
      }

      if (userEvent != null && userEvent.isNotEmpty) {
        var user = UserModel.fromMap(userEvent);
        final data = await _ref.read(profileRepositoryProvider).getUserBirthDate(user.id);
        user = user.copyWith(birth_date: DateTime.tryParse(data));

        if (state != user && user.id.isNotEmpty) {
          if (state?.goals == null || state?.user_preferences == null) {
            final prefs = await _ref
                .read(userPreferencesControllerProvider.notifier)
                .getUserPreferences(user.id);
            final goals = await _ref.read(goalsRepositoryProvider).getUserGoals(user.id);
            state = user.copyWith(
              goals: goals,
              user_preferences: prefs,
              level: _level,
            );
          } else {
            state = user.copyWith(
              level: _level,
            );
          }
          log("the user data is updated");
        }
        _stateStreamController.add(state);
      }

      final validAccount = _ref.watch(hasValidAccountProvider);

      if (levelEvent == null && validAccount) {
        final level = await _ref.read(levelingRepositoryProvider).insertNewLevelRow(userId);
        _level = level;
      }

      if (levelEvent != null && levelEvent.isNotEmpty) {
        final levelModel = LevelsModel.fromMap(levelEvent);
        if (state?.level != levelModel) {
          state = state?.copyWith(level: levelModel);
        }
      }
    }, onError: (error) async {
      log('User data stream error: $error');
      await Future.delayed(const Duration(seconds: 5));
      _listenToUserData(userId);
    });
  }

  Future<bool> googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: serverClientId,
        clientId: clientId,
        scopes: ["profile", "email"],
      );

      // First check if already signed in
      final isSignedIn = await googleSignIn.isSignedIn();
      if (isSignedIn) {
        await googleSignIn.signOut();
      }

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Sign in canceled by user';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Failed to get tokens';
      }

      final user = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final session = _supabase.auth.currentSession;
      log('Current session: ${session?.toJson()}');

      _ref.read(isLoggedInProvider.notifier).state = true;

      return user.user != null;
    } catch (e) {
      log('Google sign in error: ${e.toString()}');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ["profile", "email"],
      );
      await googleSignIn.signOut();

      await _supabase.auth.signOut();
      state = null;
      _stateStreamController.add(state);
    } catch (e) {
      log('Logout error: ${e.toString()}');
    }
  }

  Future<bool> hasValidAccount() async {
    try {
      final id = _supabase.auth.currentUser?.id ?? '';
      final data =
          await _supabase.from(TableNames.players).select('*').eq(KeyNames.id, id).maybeSingle();

      return (data != null);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<bool> insertNewUser(UserModel user) async {
    try {
      final hasAccount = await hasValidAccount();
      if (hasAccount) {
        _ref.read(hasValidAccountProvider.notifier).state = true;
        return true;
      }
      final data = await _supabase.from(TableNames.players).insert(user.toMap()).select('*');
      if (data.isNotEmpty) {
        state = UserModel.fromMap(data.first);
        _ref.read(hasValidAccountProvider.notifier).state = true;
        return true;
      }
      return false;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> availableUsername(String username) async {
    try {
      final data = await _supabase
          .from(TableNames.players)
          .select('*')
          .eq(KeyNames.username, username.trim());
      return data.isEmpty;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  void updateState(UserModel user) {
    state = user;
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _userSubscription.cancel();
    _stateStreamController.close();
    super.dispose();
  }
}
