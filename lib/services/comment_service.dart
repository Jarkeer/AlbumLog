import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addComment({
    required String reviewOwnerUid,
    required String reviewId,
    required String senderUid,
    required String senderName,
    required String text,
  }) async {
    await _firestore
        .collection('users')
        .doc(reviewOwnerUid)
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .add({
      'senderUid': senderUid,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getComments(
    String reviewOwnerUid,
    String reviewId,
  ) {
    return _firestore
        .collection('users')
        .doc(reviewOwnerUid)
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .orderBy('timestamp')
        .snapshots();
  }
}