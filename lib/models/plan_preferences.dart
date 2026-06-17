import 'package:flutter/material.dart';
import 'package:kotabi/models/travel_mode.dart';

class PlanPreferences {
  const PlanPreferences({
    this.considerNapTime = false,
    this.extraBreaks = false,
    this.startTime = const TimeOfDay(hour: 10, minute: 0),
    this.travelMode = TravelMode.drive,
  });

  final bool considerNapTime;
  final bool extraBreaks;
  final TimeOfDay startTime;
  final TravelMode travelMode;

  PlanPreferences copyWith({
    bool? considerNapTime,
    bool? extraBreaks,
    TimeOfDay? startTime,
    TravelMode? travelMode,
  }) {
    return PlanPreferences(
      considerNapTime: considerNapTime ?? this.considerNapTime,
      extraBreaks: extraBreaks ?? this.extraBreaks,
      startTime: startTime ?? this.startTime,
      travelMode: travelMode ?? this.travelMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'considerNapTime': considerNapTime,
        'extraBreaks': extraBreaks,
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'travelMode': travelMode.name,
      };

  factory PlanPreferences.fromJson(Map<String, dynamic> json) {
    return PlanPreferences(
      considerNapTime: json['considerNapTime'] as bool? ?? false,
      extraBreaks: json['extraBreaks'] as bool? ?? false,
      startTime: TimeOfDay(
        hour: json['startHour'] as int? ?? 10,
        minute: json['startMinute'] as int? ?? 0,
      ),
      travelMode: TravelMode.values.byName(
        json['travelMode'] as String? ?? TravelMode.drive.name,
      ),
    );
  }
}
