import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String facilityId;
  final String facilityName;
  final String category;
  final String uid;
  final String userName;
  final int rating;
  final String content;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.category,
    required this.uid,
    required this.userName,
    required this.rating,
    required this.content,
    this.createdAt,
  });

  // Firestore 문서 → ReviewModel
  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      facilityId: map['facilityId'] ?? '',
      facilityName: map['facilityName'] ?? '',
      category: map['category'] ?? '',
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '익명',
      rating: map['rating'] ?? 0,
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ReviewModel → Firestore 저장용 Map
  Map<String, dynamic> toMap() {
    return {
      'facilityId': facilityId,
      'facilityName': facilityName,
      'category': category,
      'uid': uid,
      'userName': userName,
      'rating': rating,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // 날짜 포맷 (2025.12.08)
  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.year}.'
        '${createdAt!.month.toString().padLeft(2, '0')}.'
        '${createdAt!.day.toString().padLeft(2, '0')}';
  }
}