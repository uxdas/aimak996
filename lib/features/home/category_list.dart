import 'package:flutter/material.dart';
import 'package:projects/data/models/category_model.dart';
import 'package:projects/core/widgets/category_chip.dart';

class CategoryList extends StatelessWidget {
  final Function(int) onCategorySelected;
  final int selectedCategoryId;

  const CategoryList({
    super.key,
    required this.onCategorySelected,
    this.selectedCategoryId = 0,
  });

  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> categories = [
      CategoryModel(id: 0, name: 'Жалпы', ruName: 'Общее'),
      CategoryModel(id: 1, name: 'К. Мүлк', ruName: 'Недвижимость'),
      CategoryModel(id: 2, name: 'Авто', ruName: 'Авто'),
      CategoryModel(id: 3, name: 'Мал-чарба', ruName: 'Скот'),
      CategoryModel(id: 4, name: 'Алуу/сатуу', ruName: 'Купить/Продать'),
      CategoryModel(id: 5, name: 'Жумуш', ruName: 'Работа'),
      CategoryModel(id: 7, name: 'Каттам', ruName: 'Попутка'),
      CategoryModel(id: 9, name: 'Жаңылыктар', ruName: 'Новости района'),
    ];

    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return CategoryChip(
            category: category,
            isSelected: isSelected,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}
