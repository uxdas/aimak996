import 'package:flutter/material.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/data/services/ad_service.dart';
import 'ad_card.dart';

class AdFeed extends StatefulWidget {
  final int? categoryId;
  final ScrollController? scrollController;

  const AdFeed({
    Key? key,
    this.categoryId,
    this.scrollController,
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
    fetchAds();
  }

  @override
  void didUpdateWidget(covariant AdFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      print('[WIDGET] категория изменилась: ${oldWidget.categoryId} → ${widget.categoryId}');
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
      ads = [];
      debugPrint('Ошибка при загрузке объявлений: $e');
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ads.isEmpty) {
      return const Center(child: Text('Жарыялар табылган жок.'));
    }

    return RefreshIndicator(
      onRefresh: fetchAds,
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: ads.length,
        itemBuilder: (context, index) {
          return AdCard(ad: ads[index]);
        },
      ),
    );
  }
}
