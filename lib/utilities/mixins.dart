import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nnb_fr_translator2/utilities/api.dart';

extension on String {
  String get padded => "translate Nande to French: $this target: ";
}

mixin ApiMixin {
  Future<String?> getTranslatedText({required String sourceText}) async {
    final url = Uri.parse(ApiConstants.apiEndpoint);
    final body = '{"inputs": "${sourceText.padded}"}';
    try {
      final response = await http.post(
        url,
        headers: ApiConstants.headers,
        body: body,
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final translationText = jsonResponse[0]['translation_text'];
        return translationText;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
