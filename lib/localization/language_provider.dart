import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale('tr');

  Locale get locale => _locale;

  Future<void> loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language') ?? 'tr';

    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String localeCode) async {
    _locale = Locale(localeCode);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}
