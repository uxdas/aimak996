import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:projects/data/models/ad_model.dart';
import 'package:projects/data/services/ad_service.dart';
import 'package:projects/features/home/ad_buttons_row.dart';

class AdDetailScreen extends StatefulWidget {
  final int adId;

  const AdDetailScreen({super.key, required this.adId});

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  int _currentSlide = 0;

  final Map<int, String> categoryNames = {
    1: 'К. Мүлк',
    2: 'Авто',
    3: 'Мал-чарба',
    4: 'Алуу/сатуу',
    5: 'Жумуш',
    7: 'Каттам',
    9: 'Жаңылыктар',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Толук маалымат')),
      body: FutureBuilder<AdModel>(
        future: AdService().fetchAdById(widget.adId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Маалымат табылган жок'));
          }

          final ad = snapshot.data!;
          final dateTime = DateTime.tryParse(ad.createdAt) ?? DateTime.now();
          final timeStr = DateFormat('HH:mm').format(dateTime);
          final dateStr = DateFormat('dd.MM.yyyy').format(dateTime);
          final categoryName = categoryNames[ad.categoryId] ?? 'Белгисиз категория';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ad.images.isNotEmpty)
                  Column(
                    children: [
                      CarouselSlider.builder(
                        itemCount: ad.images.length,
                        options: CarouselOptions(
                          height: 250,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, _) {
                            setState(() => _currentSlide = index);
                          },
                        ),
                        itemBuilder: (context, index, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              ad.images[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ad.images.asMap().entries.map((entry) {
                          final isActive = entry.key == _currentSlide;
                          return Container(
                            width: isActive ? 10 : 6,
                            height: isActive ? 10 : 6,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? theme.primaryColor
                                  : Colors.grey.shade400,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                /// Title
                Text(
                  ad.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                /// Description
                Text(
                  ad.description,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                /// Phone buttons
                AdButtonsRow(phone: ad.phone),
                const SizedBox(height: 24),

                /// Meta Info
                Row(
                  children: [
                    const Icon(Icons.category, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(categoryName, style: theme.textTheme.labelSmall),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text('$timeStr | $dateStr',
                        style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
