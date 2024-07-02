// LanguageManager.dart
class LanguageManager {
  bool isEnglish = true;

  void toggleLanguage() {
    isEnglish = !isEnglish;
  }

  String getLabelText(String englishText, String punjabiText) {
    return isEnglish ? englishText : punjabiText;
  }

  String getButtonText(String englishText, String punjabiText) {
    return isEnglish ? englishText : punjabiText;
  }
}
