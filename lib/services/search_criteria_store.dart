import 'package:flutter/foundation.dart';
import 'package:kotabi/models/search_criteria.dart';

/// トップ画面と一覧画面で共有する検索条件。
class SearchCriteriaStore extends ChangeNotifier {
  SearchCriteria _criteria = SearchCriteria.initial();

  SearchCriteria get criteria => _criteria;

  void apply({
    required String area,
    required Map<String, bool> conditions,
  }) {
    _criteria = SearchCriteria(
      area: area,
      selectedConditions: conditions.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toSet(),
    );
    notifyListeners();
  }
}
