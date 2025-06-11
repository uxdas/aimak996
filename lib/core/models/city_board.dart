class CityBoard {
  final int id;
  final String cityName;
  final String logoUrl;
  final bool isActive;
  final String playmarketLink;
  final String appstoreLink;

  CityBoard({
    required this.id,
    required this.cityName,
    required this.logoUrl,
    required this.isActive,
    required this.playmarketLink,
    required this.appstoreLink,
  });

  factory CityBoard.fromJson(Map<String, dynamic> json) {
    return CityBoard(
      id: json['id'] as int,
      cityName: json['city_name'] as String,
      logoUrl: json['logo_url'] as String,
      isActive: json['is_active'] as bool,
      playmarketLink: json['playmarket_link'] as String,
      appstoreLink: json['appstore_link'] as String,
    );
  }
}
