enum TravelMode {
  drive,
  walk;

  String get routesApiValue => switch (this) {
        TravelMode.drive => 'DRIVE',
        TravelMode.walk => 'WALK',
      };

  String get label => switch (this) {
        TravelMode.drive => '車',
        TravelMode.walk => '徒歩',
      };

  String get iconName => switch (this) {
        TravelMode.drive => 'car',
        TravelMode.walk => 'walk',
      };
}
