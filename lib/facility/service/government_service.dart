import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../model/government_model.dart';

class GovernmentService {
  // Firestore collection name. 데이터를 Firestore에 시드하면 자동으로 사용됨.
  // 컬렉션이 없거나 비어 있으면 로컬 JSON fallback.
  static const String _firestoreCollection = 'jongno_government';

  List<GovernmentModel>? _cache;

  Future<List<GovernmentModel>> fetchGovernments() async {
    if (_cache != null) return _cache!;

    final fromFs = await _fetchFromFirestore();
    if (fromFs.isNotEmpty) {
      _cache = fromFs..sort((a, b) => a.name.compareTo(b.name));
      return _cache!;
    }

    return _loadLocal();
  }

  Future<List<GovernmentModel>> _fetchFromFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_firestoreCollection)
          .get();
      return snap.docs
          .map((d) => GovernmentModel.fromFirestore(d.data(), d.id))
          .where((g) => g.name.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Firestore government fetch skipped: $e');
      return const [];
    }
  }

  Future<List<GovernmentModel>> _loadLocal() async {
    final jsonString =
        await rootBundle.loadString('assets/jongno_government.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rows = decoded['data'] as List<dynamic>;

    _cache = rows
        .whereType<Map<String, dynamic>>()
        .map((e) => GovernmentModel.fromLocal(e))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }

  // 로컬 JSON을 Firestore 컬렉션으로 1회 시드. 호출 시점에 컬렉션이 비어있을 때만 작동.
  // 관리 도구에서 한 번 호출하면 이후엔 자동으로 Firestore 사용.
  Future<void> seedToFirestore() async {
    try {
      final col =
          FirebaseFirestore.instance.collection(_firestoreCollection);
      final existing = await col.limit(1).get();
      if (existing.docs.isNotEmpty) return;

      final locals = await _loadLocal();
      final batch = FirebaseFirestore.instance.batch();
      for (final g in locals) {
        batch.set(col.doc(g.id), {
          'name': g.name,
          'addr': g.addr,
          'lat': g.lat,
          'lng': g.lng,
          'type': g.type,
          'tel': g.tel,
          'homepage': g.homepage,
          'operatingHours': g.operatingHours,
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('seed government to Firestore failed: $e');
    }
  }
}
