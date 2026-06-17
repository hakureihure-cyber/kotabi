import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kotabi/config/google_maps_config.dart';
import 'package:kotabi/models/facility.dart';
import 'package:kotabi/models/lat_lng_coord.dart';
import 'package:kotabi/theme/kotabi_colors.dart';

/// プラン施設のマーカーと Routes API ポリラインを表示する地図。
class PlanRouteMap extends StatefulWidget {
  const PlanRouteMap({
    super.key,
    required this.facilities,
    required this.segmentPolylines,
    this.height = 220,
    this.borderRadius = 16,
    this.showOverlayLabel = true,
  });

  final List<Facility> facilities;
  final Map<String, List<LatLngCoord>> segmentPolylines;
  final double height;
  final double borderRadius;
  final bool showOverlayLabel;

  @override
  State<PlanRouteMap> createState() => _PlanRouteMapState();
}

class _PlanRouteMapState extends State<PlanRouteMap> {
  GoogleMapController? _mapController;
  static const _kyotoCenter = LatLng(35.0116, 135.7681);

  @override
  void didUpdateWidget(covariant PlanRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.facilities != widget.facilities ||
        oldWidget.segmentPolylines != widget.segmentPolylines) {
      _fitCameraToBounds();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    var order = 1;

    for (final facility in widget.facilities) {
      if (!facility.hasCoordinates) {
        continue;
      }

      markers.add(
        Marker(
          markerId: MarkerId(facility.id),
          position: LatLng(facility.latitude!, facility.longitude!),
          infoWindow: InfoWindow(
            title: facility.name,
            snippet: '訪問順: $order',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _markerHue(facility.color),
          ),
        ),
      );
      order++;
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};

    for (final entry in widget.segmentPolylines.entries) {
      if (entry.value.length < 2) {
        continue;
      }

      polylines.add(
        Polyline(
          polylineId: PolylineId(entry.key),
          points: entry.value
              .map((coord) => LatLng(coord.latitude, coord.longitude))
              .toList(),
          color: KotabiColors.primary,
          width: 4,
          patterns: GoogleMapsConfig.isConfigured && entry.value.length > 2
              ? []
              : [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    return polylines;
  }

  List<LatLng> _collectAllPoints() {
    final points = <LatLng>[];

    for (final facility in widget.facilities) {
      if (facility.hasCoordinates) {
        points.add(LatLng(facility.latitude!, facility.longitude!));
      }
    }

    for (final segment in widget.segmentPolylines.values) {
      for (final coord in segment) {
        points.add(LatLng(coord.latitude, coord.longitude));
      }
    }

    return points;
  }

  Future<void> _fitCameraToBounds() async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }

    final points = _collectAllPoints();
    if (points.isEmpty) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_kyotoCenter, 12),
      );
      return;
    }

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 14),
      );
      return;
    }

    final bounds = _latLngBoundsFromPoints(points);
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 48),
    );
  }

  LatLngBounds _latLngBoundsFromPoints(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    if ((maxLat - minLat).abs() < 0.002) {
      minLat -= 0.005;
      maxLat += 0.005;
    }
    if ((maxLng - minLng).abs() < 0.002) {
      minLng -= 0.005;
      maxLng += 0.005;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  double _markerHue(Color color) {
    if (color == KotabiColors.green) {
      return BitmapDescriptor.hueGreen;
    }
    if (color == KotabiColors.blue) {
      return BitmapDescriptor.hueBlue;
    }
    if (color == KotabiColors.orange) {
      return BitmapDescriptor.hueOrange;
    }
    if (color == KotabiColors.teal) {
      return BitmapDescriptor.hueCyan;
    }
    return BitmapDescriptor.hueRose;
  }

  @override
  Widget build(BuildContext context) {
    final mappable = widget.facilities.where((f) => f.hasCoordinates).toList();

    if (mappable.isEmpty) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: KotabiColors.primaryLight,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: KotabiColors.border),
        ),
        child: const Text(
          '地図を表示する座標情報がありません',
          style: TextStyle(color: KotabiColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _kyotoCenter,
                zoom: 12,
              ),
              markers: _buildMarkers(),
              polylines: _buildPolylines(),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) async {
                _mapController = controller;
                await Future<void>.delayed(const Duration(milliseconds: 300));
                await _fitCameraToBounds();
              },
            ),
            if (widget.showOverlayLabel)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ルート (${mappable.length}件)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KotabiColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 全画面のルート地図。
class PlanRouteMapFullScreen extends StatelessWidget {
  const PlanRouteMapFullScreen({
    super.key,
    required this.facilities,
    required this.segmentPolylines,
  });

  final List<Facility> facilities;
  final Map<String, List<LatLngCoord>> segmentPolylines;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルート地図'),
      ),
      body: PlanRouteMap(
        facilities: facilities,
        segmentPolylines: segmentPolylines,
        height: MediaQuery.sizeOf(context).height,
        borderRadius: 0,
        showOverlayLabel: false,
      ),
    );
  }
}
