import 'package:flutter/material.dart';
import 'package:album_log/services/preferences_services.dart';

class PreferencesViewModel extends ChangeNotifier {
  final PreferencesService _prefsService = PreferencesService();

  bool _isDarkMode = true;
  String _userName = '';
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  bool get isLoading => _isLoading;


  PreferencesViewModel() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners(); 

    _isDarkMode = await _prefsService.getThemeMode();
    _userName = await _prefsService.getUserName();

    _isLoading = false;
    notifyListeners(); 
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners(); 
    await _prefsService.saveThemeMode(isDark); 
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    notifyListeners();
    await _prefsService.saveUserName(name);
  }
}