import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nookat996/features/home/ad_card.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:nookat996/core/widgets/app_drawer.dart';
import 'package:nookat996/core/widgets/custom_app_bar.dart';
import 'package:nookat996/features/home/ad_feed.dart';
import 'package:nookat996/features/home/category_list.dart';
import 'package:nookat996/features/home/category_pages_view.dart';
import 'package:nookat996/core/providers/search_provider.dart';
import 'package:nookat996/core/providers/theme_provider.dart';
import 'package:nookat996/features/favorites/favorites_screen.dart';
import 'package:nookat996/core/providers/category_provider.dart';
import 'package:nookat996/core/providers/pinned_message_provider.dart';
import 'package:nookat996/core/providers/contact_info_provider.dart';
import 'package:nookat996/core/widgets/pinned_message_box.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      // Загрузка закреплённого сообщения (city_id = 1)
      context.read<PinnedMessageProvider>().load(1);
    });
  }

  Future<void> _initializeData() async {
    try {
      await context.read<CategoryProvider>().loadCategories();
      await context.read<ContactInfoProvider>().loadContactInfo(1);
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
    final contactProvider = context.read<ContactInfoProvider>();
    final phone = contactProvider.moderatorPhone.replaceAll(' ', '');
    final uri = Uri.parse('https://wa.me/$phone');
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

  void _shareToWhatsApp(String text) async {
    final url = 'https://wa.me/?text=${Uri.encodeComponent(text)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareToTelegram(String text) async {
    final url = 'https://t.me/share/url?url=${Uri.encodeComponent(text)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareToInstagram() async {
    const url = 'instagram://app';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareOther(BuildContext context, String text) {
    Share.share(text);
  }

  void showShareDialog(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
              title: const Text('WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                _shareToWhatsApp(text);
              },
            ),
            ListTile(
              leading:
                  const FaIcon(FontAwesomeIcons.telegram, color: Colors.blue),
              title: const Text('Telegram'),
              onTap: () {
                Navigator.pop(context);
                _shareToTelegram(text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: const Text('Instagram'),
              onTap: () {
                Navigator.pop(context);
                _shareToInstagram();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Другие приложения'),
              onTap: () {
                Navigator.pop(context);
                _shareOther(context, text);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context);
    final pinnedProvider = Provider.of<PinnedMessageProvider>(context);
    final showPinned = pinnedProvider.message != null;
    final pinnedBoxHeight = showPinned ? 48.0 : 0.0;

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
        onSearchToggle: _toggleSearch,
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onMenuPressed: () {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState!.openDrawer();
          }
        },
        onCategoryScrollNeeded: _onPageChanged,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: pinnedProvider.message != null ? 60.0 : 0.0,
                  ),
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
              ),
            ],
          ),
          if (pinnedProvider.message != null)
            Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PinnedMessageBox(
                text: pinnedProvider.message!.text,
                    onClose: () => pinnedProvider.hide(),
                  ),
            ),
          if (_showScrollToTop)
            Positioned(
              right: 16,
              bottom: 13,
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
          height: 62,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF104391),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () {
                    showShareDialog(context, 'share_text'.tr());
                  },
                  child: Container(
                    width: 56,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.share, color: Color(0xFF104391), size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _launchWhatsApp,
                child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Center(
                              child: Icon(FontAwesomeIcons.whatsapp,
                                  color: Color(0xFF104391), size: 28),
                        ),
                      ),
                      Flexible(
                            child: Consumer<ContactInfoProvider>(
                              builder: (context, contactProvider, _) {
                                return Text(
                                  'bottom_ad_button'.tr().replaceAll(
                                      '0 (999) 109 190',
                                      contactProvider.moderatorPhone),
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Color(0xFF104391),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                                );
                              },
                        ),
                      ),
                    ],
                  ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
