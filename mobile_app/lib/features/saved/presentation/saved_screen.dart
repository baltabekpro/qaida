import 'package:flutter/material.dart';

import '../../../app/models/place.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/qaida_network_image.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({
    super.key,
    required this.savedPlaces,
    required this.onOpenPlace,
    required this.onToggleSaved,
    required this.onOpenSearch,
  });

  final List<Place> savedPlaces;
  final ValueChanged<Place> onOpenPlace;
  final ValueChanged<String> onToggleSaved;
  final VoidCallback onOpenSearch;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  static const _collections = <_SavedCollectionData>[
    _SavedCollectionData(
      title: 'На выходные',
      subtitle: '6 мест · brunch, прогулка и тихий ужин',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
      badge: 'Обновлена сегодня',
      isPrimaryBadge: true,
    ),
    _SavedCollectionData(
      title: 'Для свидания',
      subtitle: '4 места · спокойная атмосфера и тёплый свет',
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SavedHeaderDelegate(
            minExtentValue: 108,
            maxExtentValue: 108,
            child: _SavedHeader(
              currentTab: _tabIndex,
              isDark: isDark,
              onTabChanged: (value) => setState(() => _tabIndex = value),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          sliver: SliverToBoxAdapter(
            child: _tabIndex == 0
                ? _PlacesTab(
                    savedPlaces: widget.savedPlaces,
                    isDark: isDark,
                    onOpenPlace: widget.onOpenPlace,
                    onRemovePlace: _confirmRemove,
                    onOpenSearch: widget.onOpenSearch,
                  )
                : _CollectionsTab(isDark: isDark),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmRemove(Place place) async {
    final remove = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) => _DeleteSavedDialog(place: place),
    );

    if (remove == true && mounted) {
      widget.onToggleSaved(place.id);
    }
  }
}

class _SavedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SavedHeaderDelegate({
    required this.minExtentValue,
    required this.maxExtentValue,
    required this.child,
  });

  final double minExtentValue;
  final double maxExtentValue;
  final Widget child;

  @override
  double get minExtent => minExtentValue;

  @override
  double get maxExtent => maxExtentValue;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SavedHeaderDelegate oldDelegate) {
    return oldDelegate.minExtentValue != minExtentValue ||
        oldDelegate.maxExtentValue != maxExtentValue ||
        oldDelegate.child != child;
  }
}

class _SavedHeader extends StatelessWidget {
  const _SavedHeader({
    required this.currentTab,
    required this.isDark,
    required this.onTabChanged,
  });

  final int currentTab;
  final bool isDark;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark
          ? AppColors.darkBg.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.92),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Сохранённые места',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SavedTabChip(
                  label: 'Места',
                  selected: currentTab == 0,
                  isDark: isDark,
                  onTap: () => onTabChanged(0),
                ),
                const SizedBox(width: 8),
                _SavedTabChip(
                  label: 'Коллекции',
                  selected: currentTab == 1,
                  isDark: isDark,
                  onTap: () => onTabChanged(1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedTabChip extends StatelessWidget {
  const _SavedTabChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : const Color(0xFF475569)),
                ),
          ),
        ),
      ),
    );
  }
}

class _PlacesTab extends StatelessWidget {
  const _PlacesTab({
    required this.savedPlaces,
    required this.isDark,
    required this.onOpenPlace,
    required this.onRemovePlace,
    required this.onOpenSearch,
  });

  final List<Place> savedPlaces;
  final bool isDark;
  final ValueChanged<Place> onOpenPlace;
  final ValueChanged<Place> onRemovePlace;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    if (savedPlaces.isEmpty) {
      return _SavedEmptyState(isDark: isDark, onOpenSearch: onOpenSearch);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: savedPlaces.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.74,
      ),
      itemBuilder: (context, index) {
        final place = savedPlaces[index];
        return _SavedPlaceCard(
          place: place,
          isDark: isDark,
          onTap: () => onOpenPlace(place),
          onRemove: () => onRemovePlace(place),
        );
      },
    );
  }
}

class _SavedPlaceCard extends StatelessWidget {
  const _SavedPlaceCard({
    required this.place,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  final Place place;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: QaidaNetworkImage(
                        imageUrl: place.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _displayTitle(place),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 4),
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayTitle(Place place) {
    return switch (place.id) {
      'sunline-brunch' => "Кофейня 'Утро'",
      'mint-garden' => 'Парк Культуры',
      'azure-courtyard' => 'Ресторан "Горизонт"',
      'frame-house' => 'Центральная Библиотека',
      _ => place.title,
    };
  }
}

class _CollectionsTab extends StatelessWidget {
  const _CollectionsTab({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._SavedScreenState._collections.map(
          (collection) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CollectionCard(collection: collection, isDark: isDark),
          ),
        ),
        _NewCollectionCard(isDark: isDark),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection, required this.isDark});

  final _SavedCollectionData collection;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: SizedBox(
              height: 128,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  QaidaNetworkImage(imageUrl: collection.imageUrl, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.16),
                          Colors.black.withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Коллекция',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF94A3B8),
                              letterSpacing: 1.8,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.title,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF64748B),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (collection.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: collection.isPrimaryBadge
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      collection.badge!,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: collection.isPrimaryBadge
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : const Color(0xFF94A3B8)),
                          ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewCollectionCard extends StatelessWidget {
  const _NewCollectionCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFD1D5DB),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add_rounded, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Новая коллекция',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Собирай отдельные подборки для прогулок, свиданий, быстрых встреч и новых открытий.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                ),
          ),
        ],
      ),
    );
  }
}

class _SavedEmptyState extends StatelessWidget {
  const _SavedEmptyState({required this.isDark, required this.onOpenSearch});

  final bool isDark;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0x262563EB) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.bookmark_rounded, size: 30, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'Пока ничего не сохранено',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 34,
                height: 1,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Text(
            'Добавляй любимые места в коллекции, чтобы быстро возвращаться к ним позже.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onOpenSearch,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            'Найти места',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        const SizedBox(height: 36),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _HintCard(
                  title: 'Совет',
                  body: 'Сохраняй места одним тапом из рекомендаций.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _HintCard(
                  title: 'Коллекции',
                  body: 'Создай папки «На выходные» и «Быстро перекусить».',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                  letterSpacing: 1.6,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DeleteSavedDialog extends StatelessWidget {
  const _DeleteSavedDialog({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x380F172A),
              blurRadius: 60,
              offset: Offset(0, 24),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x262563EB) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_rounded, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Удалить из сохранённых?',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Место ${place.title} исчезнет из коллекции, но его можно будет сохранить снова позже.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Удалить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCollectionData {
  const _SavedCollectionData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.badge,
    this.isPrimaryBadge = false,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String? badge;
  final bool isPrimaryBadge;
}