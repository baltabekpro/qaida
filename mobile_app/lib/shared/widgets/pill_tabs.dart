import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isDark
                  ? AppColors.darkTextSecondary.withValues(alpha: 0.18)
                  : const Color(0x2E0F172A),
            ),
          ),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final selected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? Colors.white
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.82),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
