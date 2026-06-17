import 'dart:convert';

import 'package:kotabi/models/facility.dart';
import 'package:kotabi/models/plan_preferences.dart';
import 'package:kotabi/services/facility_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanRepository {
  PlanRepository({FacilityRepository? facilityRepository})
      : _facilityRepository = facilityRepository ?? FacilityRepository();

  final FacilityRepository _facilityRepository;

  static const _facilityIdsKey = 'plan_facility_ids';
  static const _facilitiesJsonKey = 'plan_facilities_json';
  static const _preferencesKey = 'plan_preferences';

  Future<({List<Facility> facilities, PlanPreferences preferences})> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawPreferences = prefs.getString(_preferencesKey);

    final preferences = rawPreferences == null
        ? const PlanPreferences()
        : PlanPreferences.fromJson(
            jsonDecode(rawPreferences) as Map<String, dynamic>,
          );

    final rawFacilitiesJson = prefs.getString(_facilitiesJsonKey);
    if (rawFacilitiesJson != null) {
      final list = (jsonDecode(rawFacilitiesJson) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(Facility.fromJson)
          .toList();
      if (list.isNotEmpty) {
        return (facilities: list, preferences: preferences);
      }
    }

    final rawIds = prefs.getString(_facilityIdsKey);
    if (rawIds == null) {
      return (facilities: <Facility>[], preferences: preferences);
    }

    final ids = (jsonDecode(rawIds) as List<dynamic>).cast<String>();
    final facilities = await _facilityRepository.resolveByPlaceIds(ids);
    return (facilities: facilities, preferences: preferences);
  }

  Future<void> save({
    required List<Facility> facilities,
    required PlanPreferences preferences,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = facilities.map((facility) => facility.id).toList();
    final facilitiesJson = facilities.map((facility) => facility.toJson()).toList();

    await prefs.setString(_facilityIdsKey, jsonEncode(ids));
    await prefs.setString(_facilitiesJsonKey, jsonEncode(facilitiesJson));
    await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_facilityIdsKey);
    await prefs.remove(_facilitiesJsonKey);
    await prefs.remove(_preferencesKey);
  }
}
