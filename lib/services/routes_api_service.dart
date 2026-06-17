import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kotabi/config/google_maps_config.dart';
import 'package:kotabi/models/lat_lng_coord.dart';
import 'package:kotabi/models/route_compute_result.dart';
import 'package:kotabi/models/travel_mode.dart';
import 'package:kotabi/utils/polyline_decoder.dart';

class RoutesApiService {
  RoutesApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://routes.googleapis.com/directions/v2';

  /// 2点間のルート（移動時間 + ポリライン）を Routes API から取得。
  Future<RouteComputeResult?> computeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required TravelMode mode,
  }) async {
    if (!GoogleMapsConfig.isConfigured) {
      return null;
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl:computeRoutes'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': GoogleMapsConfig.apiKey,
        'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
      },
      body: jsonEncode({
        'origin': {
          'location': {
            'latLng': {'latitude': originLat, 'longitude': originLng},
          },
        },
        'destination': {
          'location': {
            'latLng': {'latitude': destLat, 'longitude': destLng},
          },
        },
        'travelMode': mode.routesApiValue,
        'routingPreference':
            mode == TravelMode.drive ? 'TRAFFIC_AWARE' : 'ROUTING_PREFERENCE_UNSPECIFIED',
        'languageCode': 'ja',
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = body['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      return null;
    }

    final route = routes.first as Map<String, dynamic>;
    final duration = route['duration'] as String?;
    if (duration == null || !duration.endsWith('s')) {
      return null;
    }

    final seconds = int.tryParse(duration.replaceAll('s', ''));
    if (seconds == null) {
      return null;
    }

    final encoded = (route['polyline'] as Map<String, dynamic>?)?['encodedPolyline'] as String?;
    final decoded = encoded != null ? decodeEncodedPolyline(encoded) : <({double lat, double lng})>[];
    final polylinePoints = decoded
        .map((point) => LatLngCoord(point.lat, point.lng))
        .toList();

    return RouteComputeResult(
      travelMinutes: (seconds / 60).ceil().clamp(1, 999),
      polylinePoints: polylinePoints.isNotEmpty
          ? polylinePoints
          : [
              LatLngCoord(originLat, originLng),
              LatLngCoord(destLat, destLng),
            ],
    );
  }

  /// 後方互換: 移動時間のみ取得。
  Future<int?> getTravelMinutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required TravelMode mode,
  }) async {
    final result = await computeRoute(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      mode: mode,
    );
    return result?.travelMinutes;
  }
}

/// プラン内の施設間ルートを一括計算。
class RouteTravelService {
  RouteTravelService({RoutesApiService? routesApi})
      : _routesApi = routesApi ?? RoutesApiService();

  final RoutesApiService _routesApi;

  Future<({
    Map<String, int> times,
    Map<String, List<LatLngCoord>> polylines,
  })> computeSegmentRoutes({
    required List<({String id, double? lat, double? lng})> stops,
    required TravelMode mode,
  }) async {
    final times = <String, int>{};
    final polylines = <String, List<LatLngCoord>>{};

    for (var i = 0; i < stops.length - 1; i++) {
      final from = stops[i];
      final to = stops[i + 1];
      final key = '${from.id}|${to.id}';

      if (from.lat == null || from.lng == null || to.lat == null || to.lng == null) {
        continue;
      }

      final result = await _routesApi.computeRoute(
        originLat: from.lat!,
        originLng: from.lng!,
        destLat: to.lat!,
        destLng: to.lng!,
        mode: mode,
      );

      if (result != null) {
        times[key] = result.travelMinutes;
        polylines[key] = result.polylinePoints;
      } else {
        polylines[key] = [
          LatLngCoord(from.lat!, from.lng!),
          LatLngCoord(to.lat!, to.lng!),
        ];
      }
    }

    return (times: times, polylines: polylines);
  }

  /// キー: `fromPlaceId|toPlaceId` → 移動分数
  Future<Map<String, int>> computeSegmentTimes({
    required List<({String id, double? lat, double? lng})> stops,
    required TravelMode mode,
  }) async {
    final result = await computeSegmentRoutes(stops: stops, mode: mode);
    return result.times;
  }
}
