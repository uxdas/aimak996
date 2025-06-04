import 'package:flutter/material.dart';
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

  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    if (widget.externalAds == null) {
      fetchAds();
    }
  }

  @override
  void didUpdateWidget(covariant AdFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      print(
          '[WIDGET] категория изменилась: ${oldWidget.categoryId} → ${widget.categoryId}');
      fetchAds();
    }
  }

  Future<void> fetchAds() async {
    setState(() => isLoading = true);

    try {
      if (widget.categoryId != null && widget.categoryId != 0) {
        print('[FETCH] категория: ${widget.categoryId}');
        ads = await _adService.fetchAdsByCategory(widget.categoryId!);
      } else {
        print('[FETCH] загружаем все категории');
        ads = await _adService.fetchAds();
      }

      ads.sort((a, b) {
        final dateA = DateTime.tryParse(a.createdAt) ?? DateTime(2000);
        final dateB = DateTime.tryParse(b.createdAt) ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      print('Загружено объявлений: ${ads.length}');
      print('ID категорий: ${ads.map((e) => e.categoryId).toSet()}');
    } catch (e) {
      debugPrint('Ошибка при загрузке объявлений: $e');
      ads = []; // Очищаем список в случае ошибки
    }

    if (mounted) {
      setState(() => isLoading = false);
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
      return const Center(child: Text('Жарыялар табылган жок.'));
    }

    return TelegramRefreshIndicator(
      onRefresh: widget.externalAds != null ? () async {} : fetchAds,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 11, left: 12, right: 12),
        controller: widget.scrollController,
        itemCount: displayAds.length,
        itemBuilder: (context, index) => AdCard(ad: displayAds[index]),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}

// margin: const EdgeInsets.only(bottom: 16),
