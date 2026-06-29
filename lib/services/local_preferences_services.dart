import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';

class LocalPreferencesService {
  
  // Claves para las preferencias simples
  static const String _darkModeKey = 'isDarkMode';
  static const String _userNameKey = 'userName';
  static const String _favoriteGenreKey = 'favoriteGenre';
  static const String _reviewsKey = 'mis_resenas';


  // PREFERENCIAS DE USUARIO 


  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? true; 
  }

  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Nuevo Usuario';
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<String> getFavoriteGenre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_favoriteGenreKey) ?? 'Rock';
  }

  Future<void> saveFavoriteGenre(String genre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoriteGenreKey, genre);
  }

  // SISTEMA DE RESEÑAS Y CALIFICACIONES

  // NUEVO: Guardar la reseña completa convirtiendo el modelo a JSON
  Future<void> saveAlbumReview(ReviewModel review) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedReviewsStr = prefs.getStringList(_reviewsKey) ?? [];
    
    // Eliminamos la reseña anterior de este mismo disco 
    savedReviewsStr.removeWhere((item) {
      try {
        final map = jsonDecode(item);
        return map['albumId'] == review.albumId;
      } catch (e) {
        debugPrint("JSON corrupto al eliminar: $e");
        return true;
      }
    });
    
    // Agregamos la nueva reseña
    savedReviewsStr.add(jsonEncode(review.toMap()));
    await prefs.setStringList(_reviewsKey, savedReviewsStr);
  }

  // NUEVO: Obtener todas las reseñas como lista de ReviewModel
  Future<List<ReviewModel>> getAllSavedReviews() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedReviewsStr = prefs.getStringList(_reviewsKey) ?? [];

    List<ReviewModel> reviews = [];

    for (String item in savedReviewsStr) {
      try {
        final map = jsonDecode(item);
        reviews.add(ReviewModel.fromMap(map));
      } catch (e) {
        debugPrint("Error leyendo reseña: $e");
      }
    }

    return reviews;
  }


  Future<int> getAlbumRating(String albumId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedReviewsStr = prefs.getStringList(_reviewsKey) ?? [];
    
    for (String item in savedReviewsStr) {
      try {
        final map = jsonDecode(item);

        if (map['albumId'] == albumId) {
          return map['rating'] as int;
        }
      } catch (e) {
        debugPrint("Error leyendo rating: $e");
      }
    }
    return 0; // Retorna 0 si no lo ha calificado
  }

  
  Future<void> deleteRating(String albumId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedReviewsStr = prefs.getStringList(_reviewsKey) ?? [];

    savedReviewsStr.removeWhere((item) {
      try {
        final map = jsonDecode(item);
        return map['albumId'] == albumId;
      } catch (e) {
        debugPrint("Error borrando rating: $e");
        return true;
      }
    });
    
    await prefs.setStringList(_reviewsKey, savedReviewsStr);
  }
}