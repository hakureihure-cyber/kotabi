import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kotabi/config/google_maps_config.dart';
import 'package:kotabi/services/facility_merger.dart';

class PlacesApiService {
  PlacesApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://places.googleapis.com/v1';

  /// テキスト検索（Places API New）。
  Future<List<GooglePlace>> searchText({
    required String textQuery,
    double latitude = 35.0116,
    double longitude = 135.7681,
    int radiusMeters = 15000,
  }) async {
    if (!GoogleMapsConfig.isConfigured) {
      return [];
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl/places:searchText'),
      headers: _headers(
        fieldMask:
            'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.nationalPhoneNumber,places.regularOpeningHours',
      ),
      body: jsonEncode({
        'textQuery': textQuery,
        'languageCode': 'ja',
        'locationBias': {
          'circle': {
            'center': {'latitude': latitude, 'longitude': longitude},
            'radius': radiusMeters.toDouble(),
          },
        },
      }),
    );

    if (response.statusCode != 200) {
      throw PlacesApiException(
        'Places search failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final places = body['places'] as List<dynamic>? ?? [];
    return places
        .map((place) => _parsePlace(place as Map<String, dynamic>))
        .whereType<GooglePlace>()
        .toList();
  }

  /// place_id から詳細取得。
  Future<GooglePlace?> getPlaceDetails(String placeId) async {
    if (!GoogleMapsConfig.isConfigured) {
      return null;
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl/places/$placeId'),
      headers: _headers(
        fieldMask:
            'id,displayName,formattedAddress,location,rating,userRatingCount,nationalPhoneNumber,regularOpeningHours',
      ),
    );

    if (response.statusCode != 200) {
      return null;
    }

    return _parsePlace(jsonDecode(response.body) as Map<String, dynamic>);
  }

  GooglePlace? _parsePlace(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    if (location == null) {
      return null;
    }

    final placeId = (json['id'] as String?) ?? (json['name'] as String?)?.split('/').last;
    if (placeId == null || placeId.isEmpty) {
      return null;
    }

    final displayName = json['displayName'] as Map<String, dynamic>?;
    final openingHours = json['regularOpeningHours'] as Map<String, dynamic>?;
    final weekdayDescriptions =
        (openingHours?['weekdayDescriptions'] as List<dynamic>?)?.cast<String>() ?? const [];

    return GooglePlace(
      placeId: placeId,
      name: displayName?['text'] as String? ?? '名称不明',
      address: json['formattedAddress'] as String? ?? '',
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['userRatingCount'] as num?)?.toInt() ?? 0,
      phone: json['nationalPhoneNumber'] as String? ?? '',
      hours: weekdayDescriptions.isNotEmpty ? weekdayDescriptions.first : '営業時間情報なし',
      closedDays: weekdayDescriptions.length > 1 ? weekdayDescriptions.last : '',
    );
  }

  Map<String, String> _headers({required String fieldMask}) => {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': GoogleMapsConfig.apiKey,
        'X-Goog-FieldMask': fieldMask,
      };
}

class PlacesApiException implements Exception {
  PlacesApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
