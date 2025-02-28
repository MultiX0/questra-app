import 'dart:developer';

import 'package:questra_app/core/services/android_id_service.dart';
import 'package:questra_app/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static final _client = Supabase.instance.client;
  static SupabaseQueryBuilder get _devicesTable => _client.from(TableNames.player_devices);

  static Future<void> checkDevice(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = await AndroidId().getId();
      final storedId = prefs.getBool(id ?? "");
      if (storedId == null || !storedId) {
        final data = await _devicesTable.select('*').eq(KeyNames.device_id, id!).maybeSingle();
        if (data != null) {
          prefs.setBool(id, true);
          return;
        }

        await _devicesTable.insert({
          KeyNames.device_id: id,
          KeyNames.user_id: userId,
        });
      }
      return;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
