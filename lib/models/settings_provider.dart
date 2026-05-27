import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'English (US)';

  bool get notificationsEnabled => _notificationsEnabled;
  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }
}
