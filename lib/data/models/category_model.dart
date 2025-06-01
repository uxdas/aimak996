class CategoryModel {
  final int id;
  final String title;

  CategoryModel({required this.id, required this.title});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['name'],
    );
  }

  String get name => title; // Для обратной совместимости
}
