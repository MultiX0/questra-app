import 'dart:developer';

import 'package:questra_app/core/providers/supabase_provider.dart';
import 'package:questra_app/core/shared/constants/table_names.dart';
import 'package:questra_app/features/quests/models/quest_type_model.dart';
import 'package:questra_app/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final questsRepositoryProvider = Provider<QuestsRepository>((ref) {
  return QuestsRepository(ref: ref);
});

class QuestsRepository {
  final Ref _ref;
  QuestsRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _questTypesTable => _client.from(TableNames.quest_types);

  Future<List<QuestTypeModel>> getAllQuestTypes() async {
    try {
      final data = await _questTypesTable.select('*');
      log("quest types: $data");
      final types = data.map((type) => QuestTypeModel.fromMap(type)).toList();
      return types;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
