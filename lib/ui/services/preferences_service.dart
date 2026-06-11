import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
 
  static const String _darkModeKey = 'isDarkMode';
  static const String _userNameKey = 'userName';

  
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    
    return prefs.getBool(_darkModeKey) ?? true; 
  }

 
  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
    print("Preferencia de pantalla guardada exitosamente");
  }

  
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
   
    return prefs.getString(_userNameKey) ?? 'Nuevo Usuario';
  }

 
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    print("Nombre de usuario guardado exitosamente");
  }
}