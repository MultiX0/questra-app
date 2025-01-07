import 'dart:async';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:questra_app/core/providers/accounts_provider.dart';
import 'package:questra_app/core/providers/supabase_provider.dart';
import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/core/shared/constants/table_names.dart';
import 'package:questra_app/features/auth/models/user_model.dart';
import 'package:questra_app/imports.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serverClientId = dotenv.env['SERVERCLIENTID'] ?? '';
final clientId = dotenv.env['CLIENTID'] ?? '';

final authStateProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref: ref);
});

final isLoggedInProvider = StateProvider<bool>((ref) {
  return false;
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
    ]).listen((events) async {
      final userEvent = events[0].isNotEmpty ? events[0].first : null;
      log("the user event is $userEvent");

      if (userEvent == null) {
        state = UserModel(
          id: _supabase.auth.currentUser?.id ?? '',
          name: '',
          username: '',
          joined_at: DateTime.now(),
          avatar: '',
          is_online: false,
        );
        _stateStreamController.add(state);
      }

      if (userEvent != null && userEvent.isNotEmpty) {
        final user = UserModel.fromMap(userEvent);
        if (state != user && user.id.isNotEmpty) {
          state = user;
          log("the user data is updated");
        }
        _stateStreamController.add(state);
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

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _userSubscription.cancel();
    _stateStreamController.close();
    super.dispose();
  }
}
