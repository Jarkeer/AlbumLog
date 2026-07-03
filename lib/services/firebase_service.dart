import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Future<void> saveReviewToCloud(ReviewModel review, String userId) async {
    try {
      // Usamos un ID compuesto (userId_albumId) para que si el usuario
      // vuelve a reseñar el mismo disco, simplemente se actualice el documento
      final docId = '${userId}_${review.albumId}';
      
      await _db.collection('reviews').doc(docId).set({
        ...review.toMap(),
        'userId': userId, 
        'createdAt': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      throw Exception('Error al guardar en la nube: $e');
    }
  }
}