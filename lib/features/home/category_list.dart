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
      CategoryModel(id: 0, title: 'Жалпы'),
      CategoryModel(id: 1, title: 'К. Мүлк'),
      CategoryModel(id: 2, title: 'Авто'),
      CategoryModel(id: 3, title: 'Мал-чарба'),
      CategoryModel(id: 4, title: 'Алуу/сатуу'),
      CategoryModel(id: 5, title: 'Жумуш'),
      CategoryModel(id: 7, title: 'Каттам'),
      CategoryModel(id: 9, title: 'Жаңылыктар'),
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
