import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

class QaidaBottomNav extends StatelessWidget {
  const QaidaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Match CSS: padding-bottom:20px (safe area already handled by inset)
    final navBottom = bottomInset > 0 ? bottomInset : 8.0;

    final items = const [
      (_NavIcons(Icons.home_rounded, Icons.home_outlined), 'Главная'),
      (_NavIcons(Icons.search_rounded, Icons.search_rounded), 'Поиск'),
      (_NavIcons(Icons.bookmark_rounded, Icons.bookmark_border_rounded), 'Сохранено'),
      (_NavIcons(Icons.person_rounded, Icons.person_outline_rounded), 'Профиль'),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glass capsule with shadow
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: navBottom,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.34)
                      : const Color(0x1E0F172A),
                  blurRadius: isDark ? 24 : 30,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xD9101A2B)
                        : const Color(0xC7FFFFFF),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0x4794A3B8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : const Color(0xE6FFFFFF),
                        blurRadius: 0,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final selected = index == currentIndex;
                      final activeColor = AppColors.primary;
                      final inactiveColor = isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF64748B);
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? (isDark
                                      ? const Color(0x332463EB)
                                      : const Color(0x242463EB))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: isDark
                                            ? const Color(0x1F2463EB)
                                            : const Color(0x0F2463EB),
                                        blurRadius: isDark ? 10 : 0,
                                        spreadRadius: isDark ? 0 : 1,
                                        offset: isDark
                                            ? const Offset(0, 2)
                                            : Offset.zero,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selected
                                      ? item.$1.active
                                      : item.$1.inactive,
                                  size: 20,
                                  color: selected
                                      ? activeColor
                                      : inactiveColor,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.$2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize: 9,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: selected
                                            ? activeColor
                                            : inactiveColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
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

class _NavIcons {
  const _NavIcons(this.active, this.inactive);

  final IconData active;
  final IconData inactive;
}
