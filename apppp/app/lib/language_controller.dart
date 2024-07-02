import 'package:get/get.dart';

class LanguageController extends GetxController {
  var locale = 'en'.obs; // Default language is English

  void changeLanguage(String languageCode) {
    locale.value = languageCode;
    // You can implement logic to load language settings here
    // For simplicity, I'm just changing the locale value
  }

  String getLanguage() {
    return locale.value;
  }
}
