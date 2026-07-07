import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String userId;
  final String userName;
  final String photoUrl;
  final String comment;
  final Timestamp? createdAt;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.photoUrl,
    required this.comment,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'userId': userId,
      'userName': userName,
      'photoUrl': photoUrl,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'],
    );
  }
}