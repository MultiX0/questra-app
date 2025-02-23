import 'dart:developer';

import 'package:questra_app/imports.dart';

class UpdatesService {
  static final _client = Supabase.instance.client;
  static Future<String> getLastVersionLink() async {
    try {
      final data = await _client
          .from(TableNames.app_versions)
          .select("*")
          .order(KeyNames.created_at, ascending: false)
          .limit(1);
      final url = data.first['url'];
      return url;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
