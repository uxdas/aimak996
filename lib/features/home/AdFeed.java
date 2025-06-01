import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projects/features/home/ad_card.dart';
import 'package:projects/data/models/ad_model.dart';

class AdFeed extends StatefulWidget {
  final int? categoryId;
  final ScrollController? scrollController;

  const AdFeed({
    super.key,
    this.categoryId,
    this.scrollController,
  });

  @override
  State<AdFeed> createState() => _AdFeedState();
}

class _AdFeedState extends State<AdFeed> {
  List<AdModel> _ads = [];
  bool _isLoading = true;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  @override
  void didUpdateWidget(covariant AdFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      _loadAds();
    }
  }

  Future<void> _loadAds() async {
    setState(() => _isLoading = true);

    final cityId = 1;
    final catId = widget.categoryId ?? 0;

    final url = Uri.parse('http://5.59.233.32:8080/ads/public-city/$cityId/category/$catId');
    debugPrint('Загружаю: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _ads = jsonData.map((json) {
            return AdModel(
              id: json['id'],
              title: json['category'] ?? '',
              description: json['description'] ?? '',
              phone: json['contact_phone'] ?? '',
              imageUrls: List<String>.from(json['images'] ?? []),
              createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
              categoryId: catId,
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        debugPrint('Ошибка сервера: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('‼ Ошибка при загрузке: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _loadAds,
        color: primary,
        child: _ads.isEmpty
            ? ListView(
                controller: widget.scrollController,
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Ничего не найдено')),
                ],
              )
            : ListView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _ads.length,
                itemBuilder: (_, i) => AdCard(ad: _ads[i]),
              ),
      ),
    );
  }
}
