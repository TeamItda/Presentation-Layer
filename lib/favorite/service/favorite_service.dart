import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인한 유저 ID
  String get _uid => _auth.currentUser!.uid;

  // Firestore 경로: users/{uid}/favorites/{facilityId}
  CollectionReference get _favoritesRef =>
      _firestore.collection('users').doc(_uid).collection('favorites');

  // ── 즐겨찾기 추가 ──────────────────────────
  Future<void> addFavorite({
    required String facilityId,
    required String name,
    required String category,
    required String address,
    required String distance,
    required double rating,
  }) async {
    await _favoritesRef.doc(facilityId).set({
      'facilityId': facilityId,
      'name': name,
      'category': category,
      'address': address,
      'distance': distance,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── 즐겨찾기 삭제 ──────────────────────────
  Future<void> removeFavorite(String facilityId) async {
    await _favoritesRef.doc(facilityId).delete();
  }

  // ── 즐겨찾기 목록 가져오기 ─────────────────
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final snapshot = await _favoritesRef
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // ── 특정 시설 즐겨찾기 여부 확인 ───────────
  Future<bool> isFavorite(String facilityId) async {
    final doc = await _favoritesRef.doc(facilityId).get();
    return doc.exists;
  }
}