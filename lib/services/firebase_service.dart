import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveReviewToCloud(
    ReviewModel review,
    String userId,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('reviews')
          .doc(review.reviewId)
          .set({
        ...review.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al guardar la reseña: $e');
    }
  }

  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo reseñas: $e');
    }
  }

  Future<void> deleteReview(
    String userId,
    String reviewId,
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }

  Future<void> addComment({
    required String ownerUid,
    required String reviewId,
    required String commenterUid,
    required String commenterName,
    required String text,
  }) async {
    await _db
        .collection('users')
        .doc(ownerUid)
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .add({
      'commenterUid': commenterUid,
      'commenterName': commenterName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getComments(
    String ownerUid,
    String reviewId,
  ) {
    return _db
        .collection('users')
        .doc(ownerUid)
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> deleteComment({
    required String ownerUid,
    required String reviewId,
    required String commentId,
  }) async {
    await _db
        .collection('users')
        .doc(ownerUid)
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}