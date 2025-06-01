import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:projects/core/widgets/app_drawer.dart';
import 'package:projects/features/home/ad_feed.dart';
import 'package:projects/features/home/category_list.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryId = 0;
  bool _isSearching = false;
  bool _showScrollToTop = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != _showScrollToTop && mounted) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/996999109190');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      drawer: AppDrawer(
        isDark: widget.isDark,
        toggleTheme: widget.toggleTheme,
      ),
      appBar: AppBar(
        toolbarHeight: 110,
        // backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Stack(
          children: [
            Image.asset(
              'assets/images/header_pattern.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSearching
                  ? SizedBox(
                      key: const ValueKey('searchField'),
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'search_hint'.tr(),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: searchProvider.updateQuery,
                      ),
                    )
                  : const Text(
                      'Ноокат 996',
                      key: ValueKey('titleText'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Arsenal',
                      ),
                    ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              _isSearching
                  ? FontAwesomeIcons.xmark
                  : FontAwesomeIcons.magnifyingGlass,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  searchProvider.clearQuery();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          CategoryList(
            selectedCategoryId: selectedCategoryId,
            onCategorySelected: (id) => setState(() => selectedCategoryId = id),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AdFeed(
              categoryId: selectedCategoryId,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: theme.primaryColor,
        margin: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: _launchWhatsApp,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 8),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.whatsapp,
                    color: Color(0xFF25D366)),
                onPressed: _launchWhatsApp,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? IconButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              icon: SvgPicture.asset('assets/icon/arrow_top.svg'))
          : null,
    );
  }
}
