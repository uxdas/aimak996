class AdModel {
  final String id;
  final String title;
  final String description;
  final String phone;
  final String category;
  final int categoryId;
  final String createdAt;
  final List<String> images;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.phone,
    required this.category,
    required this.categoryId,
    required this.createdAt,
    required this.images,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id']?.toString() ?? '0',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      phone: json['contact_phone'] ?? '',
      category: json['category'] ?? '',
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? '') ?? 0,
      createdAt: json['created_at'] ?? '',
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contact_phone': phone,
      'category': category,
      'category_id': categoryId,
      'created_at': createdAt,
      'images': images,
    };
  }
}
