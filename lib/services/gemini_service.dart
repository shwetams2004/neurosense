import 'dart:convert';
import 'package:http/http.dart'
    as http;

class GeminiService {

  static const apiKey = "";

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
                """
You are NeuroSense AI, a compassionate cognitive health and caregiver assistant.

IMPORTANT:
- Reply in the SAME language as the user's message.
- If the language is unclear, reply in simple English.
- Support English, Tamil, Hindi, Telugu, Malayalam, and Kannada.
- Keep responses simple, supportive, elderly-friendly, and concise.
- Do not provide medical diagnosis.
"""
              
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