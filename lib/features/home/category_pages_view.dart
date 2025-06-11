import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:projects/core/providers/category_provider.dart';
import 'package:projects/features/home/ad_feed.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../utils/sound_helper.dart';

// Custom scroll physics for Telegram-like smooth swiping
class TelegramPageScrollPhysics extends ScrollPhysics {
  const TelegramPageScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  TelegramPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TelegramPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.5,
        stiffness: 120.0,
        damping: 14.0,
      );

  @override
  double get minFlingVelocity => 800.0; // Lower threshold for fling

  @override
  double get maxFlingVelocity => 5000.0; // Higher max velocity

  @override
  Tolerance get tolerance => const Tolerance(
        velocity: 1.0, // More sensitive to velocity changes
        distance: 0.5, // More precise positioning
      );
}

class CategoryPagesView extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(int)? onPageChanged;

  const CategoryPagesView({
    super.key,
    this.scrollController,
    this.onPageChanged,
  });

  @override
  State<CategoryPagesView> createState() => _CategoryPagesViewState();
}

class _CategoryPagesViewState extends State<CategoryPagesView> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(int categoryIndex) {
    if (categoryIndex != _currentPageIndex) {
      HapticFeedback.lightImpact();
      _pageController.animateToPage(
        categoryIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int pageIndex, CategoryProvider categoryProvider) async {
    if (pageIndex != _currentPageIndex) {
      HapticFeedback.selectionClick();
      await SoundHelper.playIfEnabled('sounds/cat_swipe.wav');
      setState(() {
        _currentPageIndex = pageIndex;
      });

      if (pageIndex < categoryProvider.categories.length) {
        final category = categoryProvider.categories[pageIndex];
        categoryProvider.selectCategory(category.id);
        widget.onPageChanged?.call(pageIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (categoryProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'error_loading_categories'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => categoryProvider.loadCategories(),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }

        if (categoryProvider.categories.isEmpty) {
          return Center(
            child: Text(
              'no_categories'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          );
        }

        final selectedCategoryIndex = categoryProvider.categories.indexWhere(
          (category) => category.id == categoryProvider.selectedCategoryId,
        );

        if (selectedCategoryIndex != -1 &&
            selectedCategoryIndex != _currentPageIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onCategoryChanged(selectedCategoryIndex);
          });
        }

        return PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => _onPageChanged(index, categoryProvider),
          itemCount: categoryProvider.categories.length,
          scrollDirection: Axis.horizontal,
          physics: const TelegramPageScrollPhysics(),
          allowImplicitScrolling: false,
          padEnds: false,
          pageSnapping: true,
          itemBuilder: (context, index) {
            final category = categoryProvider.categories[index];
            return AdFeed(
              categoryId: category.id,
              scrollController: widget.scrollController,
              key: ValueKey('category_${category.id}'),
            );
          },
        );
      },
    );
  }
}
