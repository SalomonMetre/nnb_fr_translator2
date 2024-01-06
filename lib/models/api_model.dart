import 'package:nnb_fr_translator2/utilities/mixins.dart';

class ApiModel with ApiMixin {
  static final ApiModel instance = ApiModel._();
  ApiModel._();
  factory ApiModel() => instance;

  Future<String?> translate({required String sourceText}) async {
    return await getTranslatedText(sourceText: sourceText);
  }
}
