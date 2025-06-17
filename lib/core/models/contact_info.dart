class ContactInfo {
  final String adminPhone;
  final CityInfo city;

  ContactInfo({
    required this.adminPhone,
    required this.city,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      adminPhone: json['admin_phone'] ?? '',
      city: CityInfo.fromJson(json['city'] ?? {}),
    );
  }
}

class CityInfo {
  final int id;
  final String name;
  final String moderatorPhone;

  CityInfo({
    required this.id,
    required this.name,
    required this.moderatorPhone,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      moderatorPhone: json['moderator_phone'] ?? '',
    );
  }
}
