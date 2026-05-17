import 'dart:convert';

import 'package:http/http.dart'
    as http;

class GeminiService {
  static const String apiKey =
      "";

  static Future<String> sendMessage(
    String message,
  ) async {
    try {
      final url = Uri.parse(
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
);

      final response =
          await http.post(
        url,
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      """
You are NeuroSense AI.

You help caregivers and clinicians understand:
- memory decline
- dementia risk
- attention issues
- executive dysfunction
- cognitive health monitoring

Keep answers:
- short
- clinically safe
- helpful
- non-diagnostic

User Question:
$message
""",
                }
              ]
            }
          ]
        }),
      );

      print(response.body);

      if (response.statusCode ==
          200) {
        final data =
            jsonDecode(response.body);

        return data["candidates"][0]
                    ["content"]["parts"]
                [0]["text"] ??
            "No response.";
      }

      return "API Error: ${response.statusCode}";
    } catch (e) {
      return "Error: $e";
    }
  }
}