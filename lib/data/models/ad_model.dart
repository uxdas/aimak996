class AdModel {
  final int id;
  final String title;
  final String description;
  final List<String> images;
  final String phone;
  final String createdAt;
  final int categoryId;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.phone,
    required this.createdAt,
    required this.categoryId,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      phone: json['contact_phone'] ?? '',
      createdAt: json['created_at'] ?? '',
      categoryId: json['category_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'images': images,
      'contact_phone': phone,
      'created_at': createdAt,
      'category_id': categoryId,
    };
  }
}
