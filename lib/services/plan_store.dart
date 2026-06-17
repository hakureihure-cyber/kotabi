import 'package:flutter/foundation.dart';
import 'package:kotabi/models/facility.dart';
import 'package:kotabi/models/lat_lng_coord.dart';
import 'package:kotabi/models/plan_preferences.dart';
import 'package:kotabi/models/schedule_entry.dart';
import 'package:kotabi/models/travel_mode.dart';
import 'package:kotabi/services/plan_repository.dart';
import 'package:kotabi/services/routes_api_service.dart';
import 'package:kotabi/services/schedule_builder.dart';

class PlanStore extends ChangeNotifier {
  PlanStore({
    PlanRepository? repository,
    RouteTravelService? routeTravelService,
  })  : _repository = repository ?? PlanRepository(),
        _routeTravelService = routeTravelService ?? RouteTravelService();

  final PlanRepository _repository;
  final RouteTravelService _routeTravelService;

  final List<Facility> _items = [];
  PlanPreferences _preferences = const PlanPreferences();
  Map<String, int> _segmentTravelMinutes = {};
  Map<String, List<LatLngCoord>> _segmentPolylines = {};

  bool _isLoaded = false;
  bool _isSaving = false;
  bool _isLoadingRoutes = false;

  List<Facility> get items => List.unmodifiable(_items);
  PlanPreferences get preferences => _preferences;
  Map<String, int> get segmentTravelMinutes => Map.unmodifiable(_segmentTravelMinutes);
  Map<String, List<LatLngCoord>> get segmentPolylines => Map.unmodifiable(_segmentPolylines);
  bool get isLoaded => _isLoaded;
  bool get isSaving => _isSaving;
  bool get isLoadingRoutes => _isLoadingRoutes;
  bool get usesRoutesApi => _segmentTravelMinutes.isNotEmpty;

  List<ScheduleEntry> get schedule => ScheduleBuilder.build(
        facilities: _items,
        preferences: _preferences,
        segmentTravelMinutes: _segmentTravelMinutes,
      );

  bool contains(Facility facility) =>
      _items.any((item) => item.id == facility.id);

  Future<void> load() async {
    final saved = await _repository.load();
    _items
      ..clear()
      ..addAll(saved.facilities);
    _preferences = saved.preferences;
    _isLoaded = true;
    notifyListeners();
    await refreshTravelTimes();
  }

  bool add(Facility facility) {
    if (contains(facility)) {
      return false;
    }
    _items.add(facility);
    notifyListeners();
    _persistSilently();
    refreshTravelTimes();
    return true;
  }

  void remove(Facility facility) {
    _items.removeWhere((item) => item.id == facility.id);
    notifyListeners();
    _persistSilently();
    refreshTravelTimes();
  }

  void clear() {
    _items.clear();
    _segmentTravelMinutes = {};
    _segmentPolylines = {};
    notifyListeners();
    _persistSilently();
  }

  void updatePreferences(PlanPreferences preferences) {
    final modeChanged = preferences.travelMode != _preferences.travelMode;
    _preferences = preferences;
    notifyListeners();
    _persistSilently();
    if (modeChanged) {
      refreshTravelTimes();
    }
  }

  void setConsiderNapTime(bool value) {
    updatePreferences(_preferences.copyWith(considerNapTime: value));
  }

  void setExtraBreaks(bool value) {
    updatePreferences(_preferences.copyWith(extraBreaks: value));
  }

  void setTravelMode(TravelMode mode) {
    updatePreferences(_preferences.copyWith(travelMode: mode));
  }

  /// Routes API で施設間の移動時間・ポリラインを再計算。
  Future<void> refreshTravelTimes() async {
    if (_items.length < 2) {
      _segmentTravelMinutes = {};
      _segmentPolylines = _buildFallbackPolylines();
      notifyListeners();
      return;
    }

    _isLoadingRoutes = true;
    notifyListeners();

    try {
      final stops = _items
          .map(
            (facility) => (
              id: facility.id,
              lat: facility.latitude,
              lng: facility.longitude,
            ),
          )
          .toList();

      final result = await _routeTravelService.computeSegmentRoutes(
        stops: stops,
        mode: _preferences.travelMode,
      );
      _segmentTravelMinutes = result.times;
      _segmentPolylines = result.polylines.isNotEmpty
          ? result.polylines
          : _buildFallbackPolylines();
    } finally {
      _isLoadingRoutes = false;
      notifyListeners();
    }
  }

  Map<String, List<LatLngCoord>> _buildFallbackPolylines() {
    final polylines = <String, List<LatLngCoord>>{};
    for (var i = 0; i < _items.length - 1; i++) {
      final from = _items[i];
      final to = _items[i + 1];
      if (!from.hasCoordinates || !to.hasCoordinates) {
        continue;
      }
      final key = '${from.id}|${to.id}';
      polylines[key] = [
        LatLngCoord(from.latitude!, from.longitude!),
        LatLngCoord(to.latitude!, to.longitude!),
      ];
    }
    return polylines;
  }

  Future<bool> save() async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.save(
        facilities: _items,
        preferences: _preferences,
      );
      return true;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _persistSilently() async {
    if (!_isLoaded) {
      return;
    }
    await _repository.save(
      facilities: _items,
      preferences: _preferences,
    );
  }
}
