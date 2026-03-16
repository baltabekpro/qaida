import 'package:flutter/material.dart';

abstract final class AppShadows {
  static List<BoxShadow> soft(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.06),
        blurRadius: 28,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static List<BoxShadow> medium(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.08),
        blurRadius: 44,
        offset: const Offset(0, 20),
      ),
    ];
  }

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.22),
        blurRadius: 30,
        offset: const Offset(0, 14),
      ),
    ];
  }
}
