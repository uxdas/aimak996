import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import 'category_button.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isSearching;
  final VoidCallback onSearchToggle;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onMenuPressed;

  const CustomAppBar({
    super.key,
    required this.isSearching,
    required this.onSearchToggle,
    required this.searchController,
    required this.onSearchChanged,
    required this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // Загружаем категории при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Верхняя часть с логотипом и поиском
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  // Кнопка меню слева
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icon/drawer_icon.svg',
                          width: 48,
                          height: 48,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: widget.onMenuPressed,
                          splashRadius: 24,
                        ),
                      ],
                    ),
                  ),

                  // Название по центру
                  Expanded(
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: widget.isSearching
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Center(
                        child: Text(
                          'Ноокат 996',
                          style: const TextStyle(
                            fontFamily: 'Arsenal',
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: TextField(
                          controller: widget.searchController,
                          onChanged: widget.onSearchChanged,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: 'Поиск...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      layoutBuilder:
                          (topChild, topChildKey, bottomChild, bottomChildKey) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              key: bottomChildKey,
                              child: bottomChild,
                            ),
                            Positioned.fill(
                              key: topChildKey,
                              child: topChild,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Кнопка поиска справа
                  IconButton(
                    icon: Icon(
                      widget.isSearching ? Icons.close : Icons.search,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: widget.onSearchToggle,
                    splashRadius: 24,
                  ),
                ],
              ),
            ),

            // Нижняя часть с кнопками навигации
            Container(
              height: 64,
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Consumer<CategoryProvider>(
                builder: (context, categoryProvider, _) {
                  if (categoryProvider.isLoading) {
                    return const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  }

                  if (categoryProvider.error != null) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ошибка загрузки',
                            style: TextStyle(
                              color: Colors.red[100],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () => categoryProvider.loadCategories(),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    );
                  }

                  if (categoryProvider.categories.isEmpty) {
                    return const Center(
                      child: Text(
                        'Нет доступных категорий',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          ...categoryProvider.categories.map((category) {
                            final isLast =
                                category == categoryProvider.categories.last;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: isLast ? 12 : 6,
                              ),
                              child: CategoryButton(
                                icon: category.iconData,
                                label: category.name,
                                isActive: categoryProvider.selectedCategoryId ==
                                    category.id,
                                onTap: () => categoryProvider
                                    .selectCategory(category.id),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
