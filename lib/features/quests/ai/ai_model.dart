import 'dart:convert';
import 'dart:developer';
import 'package:questra_app/imports.dart';
import 'package:dio/dio.dart';

final _apiKey = dotenv.env['LLAMA3_KEY'] ?? "";
final _deepinfra_api = dotenv.env['DEEPINFRA_API'] ?? "";

final aiModelObjectProvider = Provider<AiModel>((ref) => AiModel(ref: ref));

class AiModel {
  AiModel({required Ref ref});

  final dio = Dio();
  final _options = Options(
    headers: {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    },
  );

  Future<Response<dynamic>> makeAiResponse({
    int? maxTokens,
    required List<Map<String, dynamic>> content,
  }) async {
    try {
      return await dio.post(
        _deepinfra_api,
        options: _options,
        data: jsonEncode({
          "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo",
          "messages": content,
          "temperature": 0.0,
          "top_p": 0.9,
          "top_k": 50,
          "max_tokens": maxTokens ?? 500,
          "frequency_penalty": 0.0,
          "presence_penalty": 0.0,
          "stop": ["}"],
        }),
      );
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
    }
  }
}
