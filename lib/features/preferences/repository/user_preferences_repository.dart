import 'dart:developer';

import 'package:questra_app/core/shared/constants/key_names.dart';
import 'package:questra_app/core/shared/constants/table_names.dart';
import 'package:questra_app/features/preferences/models/user_preferences_model.dart';
import 'package:questra_app/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userPreferencesRepositoryProvider =
    Provider<UserPreferencesRepository>((ref) => UserPreferencesRepository(ref: ref));

class UserPreferencesRepository {
  final Ref _ref;
  UserPreferencesRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _prefsTable => _client.from(TableNames.user_preferences);

  Future<void> insertPreferences(UserPreferencesModel prefs) async {
    try {
      await _prefsTable.insert(prefs.toMap());
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<UserPreferencesModel?> getUserPreferences(String user_id) async {
    try {
      final data = await _prefsTable.select("*").eq(KeyNames.user_id, user_id).maybeSingle();
      if (data != null) {
        return UserPreferencesModel.fromMap(data);
      }

      return null;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
