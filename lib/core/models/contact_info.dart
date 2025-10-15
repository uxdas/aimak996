class ContactInfo {
  final String adminPhone;
  final CityInfo city;
  final UpdateInfo? update;

  ContactInfo({
    required this.adminPhone,
    required this.city,
    this.update,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      adminPhone: json['admin_phone'] ?? '',
      city: CityInfo.fromJson(json['city'] ?? {}),
      update: json['update'] != null
          ? UpdateInfo.fromJson(json['update'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CityInfo {
  final int id;
  final String name;
  final String moderatorPhone;
  final String textForShare;
  final String textForUpload;

  CityInfo({
    required this.id,
    required this.name,
    required this.moderatorPhone,
    required this.textForShare,
    required this.textForUpload,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      moderatorPhone: json['moderator_phone'] ?? '',
      textForShare: json['text_for_share'] ?? '',
      textForUpload: json['text_for_upload'] ?? '',
    );
  }
}

class UpdateInfo {
  final bool available;
  final String text;
  final String? playmarketLink;
  final String? appstoreLink;
  final String? requiredVersion; // semantic version like 2.0.0

  UpdateInfo({
    required this.available,
    required this.text,
    this.playmarketLink,
    this.appstoreLink,
    this.requiredVersion,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      // default available=true for backward compatibility
      available: (json['available'] ?? true) == true,
      text: json['text'] ?? '',
      playmarketLink: json['playmarket_link'] as String?,
      appstoreLink: json['appstore_link'] as String?,
      requiredVersion: json['required_version'] as String?,
    );
  }
}
