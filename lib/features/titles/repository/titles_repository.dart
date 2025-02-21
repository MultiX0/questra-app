import 'dart:developer';

import 'package:questra_app/features/titles/models/player_title_model.dart';
import 'package:questra_app/imports.dart';

final titlesRepositoryProvider = Provider<TitlesRepository>((ref) => TitlesRepository(ref: ref));

class TitlesRepository {
  final Ref _ref;
  TitlesRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _titlesTable => _client.from(TableNames.player_titles);
  SupabaseQueryBuilder get _playersTable => _client.from(TableNames.players);

  Future<List<PlayerTitleModel>> getAllTitles(String userId) async {
    try {
      final data = await _titlesTable.select("*").eq(KeyNames.user_id, userId);
      return data.map((title) => PlayerTitleModel.fromMap(title)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleTitleChange({String? id, required String userId}) async {
    try {
      await _playersTable.update({KeyNames.active_title: id}).eq(KeyNames.id, userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> haveTitle({required String userId, required String title}) async {
    try {
      final data = await _titlesTable
          .select("*")
          .eq(KeyNames.user_id, userId)
          .eq(KeyNames.title, title.trim());

      return data.isNotEmpty;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
