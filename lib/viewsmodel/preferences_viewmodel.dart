import 'package:flutter/material.dart';
import '../models/review_model.dart'; 
import '../services/local_preferences_services.dart';

class PreferencesViewModel extends ChangeNotifier {
  final LocalPreferencesService _service = LocalPreferencesService();

  bool _isLoading = false;
  String _username = '';
  bool _isDarkMode = true;
  String _favoriteGenre = 'Rock';
  List<ReviewModel> _savedReviews = [];

  bool get isLoading => _isLoading;
  String get username => _username;
  bool get isDarkMode => _isDarkMode;
  String get favoriteGenre => _favoriteGenre;
  List<ReviewModel> get savedReviews => _savedReviews;

  PreferencesViewModel() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    _isLoading = true;
  
    _username = await _service.getUserName();
    _isDarkMode = await _service.getDarkMode();
    _favoriteGenre = await _service.getFavoriteGenre();
    _savedReviews = await _service.getAllSavedReviews();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUsername(String newUsername) async {
    _username = newUsername;
    await _service.saveUserName(newUsername);
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

  Future<void> saveReview(ReviewModel review) async {
    try {
      await _service.saveAlbumReview(review);
      await refreshAlbums(); 
    } catch (e) {
      debugPrint('Error al guardar la reseña: $e');
    }
  }

  Future<void> removeAlbum(String albumId) async {
    await _service.deleteRating(albumId); 
    await refreshAlbums();
  }

  Future<void> refreshAlbums() async {
    _isLoading = true;
    notifyListeners();
    
    _savedReviews = await _service.getAllSavedReviews();
    
    _isLoading = false;
    notifyListeners();
  }
}