import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projects/features/home/ad_card.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:projects/core/widgets/app_drawer.dart';
import 'package:projects/core/widgets/custom_app_bar.dart';
import 'package:projects/features/home/ad_feed.dart';
import 'package:projects/features/home/category_list.dart';
import 'package:projects/core/providers/search_provider.dart';
import 'package:projects/core/providers/theme_provider.dart';
import 'package:projects/features/favorites/favorites_screen.dart';
import 'package:projects/core/providers/category_provider.dart';
import 'package:projects/core/providers/search_provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isSearching = false;
  bool _showScrollToTop = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != _showScrollToTop && mounted) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/996999109190');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<SearchProvider>().clear();
      }
    });
  }

  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchProvider>().search(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.error != null) {
      return Center(
        child: Text(
          'Ошибка: ${searchProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (searchProvider.results.isEmpty) {
      return const Center(
        child: Text('Ничего не найдено'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: searchProvider.results.length,
      itemBuilder: (_, index) {
        final ad = searchProvider.results[index];
        return AdCard(ad: ad);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        isDark: themeProvider.isDark,
        toggleTheme: themeProvider.toggleTheme,
      ),
      appBar: CustomAppBar(
        isSearching: _isSearching,
        onSearchToggle: () {
          setState(() {
            _isSearching = !_isSearching;
            _searchController.clear();
          });
        },
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _isSearching
                    ? AdFeed(
                        externalAds: searchProvider.results,
                        scrollController: _scrollController,
                      )
                    : AdFeed(
                        categoryId: categoryProvider.selectedCategoryId,
                        scrollController: _scrollController,
                      ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: theme.primaryColor,
        child: Center(
          child: InkWell(
            onTap: _launchWhatsApp,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icon/add_rounded.svg',
                    width: 28, // ширина
                    height: 28, // высота
                  ),
                  const SizedBox(width: 21),
                  Text(
                    'drawer_add'.tr(),
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'drawer_number'.tr(),
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 21),
                  SvgPicture.asset('assets/icon/whatsapp.svg')
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? Container(
              width: 70,
              height: 54,
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icon/arrow_top.svg',
                      width: 28,
                      height: 28,
                      // 👈 делаем стрелку белой
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
