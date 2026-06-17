import 'package:flutter/material.dart';
import 'package:kotabi/theme/kotabi_colors.dart';

enum FacilityDataSource {
  mock,
  googlePlaces,
}

class Facility {
  const Facility({
    required this.id,
    required this.name,
    required this.conditions,
    required this.stayMinutes,
    required this.travelMinutes,
    required this.rating,
    required this.reviewCount,
    required this.icon,
    required this.color,
    required this.address,
    required this.hours,
    required this.closedDays,
    required this.phone,
    this.placeId,
    this.latitude,
    this.longitude,
    this.reviewSummary = const [],
    this.dataSource = FacilityDataSource.mock,
  });

  /// Google `place_id` またはモックID。
  final String id;
  final String? placeId;
  final String name;
  final List<String> conditions;
  final int stayMinutes;
  final int travelMinutes;
  final double rating;
  final int reviewCount;
  final IconData icon;
  final Color color;
  final String address;
  final String hours;
  final String closedDays;
  final String phone;
  final List<String> reviewSummary;
  final double? latitude;
  final double? longitude;
  final FacilityDataSource dataSource;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get stayDurationLabel => '滞在 $stayMinutes分';

  String get travelDurationLabel => '移動 $travelMinutes分';

  Facility copyWith({
    int? travelMinutes,
    int? stayMinutes,
  }) {
    return Facility(
      id: id,
      placeId: placeId ?? id,
      name: name,
      conditions: conditions,
      stayMinutes: stayMinutes ?? this.stayMinutes,
      travelMinutes: travelMinutes ?? this.travelMinutes,
      rating: rating,
      reviewCount: reviewCount,
      icon: icon,
      color: color,
      address: address,
      hours: hours,
      closedDays: closedDays,
      phone: phone,
      reviewSummary: reviewSummary,
      latitude: latitude,
      longitude: longitude,
      dataSource: dataSource,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeId': placeId ?? id,
        'name': name,
        'conditions': conditions,
        'stayMinutes': stayMinutes,
        'travelMinutes': travelMinutes,
        'rating': rating,
        'reviewCount': reviewCount,
        'address': address,
        'hours': hours,
        'closedDays': closedDays,
        'phone': phone,
        'reviewSummary': reviewSummary,
        'latitude': latitude,
        'longitude': longitude,
        'dataSource': dataSource.name,
      };

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as String,
      placeId: json['placeId'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      conditions: (json['conditions'] as List<dynamic>).cast<String>(),
      stayMinutes: json['stayMinutes'] as int,
      travelMinutes: json['travelMinutes'] as int,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      icon: Icons.place,
      color: KotabiColors.primary,
      address: json['address'] as String,
      hours: json['hours'] as String,
      closedDays: json['closedDays'] as String,
      phone: json['phone'] as String,
      reviewSummary: (json['reviewSummary'] as List<dynamic>?)?.cast<String>() ?? const [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      dataSource: FacilityDataSource.values.byName(
        json['dataSource'] as String? ?? FacilityDataSource.mock.name,
      ),
    );
  }
}
