import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projects/features/home/ad_card.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:projects/core/widgets/app_drawer.dart';
import 'package:projects/core/widgets/custom_app_bar.dart';
import 'package:projects/features/home/ad_feed.dart';
import 'package:projects/features/home/category_list.dart';
import 'package:projects/features/home/category_pages_view.dart';
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
  bool _isInitializing = true;
  String? _error;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _appBarKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await context.read<CategoryProvider>().loadCategories();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _error = e.toString();
        });
      }
    }
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

  void _onPageChanged(int pageIndex) {
    // Scroll categories to show the current active category
    final appBarState = _appBarKey.currentState;
    if (appBarState != null) {
      (appBarState as dynamic).scrollToCategory(pageIndex);
    }
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
          '${"error_occurred".tr()}: ${searchProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (searchProvider.results.isEmpty) {
      return Center(
        child: Text('nothing_found'.tr()),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context);

    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Загрузка...',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки данных',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _error = null;
                  });
                  _initializeData();
                },
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        isDark: themeProvider.isDark,
        toggleTheme: themeProvider.toggleTheme,
      ),
      appBar: CustomAppBar(
        key: _appBarKey,
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
                    : CategoryPagesView(
                        scrollController: _scrollController,
                        onPageChanged: _onPageChanged,
                      ),
              ),
            ],
          ),
          if (_showScrollToTop)
            Positioned(
              right: 16,
              bottom: 100, // Подняли выше, чтобы не перекрывалась с кнопкой
              child: Container(
                width: 70,
                height: 54,
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
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          height: 52,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF104391),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () {
                    Share.share('share_text'.tr());
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.share, color: Color(0xFF104391), size: 20),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: Color(0xFF104391), size: 20),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'ЖАРЫЯ БЕРҮҮ',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '0999 109 190',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 12),
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('https://wa.me/996999109190');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('whatsapp_error'.tr())),
                      );
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FaIcon(FontAwesomeIcons.whatsapp,
                          color: Color(0xFF25D366), size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
