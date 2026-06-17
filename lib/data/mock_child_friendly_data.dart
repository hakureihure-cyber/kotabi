import 'package:kotabi/models/child_friendly_info.dart';

/// Firestore 未接続時のフォールバックデータ（place_id をキーに紐づけ）。
const mockChildFriendlyByPlaceId = <String, ChildFriendlyInfo>{
  'ChIJmock_kyoto_zoo': ChildFriendlyInfo(
    placeId: 'ChIJmock_kyoto_zoo',
    strollerOk: true,
    kidsSpace: true,
    nursingRoom: true,
    diaperChanging: true,
    stayMinutes: 120,
    reviewSummary: [
      '通路が広くベビーカーでも移動しやすい',
      'キッズスペースで子どもが遊べる',
      '授乳室が清潔で使いやすい',
    ],
  ),
  'ChIJmock_umekoji_park': ChildFriendlyInfo(
    placeId: 'ChIJmock_umekoji_park',
    strollerOk: true,
    nursingRoom: true,
    stayMinutes: 90,
    reviewSummary: [
      '芝生広場でのんびり過ごせる',
      'ベビーカーでも移動しやすい',
    ],
  ),
  'ChIJmock_kyoto_aquarium': ChildFriendlyInfo(
    placeId: 'ChIJmock_kyoto_aquarium',
    strollerOk: true,
    kidsSpace: true,
    nursingRoom: true,
    diaperChanging: true,
    stayMinutes: 100,
    reviewSummary: [
      '屋内なので天候に左右されにくい',
      '授乳室・おむつ替えスペースが充実',
    ],
  ),
  'ChIJmock_arashiyama_monkey': ChildFriendlyInfo(
    placeId: 'ChIJmock_arashiyama_monkey',
    strollerOk: true,
    stayMinutes: 80,
    reviewSummary: [
      '自然の中で子どもが大喜び',
      '山道があるためベビーカーは一部エリアのみ',
    ],
  ),
  'ChIJmock_kyoto_railway': ChildFriendlyInfo(
    placeId: 'ChIJmock_kyoto_railway',
    strollerOk: true,
    kidsSpace: true,
    parking: true,
    stayMinutes: 110,
    reviewSummary: [
      'キッズスペースで鉄道ごっこができる',
      '通路が広くベビーカーでも快適',
    ],
  ),
};
