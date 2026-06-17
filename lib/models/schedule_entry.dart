import 'package:kotabi/models/facility.dart';

enum ScheduleEntryType { facility, travel, breakTime, nap }

class ScheduleEntry {
  const ScheduleEntry({
    required this.type,
    required this.startMinutes,
    required this.endMinutes,
    this.facility,
    this.label,
  });

  final ScheduleEntryType type;
  final int startMinutes;
  final int endMinutes;
  final Facility? facility;
  final String? label;

  int get durationMinutes => endMinutes - startMinutes;

  static String formatTime(int minutesFromMidnight) {
    final hours = minutesFromMidnight ~/ 60;
    final minutes = minutesFromMidnight % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String get startTimeLabel => formatTime(startMinutes);

  String get endTimeLabel => formatTime(endMinutes);

  String get timeRangeLabel => '$startTimeLabel 〜 $endTimeLabel';
}
