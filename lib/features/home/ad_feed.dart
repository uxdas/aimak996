import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/data/services/ad_service.dart';
import 'package:projects/features/home/ad_card.dart';
import 'package:projects/features/home/ad_card_shimmer.dart';
import 'package:projects/widgets/telegram_refresh_indicator.dart';

class AdFeed extends StatefulWidget {
  final int? categoryId;
  final ScrollController? scrollController;
  final List<AdModel>? externalAds;

  const AdFeed({
    Key? key,
    this.categoryId,
    this.scrollController,
    this.externalAds,
  }) : super(key: key);

  @override
  State<AdFeed> createState() => _AdFeedState();
}

class _AdFeedState extends State<AdFeed> with SingleTickerProviderStateMixin {
  List<AdModel> ads = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMorePages = true;
  int currentPage = 1;
  static const int pageSize = 20;

  final AdService _adService = AdService();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.externalAds == null) {
      fetchAds();
    }
    _scrollController.addListener(_onScroll);

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _loadingController.repeat();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMorePages && widget.externalAds == null) {
        loadMoreAds();
      }
    }
  }

  Future<void> fetchAds() async {
    setState(() => isLoading = true);
    currentPage = 1;

    try {
      final newAds = await _adService.fetchAds(
        categoryId: widget.categoryId,
        page: currentPage,
        pageSize: pageSize,
      );

      if (mounted) {
        setState(() {
          ads = newAds;
          hasMorePages = newAds.length >= pageSize;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_loading_ads'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> loadMoreAds() async {
    if (isLoadingMore) return;

    setState(() => isLoadingMore = true);
    currentPage++;

    try {
      final newAds = await _adService.fetchAds(
        categoryId: widget.categoryId,
        page: currentPage,
        pageSize: pageSize,
      );

      if (newAds.isEmpty) {
        hasMorePages = false;
      } else {
        setState(() {
          ads.addAll(newAds);
          hasMorePages = newAds.length >= pageSize;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке дополнительных объявлений: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<AdModel> displayAds = widget.externalAds ?? ads;

    if (isLoading && widget.externalAds == null) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 11, left: 12, right: 12),
        itemBuilder: (context, index) => const AdCardShimmer(),
      );
    }

    if (displayAds.isEmpty) {
      return Center(child: Text('no_ads_found'.tr()));
    }

    return TelegramRefreshIndicator(
      onRefresh: widget.externalAds != null ? () async {} : fetchAds,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 11, left: 12, right: 12),
        controller: widget.scrollController ?? _scrollController,
        itemCount: displayAds.length + (hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayAds.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: AnimatedBuilder(
                  animation: _loadingAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _loadingAnimation.value * 2 * 3.14159,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
          return AdCard(ad: displayAds[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}

// margin: const EdgeInsets.only(bottom: 16),
