import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:questra_app/features/goals/providers/goals_provider.dart';
import 'package:questra_app/features/goals/repository/goals_repository.dart';
import 'package:questra_app/features/preferences/controller/user_preferences_controller.dart';
import 'package:questra_app/features/profiles/repository/profile_repository.dart';
import 'package:questra_app/features/ranking/functions/ranking_functions.dart';
import 'package:questra_app/features/wallet/models/wallet_model.dart';
import 'package:questra_app/features/wallet/repository/wallet_repository.dart';
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
  SupabaseQueryBuilder get _devicesTable => _supabase.from(TableNames.player_devices);

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
          ),
      _supabase
          .from(TableNames.wallet)
          .stream(primaryKey: [KeyNames.user_id])
          .eq(KeyNames.user_id, userId)
          .debounceTime(
            const Duration(seconds: 2),
          ),
    ]).listen((events) async {
      final userEvent = events[0].isNotEmpty ? events[0].first : null;
      final levelEvent = events[1].isNotEmpty ? events[1].first : null;
      final walletEvent = events[2].isNotEmpty ? events[2].first : null;

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

      await _handleUserEvent(userEvent, userId);
      await _handleLevelEvent(levelEvent, userId);
      await _handleWalletEvent(walletEvent, userId);
    }, onError: (error) async {
      log('User data stream error: $error');
      await Future.delayed(const Duration(seconds: 8));
      _listenToUserData(userId);
    });
  }

  Future<void> _handleUserEvent(Map<String, dynamic>? userEvent, String userId) async {
    try {
      if (userEvent != null && userEvent.isNotEmpty) {
        var user = UserModel.fromMap(userEvent);
        final data = await _ref.read(profileRepositoryProvider).getUserBirthDate(user.id);
        final activeTitle = await _ref.read(profileRepositoryProvider).getActiveTitle(userId);
        user = user.copyWith(
          birth_date: DateTime.tryParse(data),
          activeTitle: activeTitle,
        );

        if (state != user && user.id.isNotEmpty) {
          if (state?.goals == null || state?.user_preferences == null) {
            final prefs = await _ref
                .read(userPreferencesControllerProvider.notifier)
                .getUserPreferences(user.id);
            final goals = await _ref.read(goalsRepositoryProvider).getUserGoals(user.id);
            _ref.read(playerGoalsProvider.notifier).state = goals;
            state = user.copyWith(
              goals: goals,
              user_preferences: prefs,
            );
          } else {
            state = user;
          }
          log("the user data is updated");
        }
        _stateStreamController.add(state);
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> _handleLevelEvent(Map<String, dynamic>? levelEvent, String userId) async {
    try {
      final validAccount = _ref.watch(hasValidAccountProvider);

      if (levelEvent == null && validAccount) {
        final level = await _ref.read(levelingRepositoryProvider).insertNewLevelRow(userId);
        state = state?.copyWith(level: level);
        return;
      }

      if (levelEvent != null && levelEvent.isNotEmpty) {
        final levelModel = LevelsModel.fromMap(levelEvent);
        if (state?.level != levelModel) {
          state = state?.copyWith(level: levelModel);
          await _ref.read(rankingFunctionsProvider).refreshRanking(userId);
        }
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> _handleWalletEvent(Map<String, dynamic>? walletEvent, String userId) async {
    try {
      if (walletEvent != null) {
        final _wallet = WalletModel.fromMap(walletEvent);
        if (state?.wallet != _wallet) {
          state = state?.copyWith(wallet: _wallet);
        }
      } else {
        final _wallet = await _ref.read(walletRepositoryProvider).getUserWallet(userId);
        state = state?.copyWith(wallet: _wallet);
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
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
      if (Platform.isAndroid) {
        const _androidIdPlugin = AndroidId();
        final String? androidId = await _androidIdPlugin.getId();
        await _devicesTable.insert({
          KeyNames.device_id: androidId,
          KeyNames.user_id: user.id,
        });
      }
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
