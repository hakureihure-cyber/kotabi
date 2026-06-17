/// Google Maps Platform API キー設定。
///
/// 実行例:
/// flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_api_key
class GoogleMapsConfig {
  static const apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static bool get isConfigured => apiKey.isNotEmpty;
}
