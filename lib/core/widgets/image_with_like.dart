import 'package:flutter/material.dart';

class ImageWithLike extends StatelessWidget {
  final String imageUrl;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ImageWithLike({
    super.key,
    required this.imageUrl,
    required this.isLiked,
    required this.onLikePressed,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Изображение
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.error_outline),
              );
            },
          ),
        ),
        // Кнопка лайка в левом нижнем углу
        Positioned(
          left: 8,
          bottom: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onLikePressed,
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
