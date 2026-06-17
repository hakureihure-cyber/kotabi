import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kotabi/data/mock_child_friendly_data.dart';
import 'package:kotabi/models/child_friendly_info.dart';

/// Firestore `child_friendly_places` コレクションから place_id で子連れ情報を取得。
class FirestoreChildFriendlyService {
  FirestoreChildFriendlyService({
    FirebaseFirestore? firestore,
    this.collectionName = 'child_friendly_places',
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final String collectionName;

  bool get isAvailable => _firestore != null;

  /// 複数 place_id を一括取得し、place_id → ChildFriendlyInfo の Map を返す。
  Future<Map<String, ChildFriendlyInfo>> fetchByPlaceIds(List<String> placeIds) async {
    if (placeIds.isEmpty) {
      return {};
    }

    final result = <String, ChildFriendlyInfo>{};

    if (_firestore == null) {
      for (final placeId in placeIds) {
        final mock = mockChildFriendlyByPlaceId[placeId];
        if (mock != null) {
          result[placeId] = mock;
        }
      }
      return result;
    }

    final uniqueIds = placeIds.toSet().toList();
    const batchSize = 10;

    for (var i = 0; i < uniqueIds.length; i += batchSize) {
      final batch = uniqueIds.sublist(
        i,
        i + batchSize > uniqueIds.length ? uniqueIds.length : i + batchSize,
      );

      final snapshot = await _firestore
          .collection(collectionName)
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in snapshot.docs) {
        result[doc.id] = ChildFriendlyInfo.fromFirestore(doc.id, doc.data());
      }
    }

    for (final placeId in placeIds) {
      if (!result.containsKey(placeId)) {
        final mock = mockChildFriendlyByPlaceId[placeId];
        if (mock != null) {
          result[placeId] = mock;
        }
      }
    }

    return result;
  }

  Future<ChildFriendlyInfo?> fetchByPlaceId(String placeId) async {
    final map = await fetchByPlaceIds([placeId]);
    return map[placeId];
  }
}
