import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nookat996/data/models/ad_model.dart';
import 'package:nookat996/data/services/ad_service.dart';
import 'package:nookat996/features/home/ad_card.dart';
import 'package:nookat996/features/home/ad_card_shimmer.dart';
import 'package:nookat996/features/home/news_header_card.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../utils/sound_helper.dart';

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
  bool _isRefreshing = false;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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
      final response = await _adService.fetchAds(
        categoryId: widget.categoryId,
        page: currentPage,
        pageSize: pageSize,
      );

      if (mounted) {
        setState(() {
          ads = [];
          hasMorePages = response['totalPages'] > currentPage;
          isLoading = false;
        });

        final newAds = response['ads'] as List<AdModel>;
        final bool isNewsCategory = widget.categoryId == 9;

        for (int i = 0; i < newAds.length; i++) {
          ads.add(newAds[i]);
          final animationIndex = isNewsCategory ? i + 1 : i;
          _listKey.currentState?.insertItem(animationIndex,
              duration: const Duration(milliseconds: 350));
        }
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
      final response = await _adService.fetchAds(
        categoryId: widget.categoryId,
        page: currentPage,
        pageSize: pageSize,
      );

      if (mounted) {
        final newAds = response['ads'] as List<AdModel>;
        if (newAds.isEmpty) {
          hasMorePages = false;
        } else {
          final startIndex = ads.length;
          setState(() {
            ads.addAll(newAds);
            hasMorePages = response['totalPages'] > currentPage;
          });

          final bool isNewsCategory = widget.categoryId == 9;
          for (int i = 0; i < newAds.length; i++) {
            final animationIndex =
                isNewsCategory ? startIndex + i + 1 : startIndex + i;
            _listKey.currentState?.insertItem(animationIndex,
                duration: const Duration(milliseconds: 350));
          }
        }
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке дополнительных объявлений: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingMore = false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await SoundHelper.playIfEnabled('sounds/refresh.mp3');
    setState(() => _isRefreshing = true);
    await fetchAds();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final List<AdModel> displayAds = widget.externalAds ?? ads;
    final bool isNewsCategory = widget.categoryId == 9;

    if (isLoading && widget.externalAds == null) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 11, left: 12, right: 12),
        itemBuilder: (context, index) => const AdCardShimmer(),
      );
    }

    if (displayAds.isEmpty && !isNewsCategory) {
      return Center(child: Text('no_ads_found'.tr()));
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
        controller: widget.scrollController ?? _scrollController,
        initialItemCount: displayAds.length +
            (hasMorePages ? 1 : 0) +
            (isNewsCategory ? 1 : 0),
        itemBuilder: (context, index, animation) {
          if (isNewsCategory && index == 0) {
            return const NewsHeaderCard();
          }

          final adjustedIndex = isNewsCategory ? index - 1 : index;

          if (adjustedIndex == displayAds.length) {
            if (isLoadingMore) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            } else if (hasMorePages) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: TextButton(
                    onPressed: loadMoreAds,
                    child: Text(
                      'load_more'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox(height: 32);
            }
          }

          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: 0.0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdCard(ad: displayAds[adjustedIndex]),
            ),
          );
        },
      ),
    );
  }
}

// margin: const EdgeInsets.only(bottom: 16),
