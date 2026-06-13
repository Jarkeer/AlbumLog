import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesService {
  static final LocalPreferencesService _instance = LocalPreferencesService._internal();
  factory LocalPreferencesService() => _instance;
  LocalPreferencesService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }



  Future<void> saveAlbumRating(String albumId, int rating) async {
    await _prefs?.setInt(albumId, rating);
  }

  int getAlbumRating(String albumId) {
  // Obtenemos el valor bruto de la memoria sin forzar que sea un número (getInt)
  final value = _prefs?.get(albumId);

  // Comprobamos si el valor es realmente un número entero (int)
  if (value is int) {
    return value;
  }

  // Si es un texto (como "username") o no existe, retornamos 0 estrellas
  return 0;
}
  List<String> getAllRatedAlbums() {
    final keys = _prefs?.getKeys() ?? {};
    return keys.where((key) => 
      key != 'favorite_genre' && 
      key != 'username' && 
      key != 'is_dark_mode'
    ).toList();
  }

  Future<void> deleteRating(String albumId) async {
    await _prefs?.remove(albumId);
  }

  

  Future<void> saveUsername(String username) async {
    await _prefs?.setString('username', username);
  }

  String getUsername() {
    return _prefs?.getString('username') ?? 'Melómano';
  }

  Future<void> saveDarkMode(bool isDarkMode) async {
    await _prefs?.setBool('is_dark_mode', isDarkMode);
  }

  bool isDarkMode() {
    return _prefs?.getBool('is_dark_mode') ?? true; 
  }

  Future<void> saveFavoriteGenre(String genre) async {
    await _prefs?.setString('favorite_genre', genre);
  }

  String getFavoriteGenre() {
    return _prefs?.getString('favorite_genre') ?? 'Rock';
  }
}