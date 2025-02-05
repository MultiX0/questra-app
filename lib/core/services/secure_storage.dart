import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureLocalStorage implements LocalStorage {
  final FlutterSecureStorage _secureStorage;
  static const _sessionKey = 'supabase_session';

  // We'll store the session in memory so we can provide synchronous getters.
  String? _session;

  SecureLocalStorage([FlutterSecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// The access token getter returns the current session string.

  /// Indicates whether a session (access token) is available.

  /// Initializes the storage by attempting to read a previously persisted session.
  @override
  Future<void> initialize() async {
    _session = await _secureStorage.read(key: _sessionKey);
  }

  /// Persists the given session (access token) to secure storage.
  @override
  Future<void> persistSession(String session) async {
    _session = session;
    await _secureStorage.write(key: _sessionKey, value: session);
  }

  @override
  Future<void> removePersistedSession() async {
    _session = null;
    await _secureStorage.delete(key: _sessionKey);
  }

  Future<String?> read(String key) {
    return _secureStorage.read(key: key);
  }

  Future<void> write(String key, String value) {
    return _secureStorage.write(key: key, value: value);
  }

  Future<void> delete(String key) {
    return _secureStorage.delete(key: key);
  }

  @override
  Future<String?> accessToken() async {
    return _session;
  }

  @override
  Future<bool> hasAccessToken() async {
    return _session != null;
  }
}
