import 'package:flutter/material.dart';
import '../services/local_preferences_services.dart';

class PreferencesViewModel extends ChangeNotifier {
  final LocalPreferencesService _service = LocalPreferencesService();

  bool _isLoading = false;
  String _username = '';
  bool _isDarkMode = true;
  String _favoriteGenre = 'Rock';
  List<String> _ratedAlbums = [];

  bool get isLoading => _isLoading;
  String get username => _username;
  bool get isDarkMode => _isDarkMode;
  String get favoriteGenre => _favoriteGenre;
  List<String> get ratedAlbums => _ratedAlbums;

  PreferencesViewModel() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    _username = _service.getUsername();
    _isDarkMode = _service.isDarkMode();
    _favoriteGenre = _service.getFavoriteGenre();
    _ratedAlbums = _service.getAllRatedAlbums();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUsername(String newUsername) async {
    _username = newUsername;
    await _service.saveUsername(newUsername);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _service.saveDarkMode(value);
    notifyListeners();
  }

  Future<void> updateFavoriteGenre(String newGenre) async {
    _favoriteGenre = newGenre;
    await _service.saveFavoriteGenre(newGenre);
    notifyListeners();
  }

  Future<void> removeAlbum(String albumId) async {
    await _service.deleteRating(albumId);
    _ratedAlbums = _service.getAllRatedAlbums();
    notifyListeners();
  }

  Future<void> refreshAlbums() async {
    _isLoading = true;
    notifyListeners();
    
    _ratedAlbums = _service.getAllRatedAlbums();
    
    _isLoading = false;
    notifyListeners();
  }
}