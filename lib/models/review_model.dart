class ReviewModel {
  final String albumId;
  final String albumTitle;
  final int rating;
  final String? reviewText; 

  ReviewModel({
    required this.albumId,
    required this.albumTitle,
    required this.rating,
    this.reviewText,
  });

  Map<String, dynamic> toMap() {
    return {
      'albumId': albumId,
      'albumTitle': albumTitle,
      'rating': rating,
      'reviewText': reviewText ?? ''
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      albumId: map['albumId']?.toString() ?? '',
      albumTitle: map['albumTitle']?.toString() ?? 'Sin título',
      rating: map['rating'] is int
          ? map['rating']
          : int.tryParse(map['rating']?.toString() ?? '0') ?? 0,
      reviewText: map['reviewText']?.toString(),
    );
  }
}