import 'package:kotabi/models/lat_lng_coord.dart';

class RouteComputeResult {
  const RouteComputeResult({
    required this.travelMinutes,
    required this.polylinePoints,
  });

  final int travelMinutes;
  final List<LatLngCoord> polylinePoints;
}
