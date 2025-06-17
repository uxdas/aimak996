import 'package:flutter/material.dart';
import 'package:projects/data/models/category_model.dart';
import 'package:projects/core/widgets/category_chip.dart';
import 'package:provider/provider.dart';
import 'package:projects/core/providers/category_provider.dart';
import 'package:easy_localization/easy_localization.dart';

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
    final locale = context.locale; // Гарантирует пересборку при смене языка
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;
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
      },
    );
  }
}
