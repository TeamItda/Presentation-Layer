import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자 확보. 비로그인 상태면 익명 로그인으로 자동 전환.
  Future<User> _ensureUser() async {
    final cur = _auth.currentUser;
    if (cur != null) return cur;
    final cred = await _auth.signInAnonymously();
    final user = cred.user;
    if (user == null) {
      throw StateError('Firebase Auth 사용자 정보를 가져오지 못했습니다.');
    }
    return user;
  }

  // Firestore 경로: reviews/{reviewId}
  CollectionReference get _reviewsRef =>
      _firestore.collection('reviews');

  // ── 후기 작성 ──────────────────────────────
  Future<void> addReview({
    required String facilityId,
    required String facilityName,
    required int rating,
    required String content,
  }) async {
    final user = await _ensureUser();
    await _reviewsRef.add({
      'facilityId': facilityId,
      'facilityName': facilityName,
      'uid': user.uid,
      'userName': user.displayName ?? '익명',
      'rating': rating,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── 특정 시설 전체 후기 가져오기 ───────────
  Future<List<Map<String, dynamic>>> getReviews(String facilityId) async {
    final snapshot = await _reviewsRef
        .where('facilityId', isEqualTo: facilityId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // ── 내가 쓴 후기 가져오기 ──────────────────
  Future<List<Map<String, dynamic>>> getMyReviews() async {
    final user = _auth.currentUser;
    if (user == null) return const [];
    final snapshot = await _reviewsRef
        .where('uid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // ── 후기 삭제 ──────────────────────────────
  Future<void> deleteReview(String reviewId) async {
    await _reviewsRef.doc(reviewId).delete();
  }
}