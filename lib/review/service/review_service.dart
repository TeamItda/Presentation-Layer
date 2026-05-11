import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인한 유저 ID
  String get _uid => _auth.currentUser!.uid;

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
    await _reviewsRef.add({
      'facilityId': facilityId,
      'facilityName': facilityName,
      'uid': _uid,
      'userName': _auth.currentUser?.displayName ?? '익명',
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
    final snapshot = await _reviewsRef
        .where('uid', isEqualTo: _uid)
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