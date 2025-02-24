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

  Future<String> makeAiResponse({
    int? maxTokens,
    required List<Map<String, dynamic>> content,
  }) async {
    try {
      log("using llama 3.2-11b...");
      final res = await dio.post(
        _deepinfra_api,
        options: _options,
        data: jsonEncode({
          // "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo",
          // "model": "meta-llama/Meta-Llama-3.1-8B-Instruct",
          "model": "meta-llama/Llama-3.2-11B-Vision-Instruct",

          "messages": content,
          "temperature": 0.0,
          "top_p": 0.8,
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
