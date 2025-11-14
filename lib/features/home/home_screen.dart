import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nookat996/features/home/ad_card.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
import 'package:nookat996/constants/app_colors.dart';
import 'package:nookat996/core/models/contact_info.dart';

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
  bool _updatePromptShown = false;
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

  // Returns true if current < required, comparing semver-like strings (x.y.z)
  bool _isVersionLower(String current, String required) {
    List<int> parse(String v) =>
        v.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    final c = parse(current);
    final r = parse(required);
    final len = c.length > r.length ? c.length : r.length;
    for (int i = 0; i < len; i++) {
      final ci = i < c.length ? c[i] : 0;
      final ri = i < r.length ? r[i] : 0;
      if (ci < ri) return true;
      if (ci > ri) return false;
    }
    return false; // equal
  }

  void _showUpdateDialog(UpdateInfo update) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'update',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.system_update, color: AppColors.primaryBlue, size: 24),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Доступно обновление',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.close, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        update.text.isNotEmpty ? update.text : 'Новое обновление!',
                        style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () => _launchStore(update),
                          child: const Text(
                            'Обновить',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondary, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim), child: child),
        );
      },
    );
  }

  Future<void> _launchStore(UpdateInfo update) async {
    try {
      final String? urlStr = Platform.isAndroid
          ? (update.playmarketLink ?? update.appstoreLink)
          : (update.appstoreLink ?? update.playmarketLink);
      if (urlStr == null || urlStr.isEmpty) return;
      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _initializeData() async {
    try {
      await context.read<CategoryProvider>().loadCategories();
      await context.read<ContactInfoProvider>().loadContactInfo(1);
      // After contact-info is loaded, decide whether to show update prompt based on required_version
      final update = context.read<ContactInfoProvider>().updateInfo;
      if (!_updatePromptShown && update != null && mounted) {
        final String? required = update.requiredVersion;
        if (required != null && required.isNotEmpty) {
          final info = await PackageInfo.fromPlatform();
          final current = info.version; // e.g., 2.0.0
          if (_isVersionLower(current, required)) {
            _updatePromptShown = true;
            _showUpdateDialog(update);
          }
        }
      }
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
    try {
      final contactProvider = context.read<ContactInfoProvider>();
      final rawPhone = contactProvider.moderatorPhone;
      final message = contactProvider.uploadText; // draft text for upload
      // Normalize phone: keep digits and '+', then remove '+', map leading 0 -> 996 (KG)
      final cleaned = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
      String phone = cleaned;
      if (phone.startsWith('+')) phone = phone.substring(1);
      if (phone.startsWith('0')) phone = '996${phone.substring(1)}';
      final uri = Uri.parse(
          'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}');

      debugPrint('[WhatsApp] Attempting to launch');
      debugPrint('[WhatsApp] rawPhone: "$rawPhone"');
      debugPrint('[WhatsApp] cleaned: "$cleaned"');
      debugPrint('[WhatsApp] normalized (E.164 no plus): "$phone"');
      debugPrint('[WhatsApp] uri: $uri');

      final canLaunch = await canLaunchUrl(uri);
      debugPrint('[WhatsApp] canLaunchUrl: $canLaunch');

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('[WhatsApp] launchUrl result: $launched');
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось открыть WhatsApp')),
          );
        }
      } else {
        // Fallback to wa.me link for cases when the scheme is not handled
        final webUri = Uri.parse(
            'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
        debugPrint(
            '[WhatsApp] Scheme not available. Trying web fallback: $webUri');
        final canLaunchWeb = await canLaunchUrl(webUri);
        debugPrint('[WhatsApp] canLaunchUrl (web): $canLaunchWeb');
        if (canLaunchWeb) {
          final launched = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
          debugPrint('[WhatsApp] web launch result: $launched');
          if (!launched && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Не удалось открыть WhatsApp через браузер')),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('WhatsApp не установлен или недоступен')),
          );
        }
      }
    } catch (e, st) {
      debugPrint('[WhatsApp] Exception: $e');
      debugPrint('[WhatsApp] StackTrace: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при открытии WhatsApp: $e')),
        );
      }
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
    final url = 'whatsapp://send/?text=${Uri.encodeComponent(text)}';
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

  // Formats +996123456789 or 996123456789 or 0123456789 to "0 (123) 456 789" for display
  String _formatDisplayPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    String local9;
    if (digits.startsWith('996') && digits.length >= 12) {
      local9 = digits.substring(3, 12);
    } else if (digits.length == 9) {
      local9 = digits; // already local 9-digit
    } else if (digits.length >= 10 && digits.startsWith('0')) {
      local9 = digits.substring(1, 10);
    } else if (digits.length > 9) {
      // fallback: take last 9 digits
      local9 = digits.substring(digits.length - 9);
    } else {
      // insufficient digits, return as-is
      return raw;
    }
    final p1 = local9.substring(0, 3);
    final p2 = local9.substring(3, 6);
    final p3 = local9.substring(6, 9);
    return '0 ($p1) $p2 $p3';
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
    final contactProvider = Provider.of<ContactInfoProvider>(context);
    final showPinned = pinnedProvider.message != null;
    final pinnedBoxHeight = showPinned ? 48.0 : 0.0;
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
              bottom: 13 + bottomInset,
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
      bottomNavigationBar: Container(
        // Paint the iOS home indicator area as well
        color: AppColors.primaryBlue,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: 62,
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () {
                    final share = contactProvider.shareText;
                    showShareDialog(
                      context,
                      (share.isNotEmpty) ? share : 'share_text'.tr(),
                    );
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            FontAwesomeIcons.whatsapp,
                            color: Color(0xFF104391),
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Consumer<ContactInfoProvider>(
                            builder: (context, contactProvider, _) {
                              final formatted = _formatDisplayPhone(
                                contactProvider.moderatorPhone,
                              );
                              final text = 'bottom_ad_button'.tr().replaceAll(
                                    '0 (999) 109 190',
                                    formatted,
                                  );
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF104391),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
