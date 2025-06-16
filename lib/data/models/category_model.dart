class CategoryModel {
  final int id;
  final String name;
  final String ruName;

  CategoryModel({required this.id, required this.name, required this.ruName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      ruName: json['ru_name'] ?? '',
    );
  }

  String getLocalizedName(String langCode) {
    return langCode == 'ru' ? ruName : name;
  }
}
