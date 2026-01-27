import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class GeminiService {
  static const String apiKey = '';
  // Note: Gemini 2.5 is not released yet; usually it's gemini-1.5-flash
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // 🔥 UPDATED SYSTEM PROMPT - HEALTH, HISTORY, LAW, WEATHER, ANIMALS
  static const String systemPrompt = '''You are an expert assistant specialized in specific topics. 
You ONLY answer questions about:
1. Health & Wellness
2. Philippine History
3. Traffic Law Enforcement
4. Philippine Law
5. Animals & Weather

RULES:
1. Provide accurate information regarding Philippine Laws and Traffic rules 🚦.
2. For Health questions, always include a disclaimer to consult a professional 🏥.
3. If someone asks about Programming (Flutter, Python, etc.), Math, or unrelated topics -> RESPOND: "I am specialized in Health, History, Law, and Nature. Please ask me about those topics."
4. Be concise and informative.
5. Use emojis for clarity 🐾🌦️⚖️.

SCOPE: Health, History, Traffic/Philippine Law, Animals, and Weather ONLY''';

  static List<Map<String, dynamic>> _formatMessages(
      List<ChatMessage> messages,
      ) {
    return messages.map((msg) {
      return {
        'role': msg.role,
        'parts': [{'text': msg.text}],
      };
    }).toList();
  }

  static Future<String> sendMultiTurnMessage(
      List<ChatMessage> conversationHistory,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': _formatMessages(conversationHistory),
          'system_instruction': {
            'parts': [{'text': systemPrompt}]
          },
          'generationConfig': {
            'temperature': 0.7,
            'topK': 1,
            'topP': 1,
            'maxOutputTokens': 1500, // Reduced for faster responses
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        return 'Error: ${response.statusCode} - $errorMessage';
      }
    } catch (e) {
      return 'Network Error: $e';
    }
  }
}