import 'package:kotabi/models/facility.dart';

/// トップ画面で選択したエリア・条件。
class SearchCriteria {
  const SearchCriteria({
    required this.area,
    required this.selectedConditions,
  });

  static const defaultAreas = [
    '京都市（京都府）',
    '大阪市（大阪府）',
    '神戸市（兵庫県）',
    '奈良市（奈良県）',
    '東京都',
  ];

  static const defaultConditions = {
    'ベビーカーOK': true,
    'キッズスペースあり': true,
    'おむつ替えスペースあり': true,
    '授乳室あり': false,
    '駐車場あり': false,
  };

  final String area;
  final Set<String> selectedConditions;

  factory SearchCriteria.initial() {
    return SearchCriteria(
      area: defaultAreas.first,
      selectedConditions: defaultConditions.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toSet(),
    );
  }

  /// 一覧画面のチップ表示用ラベル。
  List<String> get activeFilterLabels {
    final labels = <String>[areaLabel];
    labels.addAll(selectedConditions);
    return labels;
  }

  /// 「京都市（京都府）」→「京都市」
  String get areaLabel => area.split('（').first;

  /// Places API 検索クエリ用。
  String get placesSearchQuery => '$areaLabel 子連れ 観光';

  SearchCriteria copyWith({
    String? area,
    Set<String>? selectedConditions,
  }) {
    return SearchCriteria(
      area: area ?? this.area,
      selectedConditions: selectedConditions ?? this.selectedConditions,
    );
  }

  /// 施設がエリア・条件の両方に合致するか判定。
  bool matches(Facility facility) {
    if (!_matchesArea(facility)) {
      return false;
    }
    for (final condition in selectedConditions) {
      if (!_hasCondition(facility, condition)) {
        return false;
      }
    }
    return true;
  }

  bool _matchesArea(Facility facility) {
    final keyword = areaLabel;
    if (facility.address.contains(keyword)) {
      return true;
    }
    if (keyword == '東京都' && facility.address.contains('東京')) {
      return true;
    }
    return false;
  }

  bool _hasCondition(Facility facility, String condition) {
    return switch (condition) {
      'おむつ替えスペースあり' => facility.conditions.any((tag) => tag.contains('おむつ替え')),
      _ => facility.conditions.contains(condition),
    };
  }
}
