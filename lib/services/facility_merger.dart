import 'package:flutter/material.dart';
import 'package:kotabi/models/child_friendly_info.dart';
import 'package:kotabi/models/facility.dart';
import 'package:kotabi/theme/kotabi_colors.dart';

/// Places API + 自前DB マージ前の Google 側プレース情報。
class GooglePlace {
  const GooglePlace({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating = 0,
    this.reviewCount = 0,
    this.phone = '',
    this.hours = '営業時間情報なし',
    this.closedDays = '',
  });

  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String phone;
  final String hours;
  final String closedDays;
}

class FacilityMerger {
  static Facility merge({
    required GooglePlace place,
    ChildFriendlyInfo? childFriendly,
  }) {
    final info = childFriendly ??
        ChildFriendlyInfo(placeId: place.placeId);

    final conditions = info.toConditionLabels();
    final iconColor = _iconForName(place.name);

    return Facility(
      id: place.placeId,
      placeId: place.placeId,
      name: place.name,
      conditions: conditions,
      stayMinutes: info.stayMinutes ?? 90,
      travelMinutes: 20,
      rating: place.rating,
      reviewCount: place.reviewCount,
      icon: iconColor.$1,
      color: iconColor.$2,
      address: place.address,
      hours: place.hours,
      closedDays: place.closedDays.isEmpty ? '定休日：情報なし' : place.closedDays,
      phone: place.phone.isEmpty ? '電話番号なし' : place.phone,
      reviewSummary: info.reviewSummary,
      latitude: place.latitude,
      longitude: place.longitude,
      dataSource: FacilityDataSource.googlePlaces,
    );
  }

  static (IconData, Color) _iconForName(String name) {
    if (name.contains('動物')) {
      return (Icons.pets, KotabiColors.green);
    }
    if (name.contains('水族')) {
      return (Icons.water, KotabiColors.blue);
    }
    if (name.contains('鉄道') || name.contains('博物館')) {
      return (Icons.train, KotabiColors.primary);
    }
    if (name.contains('公園')) {
      return (Icons.park, KotabiColors.teal);
    }
    return (Icons.place, KotabiColors.orange);
  }
}
