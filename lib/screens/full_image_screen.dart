import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullImageScreen({
    super.key,
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: tag,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
          ),

          // Кнопка закрытия в верхнем правом углу
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, size: 30, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Закрыть',
            ),
          ),
        ],
      ),
    );
  }
}
