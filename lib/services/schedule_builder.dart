import 'package:flutter/material.dart';
import 'package:kotabi/models/facility.dart';
import 'package:kotabi/models/plan_preferences.dart';
import 'package:kotabi/models/schedule_entry.dart';

class ScheduleBuilder {
  static const _napWindowStart = 12 * 60;
  static const _napWindowEnd = 14 * 60;
  static const _napDuration = 60;
  static const _extraBreakDuration = 15;
  static const _napBufferMinutes = 10;
  static const _travelBufferMinutes = 5;

  static List<ScheduleEntry> build({
    required List<Facility> facilities,
    required PlanPreferences preferences,
    Map<String, int>? segmentTravelMinutes,
  }) {
    if (facilities.isEmpty) {
      return [];
    }

    final entries = <ScheduleEntry>[];
    var current = _toMinutes(preferences.startTime);
    var napInserted = false;

    for (var i = 0; i < facilities.length; i++) {
      final facility = facilities[i];

      if (preferences.considerNapTime && !napInserted && _shouldInsertNap(current)) {
        entries.add(
          ScheduleEntry(
            type: ScheduleEntryType.nap,
            startMinutes: current,
            endMinutes: current + _napDuration,
            label: '昼寝・静かな休憩',
          ),
        );
        current += _napDuration;
        napInserted = true;
      }

      var stayMinutes = facility.stayMinutes;
      if (preferences.extraBreaks) {
        stayMinutes += (stayMinutes * 0.2).round();
      }
      if (preferences.considerNapTime) {
        stayMinutes += _napBufferMinutes;
      }

      entries.add(
        ScheduleEntry(
          type: ScheduleEntryType.facility,
          startMinutes: current,
          endMinutes: current + stayMinutes,
          facility: facility,
        ),
      );
      current += stayMinutes;

      if (i >= facilities.length - 1) {
        continue;
      }

      if (preferences.extraBreaks) {
        entries.add(
          ScheduleEntry(
            type: ScheduleEntryType.breakTime,
            startMinutes: current,
            endMinutes: current + _extraBreakDuration,
            label: '休憩・水分補給',
          ),
        );
        current += _extraBreakDuration;
      }

      final segmentKey = '${facility.id}|${facilities[i + 1].id}';
      var travelMinutes = segmentTravelMinutes?[segmentKey] ?? facility.travelMinutes;
      if (preferences.considerNapTime) {
        travelMinutes += _travelBufferMinutes;
      }
      if (preferences.extraBreaks) {
        travelMinutes += _travelBufferMinutes;
      }

      entries.add(
        ScheduleEntry(
          type: ScheduleEntryType.travel,
          startMinutes: current,
          endMinutes: current + travelMinutes,
          label: '移動 ${facilities[i + 1].name}へ（${preferences.travelMode.label}）',
        ),
      );
      current += travelMinutes;
    }

    return entries;
  }

  static int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static bool _shouldInsertNap(int currentMinutes) {
    return currentMinutes >= _napWindowStart - 30 && currentMinutes < _napWindowEnd;
  }

  static int totalMinutes(List<ScheduleEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }
    return entries.last.endMinutes - entries.first.startMinutes;
  }

  static int stayMinutes(List<ScheduleEntry> entries) {
    return entries
        .where((entry) => entry.type == ScheduleEntryType.facility)
        .fold(0, (sum, entry) => sum + entry.durationMinutes);
  }

  static int travelMinutes(List<ScheduleEntry> entries) {
    return entries
        .where((entry) => entry.type == ScheduleEntryType.travel)
        .fold(0, (sum, entry) => sum + entry.durationMinutes);
  }

  static int breakMinutes(List<ScheduleEntry> entries) {
    return entries
        .where(
          (entry) =>
              entry.type == ScheduleEntryType.breakTime ||
              entry.type == ScheduleEntryType.nap,
        )
        .fold(0, (sum, entry) => sum + entry.durationMinutes);
  }
}
