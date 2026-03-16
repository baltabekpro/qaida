import 'package:flutter/material.dart';

import 'qaida_skeleton.dart';

class QaidaNetworkImage extends StatelessWidget {
  const QaidaNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final child = Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return QaidaSkeleton(borderRadius: borderRadius);
      },
      errorBuilder: (context, error, stackTrace) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF172233) : const Color(0xFFEAF1FB),
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6A778B),
            ),
          ),
        );
      },
    );

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}
