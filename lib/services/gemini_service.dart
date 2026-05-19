import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart'
    as http;

class GeminiService {

  static final apiKey =
    dotenv.env[
        "OPENROUTER_API_KEY"] ??
    "";

  static Future<String>
      sendMessage(
    String message,
  ) async {

    final url = Uri.parse(
      "https://openrouter.ai/api/v1/chat/completions",
    );

    final response =
        await http.post(

      url,

      headers: {

        "Authorization":
            "Bearer $apiKey",

        "Content-Type":
            "application/json",
      },

      body: jsonEncode({

        "model":
            "deepseek/deepseek-chat",

        "messages": [

          {
            "role": "system",

            "content":
                "You are NeuroSense AI, a compassionate cognitive health and caregiver assistant.",
          },

          {
            "role": "user",

            "content":
                message,
          }
        ],
      }),
    );

    if (response.statusCode ==
        200) {

      final data =
          jsonDecode(response.body);

      return data["choices"][0]
          ["message"]["content"];
    }

    return "API Error: ${response.statusCode}";
  }
}