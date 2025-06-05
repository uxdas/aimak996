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

class _AdFeedState extends State<AdFeed> {
  List<AdModel> ads = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMorePages = true;
  int currentPage = 1;
  static const int pageSize = 20;

  final AdService _adService = AdService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.externalAds == null) {
      fetchAds();
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
      print('[FETCH] Starting to fetch ads...');
      if (widget.categoryId != null && widget.categoryId != 0) {
        print('[FETCH] Fetching ads for category: ${widget.categoryId}');
        ads = await _adService.fetchAdsByCategory(
          widget.categoryId!,
          page: currentPage,
          pageSize: pageSize,
        );
      } else {
        print('[FETCH] Fetching all ads');
        ads = await _adService.fetchAds(
          page: currentPage,
          pageSize: pageSize,
        );
      }

      print('[FETCH] Successfully fetched ${ads.length} ads');
      print(
          '[FETCH] First ad details: ${ads.isNotEmpty ? ads.first.toJson() : "No ads"}');

      ads.sort((a, b) {
        final dateA = DateTime.tryParse(a.createdAt) ?? DateTime(2000);
        final dateB = DateTime.tryParse(b.createdAt) ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      hasMorePages = ads.length >= pageSize;
      print('[FETCH] Sorted ads by date');
      print('[FETCH] Has more pages: $hasMorePages');
    } catch (e, stackTrace) {
      debugPrint('Error fetching ads: $e');
      debugPrint('Stack trace: $stackTrace');
      ads = [];
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadMoreAds() async {
    if (isLoadingMore || !hasMorePages) return;

    setState(() => isLoadingMore = true);
    currentPage++;

    try {
      List<AdModel> newAds;
      if (widget.categoryId != null && widget.categoryId != 0) {
        newAds = await _adService.fetchAdsByCategory(
          widget.categoryId!,
          page: currentPage,
          pageSize: pageSize,
        );
      } else {
        newAds = await _adService.fetchAds(
          page: currentPage,
          pageSize: pageSize,
        );
      }

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
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
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
