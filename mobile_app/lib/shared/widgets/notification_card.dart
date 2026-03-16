import 'package:flutter/material.dart';

import '../../app/models/qaida_notification.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.item});

  final QaidaNotification item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withValues(alpha: 0.16)
              : AppColors.borderSoft,
        ),
        boxShadow: isDark
            ? AppShadows.medium(const Color(0xFF020817))
            : AppShadows.soft(Colors.black),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: isDark ? item.color.withValues(alpha: 0.18) : item.color,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              item.icon,
              color: isDark ? AppColors.primarySoft : AppColors.nightAccent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(item.body, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                Text(
                  item.timeLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
