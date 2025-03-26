import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:questra_app/core/encrypt/encrypt.dart';
import 'package:questra_app/features/notifications/repository/notifications_repository.dart';
import 'package:questra_app/imports.dart';

class NotificationsController {
  static final Dio _dio = Dio();
  static NotificationsRepository get _repo => NotificationsRepository();

  static Future<List<dynamic>> getUserFCMTokens(String userId) async {
    try {
      return await _repo.getUserFCMTokens(userId);
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(appError);
      rethrow;
    }
  }

  static Future<dynamic> sendNotificaction({
    required String userId,
    required String content,
    required String title,
  }) async {
    try {
      final token = await (getUserFCMTokens(userId));

      final body = {
        'token': token.first[KeyNames.token].toString().trim(),
        'title': title,
        'body': content,
      };
      final headers = await generateAuthHeaders(dotenv.env['NOTIFICATION_SERVERLESS_API_KEY']!);
      final options = Options(headers: headers);
      final res = await _dio.post(
        dotenv.env['NOTIFICATION_API'] ?? "",
        options: options,
        data: jsonEncode(body),
      );
      if (res.statusCode! >= 200 && res.statusCode! <= 299) {
        log(res.data.toString());
        return res.data;
      }
      log(DioException(requestOptions: res.requestOptions).toString());
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      // CustomToast.systemToast(appError);
      return;
    }
  }
}
