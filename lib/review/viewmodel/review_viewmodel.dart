import 'package:flutter/material.dart';
import '../service/review_service.dart';

class ReviewItem {
  final String id;
  final String facilityId;
  final String facilityName;
  final String category;
  final int rating;
  final String content;
  final String userName;
  final DateTime? createdAt;

  const ReviewItem({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.category,
    required this.rating,
    required this.content,
    required this.userName,
    this.createdAt,
  });

  factory ReviewItem.fromMap(Map<String, dynamic> map) {
    return ReviewItem(
      id: map['id'] ?? '',
      facilityId: map['facilityId'] ?? '',
      facilityName: map['facilityName'] ?? '',
      category: map['category'] ?? '',
      rating: map['rating'] ?? 0,
      content: map['content'] ?? '',
      userName: map['userName'] ?? '익명',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  // 날짜 포맷 (2025.12.08)
  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.year}.${createdAt!.month.toString().padLeft(2, '0')}.${createdAt!.day.toString().padLeft(2, '0')}';
  }
}

class ReviewViewModel extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  // ── 상태 변수 ──────────────────────────────
  List<ReviewItem> _reviews = [];        // 시설 전체 후기
  List<ReviewItem> _myReviews = [];      // 내가 쓴 후기
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // ── Getter ─────────────────────────────────
  List<ReviewItem> get reviews => _reviews;
  List<ReviewItem> get myReviews => _myReviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // ── 특정 시설 후기 불러오기 ────────────────
  Future<void> loadReviews(String facilityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _reviewService.getReviews(facilityId);
      _reviews = data.map((e) => ReviewItem.fromMap(e)).toList();
    } catch (e) {
      _errorMessage = '후기를 불러오지 못했어요';
      debugPrint('후기 로딩 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 내가 쓴 후기 불러오기 ──────────────────
  Future<void> loadMyReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _reviewService.getMyReviews();
      _myReviews = data.map((e) => ReviewItem.fromMap(e)).toList();
    } catch (e) {
      _errorMessage = '후기를 불러오지 못했어요';
      debugPrint('내 후기 로딩 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 후기 작성 ──────────────────────────────
  Future<bool> submitReview({
    required String facilityId,
    required String facilityName,
    required int rating,
    required String content,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _reviewService.addReview(
        facilityId: facilityId,
        facilityName: facilityName,
        rating: rating,
        content: content,
      );
      return true; // 성공
    } catch (e) {
      debugPrint('후기 작성 실패: $e');
      return false; // 실패
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── 후기 삭제 ──────────────────────────────
  Future<void> deleteReview(String reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      _myReviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();
    } catch (e) {
      debugPrint('후기 삭제 실패: $e');
    }
  }
}