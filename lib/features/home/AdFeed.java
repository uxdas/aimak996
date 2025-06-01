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

class _AdFeedState extends State<AdFeed> with AutomaticKeepAliveClientMixin {
  List<AdModel> _ads = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

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
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    final cityId = 1;
    final catId = widget.categoryId ?? 0;

    final url = Uri.parse('http://5.59.233.32:8080/ads/public-city/$cityId/category/$catId');
    debugPrint('Загружаю: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

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
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'Ошибка сервера: ${response.statusCode}';
        });
        debugPrint(_errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Ошибка при загрузке: $e';
      });
      debugPrint(_errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isError) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAds,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _loadAds,
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
