import 'dart:developer';

import 'package:questra_app/imports.dart';

class ExceptionService {
  static final _clinet = Supabase.instance.client;
  static SupabaseQueryBuilder get _exceptionsTable => _clinet.from(TableNames.app_exception);

  static Future<void> insertException({
    required String path,
    required String error,
    required String userId,
  }) async {
    try {
      await _exceptionsTable.insert({
        'path': path,
        KeyNames.user_id: userId,
        'exception': error,
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
