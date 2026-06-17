import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kotabi/config/google_maps_config.dart';
import 'package:kotabi/data/mock_child_friendly_data.dart';
import 'package:kotabi/data/mock_facilities.dart';
import 'package:kotabi/models/facility.dart';
import 'package:kotabi/models/search_criteria.dart';
import 'package:kotabi/services/facility_merger.dart';
import 'package:kotabi/services/firebase_bootstrap.dart';
import 'package:kotabi/services/firestore_child_friendly_service.dart';
import 'package:kotabi/services/places_api_service.dart';

/// Google Places API と Firestore（子連れ情報）を place_id で紐づけるリポジトリ。
class FacilityRepository {
  FacilityRepository({
    PlacesApiService? placesApi,
    FirestoreChildFriendlyService? childFriendlyService,
  })  : _placesApi = placesApi ?? PlacesApiService(),
        _childFriendlyService = childFriendlyService ??
            FirestoreChildFriendlyService(
              firestore: FirebaseBootstrap.isInitialized
                  ? FirebaseFirestore.instance
                  : null,
            );

  final PlacesApiService _placesApi;
  final FirestoreChildFriendlyService _childFriendlyService;

  /// 施設一覧を取得し、検索条件でフィルタリングする。
  Future<List<Facility>> searchFacilities({
    required SearchCriteria criteria,
  }) async {
    final all = await _fetchAll(criteria);
    return all.where(criteria.matches).toList();
  }

  Future<List<Facility>> _fetchAll(SearchCriteria criteria) async {
    if (!GoogleMapsConfig.isConfigured) {
      return _mockMergedFacilities();
    }

    try {
      final places = await _placesApi.searchText(textQuery: criteria.placesSearchQuery);
      if (places.isEmpty) {
        return _mockMergedFacilities();
      }

      final placeIds = places.map((place) => place.placeId).toList();
      final childFriendlyMap = await _childFriendlyService.fetchByPlaceIds(placeIds);

      return places
          .map(
            (place) => FacilityMerger.merge(
              place: place,
              childFriendly: childFriendlyMap[place.placeId],
            ),
          )
          .toList();
    } catch (_) {
      return _mockMergedFacilities();
    }
  }

  /// place_id から施設を復元（保存済みプラン読み込み用）。
  Future<Facility?> getByPlaceId(String placeId) async {
    if (GoogleMapsConfig.isConfigured) {
      final place = await _placesApi.getPlaceDetails(placeId);
      if (place != null) {
        final childFriendly = await _childFriendlyService.fetchByPlaceId(placeId);
        return FacilityMerger.merge(place: place, childFriendly: childFriendly);
      }
    }

    for (final facility in _mockMergedFacilities()) {
      if (facility.id == placeId) {
        return facility;
      }
    }
    return null;
  }

  Future<List<Facility>> resolveByPlaceIds(List<String> placeIds) async {
    final facilities = <Facility>[];
    for (final placeId in placeIds) {
      final facility = await getByPlaceId(placeId);
      if (facility != null) {
        facilities.add(facility);
      }
    }
    return facilities;
  }

  List<Facility> _mockMergedFacilities() {
    return mockFacilities.map((facility) {
      final childFriendly = mockChildFriendlyByPlaceId[facility.id];
      if (childFriendly == null) {
        return facility;
      }

      return Facility(
        id: facility.id,
        placeId: facility.placeId,
        name: facility.name,
        conditions: childFriendly.toConditionLabels(),
        stayMinutes: childFriendly.stayMinutes ?? facility.stayMinutes,
        travelMinutes: facility.travelMinutes,
        rating: facility.rating,
        reviewCount: facility.reviewCount,
        icon: facility.icon,
        color: facility.color,
        address: facility.address,
        hours: facility.hours,
        closedDays: facility.closedDays,
        phone: facility.phone,
        reviewSummary: childFriendly.reviewSummary.isNotEmpty
            ? childFriendly.reviewSummary
            : facility.reviewSummary,
        latitude: facility.latitude,
        longitude: facility.longitude,
        dataSource: FacilityDataSource.googlePlaces,
      );
    }).toList();
  }
}
