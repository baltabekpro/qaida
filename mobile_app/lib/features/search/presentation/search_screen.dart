import 'package:flutter/material.dart';

import '../../../app/data/mock_data.dart';
import '../../../app/models/place.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/bookmark_button.dart';
import '../../../shared/widgets/qaida_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onOpenPlace,
    required this.onOpenFilters,
  });

  final Set<String> savedIds;
  final ValueChanged<String> onToggleSaved;
  final ValueChanged<Place> onOpenPlace;
  final Future<void> Function() onOpenFilters;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _recentQueries = <String>[
    'Бранч рядом',
    'Романтичный ужин',
  ];

  static const _chips = <_QuickChipData>[
    _QuickChipData(
      id: 'cafe',
      label: 'Кафе',
      icon: Icons.local_cafe_rounded,
      type: _QuickChipType.category,
    ),
    _QuickChipData(
      id: 'terrace',
      label: 'Терраса',
      icon: Icons.deck_rounded,
      type: _QuickChipType.feature,
    ),
    _QuickChipData(
      id: 'open',
      label: 'Открыто',
      icon: Icons.schedule_rounded,
      type: _QuickChipType.feature,
    ),
    _QuickChipData(
      id: 'budget',
      label: 'До 5 000 ₽',
      icon: Icons.payments_rounded,
      type: _QuickChipType.feature,
    ),
  ];

  late final TextEditingController _queryController = TextEditingController(
    text: 'Кофейня с террасой',
  );
  String _selectedChipId = 'cafe';

  List<Place> get _results {
    final query = _queryController.text.trim().toLowerCase();
    return MockData.places.where((place) {
      final matchesQuery = query.isEmpty ||
          place.title.toLowerCase().contains(query) ||
          place.subtitle.toLowerCase().contains(query) ||
          place.category.toLowerCase().contains(query) ||
          place.neighborhood.toLowerCase().contains(query);

      final chip = _selectedChipId;
      final matchesChip = switch (chip) {
        'cafe' => place.category == 'Кафе',
        'terrace' => place.id == 'luna-terrace' || place.id == 'azure-courtyard',
        'open' => place.rating >= 4.7,
        'budget' => place.priceLabel.length <= 2,
        _ => true,
      };

      return matchesQuery && matchesChip;
    }).toList();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _results;

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SearchHeaderDelegate(
            minExtentValue: 144,
            maxExtentValue: 144,
            child: _SearchHeader(
              controller: _queryController,
              isDark: isDark,
              onOpenFilters: widget.onOpenFilters,
              onChanged: (_) => setState(() {}),
              onClear: () {
                _queryController.clear();
                setState(() {});
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SearchSectionHeader(
                title: 'Быстрые категории',
                actionLabel: 'Все категории',
                onActionTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _AllCategoriesScreen(
                        categories: MockData.categories,
                        onSelectCategory: (category) {
                          Navigator.of(context).pop();
                          _queryController.text = category;
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _chips
                    .map(
                      (chip) => _QuickChip(
                        data: chip,
                        selected: chip.id == _selectedChipId,
                        isDark: isDark,
                        onTap: () => setState(() => _selectedChipId = chip.id),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              _RecentQueriesCard(
                isDark: isDark,
                onSelectQuery: (query) {
                  _queryController.text = query;
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),
              _SearchSectionHeader(
                title: 'Подходящие результаты',
                actionLabel: '${results.length} мест',
                mutedAction: true,
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                _EmptyState(isDark: isDark)
              else
                ...results.map(
                  (place) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SearchResultCard(
                      place: place,
                      saved: widget.savedIds.contains(place.id),
                      isDark: isDark,
                      onToggleSaved: () => widget.onToggleSaved(place.id),
                      onTap: () => widget.onOpenPlace(place),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SearchHeaderDelegate({
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) {
    return oldDelegate.minExtentValue != minExtentValue ||
        oldDelegate.maxExtentValue != maxExtentValue ||
        oldDelegate.child != child;
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.isDark,
    required this.onOpenFilters,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool isDark;
  final Future<void> Function() onOpenFilters;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark
          ? AppColors.darkBg.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.92),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Поиск',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF94A3B8),
                          letterSpacing: 2.4,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Найти место',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenFilters,
                  customBorder: const CircleBorder(),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintText: 'Кофейня с террасой',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF94A3B8),
                            ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: IgnorePointer(
                      ignoring: controller.text.isEmpty,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 120),
                        opacity: controller.text.isNotEmpty ? 1 : 0,
                        child: IconButton(
                          onPressed: onClear,
                          padding: EdgeInsets.zero,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          constraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 40,
                          ),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSectionHeader extends StatelessWidget {
  const _SearchSectionHeader({
    required this.title,
    required this.actionLabel,
    this.mutedAction = false,
    this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final bool mutedAction;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF64748B),
                ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                actionLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: mutedAction
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF94A3B8))
                          : AppColors.primary,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AllCategoriesScreen extends StatelessWidget {
  const _AllCategoriesScreen({
    required this.categories,
    required this.onSelectCategory,
  });

  final List<String> categories;
  final ValueChanged<String> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Все категории')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: categories
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelectCategory(category),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_categoryIcon(category), color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Еда' => Icons.restaurant_rounded,
      'Кафе' => Icons.coffee_rounded,
      'Бар' => Icons.sports_bar_rounded,
      'Парк' => Icons.park_rounded,
      'Кино' => Icons.movie_rounded,
      _ => Icons.label_rounded,
    };
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.data,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final _QuickChipData data;
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                data.icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : (data.type == _QuickChipType.feature
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF64748B))),
              ),
              const SizedBox(width: 8),
              Text(
                data.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSecondary : const Color(0xFF475569)),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentQueriesCard extends StatelessWidget {
  const _RecentQueriesCard({required this.isDark, required this.onSelectQuery});

  final bool isDark;
  final ValueChanged<String> onSelectQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
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
          Text(
            'Недавние запросы',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                  letterSpacing: 1.8,
                ),
          ),
          const SizedBox(height: 12),
          ..._SearchScreenState._recentQueries.map(
            (query) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelectQuery(query),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            query,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.north_west_rounded,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.place,
    required this.saved,
    required this.isDark,
    required this.onToggleSaved,
    required this.onTap,
  });

  final Place place;
  final bool saved;
  final bool isDark;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: QaidaNetworkImage(
                    imageUrl: place.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${place.rating.toStringAsFixed(1)} · ${place.distanceKm.toStringAsFixed(1)} км · ${_descriptor(place)} · ${_budgetLabel(place)}',
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
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0x262563EB)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: BookmarkButton(
                              saved: saved,
                              onPressed: onToggleSaved,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags(place).map((tag) {
                        final primary = tag == 'Уютно';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: primary
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : (isDark ? const Color(0xFF09111F) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _tagIcon(tag),
                                size: 16,
                                color: primary
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : const Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tag,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: primary
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : const Color(0xFF64748B)),
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _descriptor(Place place) {
    return switch (place.category) {
      'Кафе' => 'терраса',
      'Еда' => 'ужин',
      'Бар' => 'вечер',
      'Парк' => 'прогулка',
      'Кино' => 'сеанс',
      _ => place.category.toLowerCase(),
    };
  }

  String _budgetLabel(Place place) {
    return switch (place.priceLabel.length) {
      1 => 'до 2 000 ₽',
      2 => 'до 4 000 ₽',
      _ => 'до 6 000 ₽',
    };
  }

  List<String> _tags(Place place) {
    final terrace = place.id == 'luna-terrace' || place.id == 'azure-courtyard';
    return [
      'Уютно',
      if (terrace) 'Терраса' else 'Рядом',
    ];
  }

  IconData _tagIcon(String tag) {
    return switch (tag) {
      'Уютно' => Icons.local_cafe_rounded,
      'Терраса' => Icons.deck_rounded,
      'Рядом' => Icons.place_rounded,
      _ => Icons.label_rounded,
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.travel_explore_rounded,
            size: 36,
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            'Ничего не нашли по этому запросу',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте убрать часть фильтра или выбрать другую быструю категорию.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _QuickChipType { category, feature }

class _QuickChipData {
  const _QuickChipData({
    required this.id,
    required this.label,
    required this.icon,
    required this.type,
  });

  final String id;
  final String label;
  final IconData icon;
  final _QuickChipType type;
}