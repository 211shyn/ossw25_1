import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> summarizeText(String inputText) async {
  const String apiUrl = 'https://api-inference.huggingface.co/models/sshleifer/distilbart-cnn-12-6';
  const String apiToken = '본인 api token 발급받아서 출력하기';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'inputs': inputText}),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    return result[0]['summary_text'];
  } else {
    throw Exception('Failed to summarize: ${response.body}');
  }
}