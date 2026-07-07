import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String albumId;
  final String albumTitle;
  final int rating;
  final String? reviewText;
  final Timestamp? createdAt;

  ReviewModel({
    required this.reviewId,
    required this.albumId,
    required this.albumTitle,
    required this.rating,
    this.reviewText,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'albumId': albumId,
      'albumTitle': albumTitle,
      'rating': rating,
      'reviewText': reviewText ?? '',
      'createdAt': createdAt,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId']?.toString() ?? '',
      albumId: map['albumId']?.toString() ?? '',
      albumTitle: map['albumTitle']?.toString() ?? 'Sin título',
      rating: map['rating'] is int
          ? map['rating']
          : int.tryParse(map['rating']?.toString() ?? '0') ?? 0,
      reviewText: map['reviewText']?.toString(),
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  ReviewModel copyWith({
    String? reviewId,
    String? albumId,
    String? albumTitle,
    int? rating,
    String? reviewText,
    Timestamp? createdAt,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      albumId: albumId ?? this.albumId,
      albumTitle: albumTitle ?? this.albumTitle,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}