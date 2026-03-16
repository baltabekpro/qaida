import 'package:flutter/material.dart';

import '../../app/models/place.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import 'bookmark_button.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.saved,
    required this.onSavedToggle,
    required this.onTap,
    this.width,
  });

  final Place place;
  final bool saved;
  final VoidCallback onSavedToggle;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                place.startColor,
                isDark ? AppColors.darkSurfaceSoft : place.endColor,
              ],
            ),
            border: Border.all(
              color: isDark
                  ? AppColors.darkTextSecondary.withValues(alpha: 0.12)
                  : AppColors.borderSoft,
            ),
            boxShadow: AppShadows.soft(Colors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(place.icon, color: AppColors.nightAccent),
                  ),
                  const Spacer(),
                  BookmarkButton(saved: saved, onPressed: onSavedToggle),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${place.category} • ${place.priceLabel}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.nightAccent,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(place.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                place.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${place.rating}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${place.distanceKm.toStringAsFixed(1)} км',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
