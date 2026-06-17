/// Firestore `child_friendly_places/{place_id}` の想定スキーマ。
class ChildFriendlyInfo {
  const ChildFriendlyInfo({
    required this.placeId,
    this.strollerOk = false,
    this.nursingRoom = false,
    this.kidsSpace = false,
    this.diaperChanging = false,
    this.kidsMenu = false,
    this.parking = false,
    this.stayMinutes,
    this.reviewSummary = const [],
  });

  final String placeId;
  final bool strollerOk;
  final bool nursingRoom;
  final bool kidsSpace;
  final bool diaperChanging;
  final bool kidsMenu;
  final bool parking;
  final int? stayMinutes;
  final List<String> reviewSummary;

  factory ChildFriendlyInfo.fromFirestore(String placeId, Map<String, dynamic> data) {
    return ChildFriendlyInfo(
      placeId: placeId,
      strollerOk: data['stroller_ok'] as bool? ?? false,
      nursingRoom: data['nursing_room'] as bool? ?? false,
      kidsSpace: data['kids_space'] as bool? ?? false,
      diaperChanging: data['diaper_changing'] as bool? ?? false,
      kidsMenu: data['kids_menu'] as bool? ?? false,
      parking: data['parking'] as bool? ?? false,
      stayMinutes: data['stay_minutes'] as int?,
      reviewSummary: (data['review_summary'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'place_id': placeId,
        'stroller_ok': strollerOk,
        'nursing_room': nursingRoom,
        'kids_space': kidsSpace,
        'diaper_changing': diaperChanging,
        'kids_menu': kidsMenu,
        'parking': parking,
        if (stayMinutes != null) 'stay_minutes': stayMinutes,
        'review_summary': reviewSummary,
      };

  List<String> toConditionLabels() {
    return [
      if (strollerOk) 'ベビーカーOK',
      if (nursingRoom) '授乳室あり',
      if (kidsSpace) 'キッズスペースあり',
      if (diaperChanging) 'おむつ替えあり',
      if (kidsMenu) 'キッズメニューあり',
      if (parking) '駐車場あり',
    ];
  }
}
