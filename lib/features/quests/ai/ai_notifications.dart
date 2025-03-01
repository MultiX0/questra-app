import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:questra_app/imports.dart';

final _apiKey = dotenv.env['LLAMA3_KEY'] ?? "";
final _deepinfra_api = dotenv.env['DEEPINFRA_API'] ?? "";

class AiNotifications {
  static final dio = Dio();
  static final _options = Options(
    headers: {'Authorization': 'Bearer $_apiKey', 'Content-Type': 'application/json'},
  );

  static Future<String> makeAiResponse({
    int? maxTokens,
    double? temp,
    double? topP,
    required List<Map<String, dynamic>> content,
  }) async {
    try {
      final res = await dio.post(
        _deepinfra_api,
        options: _options,
        data: jsonEncode({
          "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo",
          "messages": content,
          "temperature": temp ?? 0.0,
          "top_p": topP ?? 0.7,
          "top_k": 30,
          "max_tokens": maxTokens ?? 700,
          "frequency_penalty": 0.0,
          "presence_penalty": 0.0,
        }),
      );
      return res.data['choices'][0]['message']['content'].toString();
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
    }
  }
}
