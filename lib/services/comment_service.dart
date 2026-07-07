import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addComment({
    required String ownerId,
    required String reviewId,
    required CommentModel comment,
  }) async {
    await _db
        .collection('users')
        .doc(ownerId)
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .doc(comment.commentId)
        .set({
      ...comment.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<CommentModel>> getComments({
    required String ownerId,
    required String reviewId,
  }) {
    return _db
        .collection('users')
        .doc(ownerId)
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .orderBy(
          'createdAt',
          descending: false,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CommentModel.fromMap(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> deleteComment({
    required String ownerId,
    required String reviewId,
    required String commentId,
  }) async {
    await _db
        .collection('users')
        .doc(ownerId)
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}