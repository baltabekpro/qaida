import 'package:flutter/material.dart';

import '../../../app/data/mock_data.dart';
import '../../../app/models/place.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../shared/widgets/qaida_mapbox_map.dart';
import '../../../shared/widgets/qaida_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onOpenPlace,
    required this.onOpenFilters,
    required this.onOpenNotifications,
  });

  final Set<String> savedIds;
  final ValueChanged<String> onToggleSaved;
  final ValueChanged<Place> onOpenPlace;
  final Future<void> Function() onOpenFilters;
  final Future<void> Function() onOpenNotifications;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = MockData.categories.first;

  static const _categoryIcons = <String, IconData>{
    'Еда': Icons.restaurant_rounded,
    'Кафе': Icons.coffee_rounded,
    'Бар': Icons.sports_bar_rounded,
    'Парк': Icons.park_rounded,
    'Кино': Icons.movie_rounded,
  };

  static const _moodCollections = <_MoodCollection>[
    _MoodCollection(
      icon: Icons.nightlife_rounded,
      title: 'Для шумного вечера',
      subtitle: '6 баров и лаунжей с музыкой и коктейлями',
      colors: [Color(0xFF111827), Color(0xFF1D4ED8)],
      shadowColor: Color(0x2E0F172A),
    ),
    _MoodCollection(
      icon: Icons.favorite_rounded,
      title: 'Для свидания',
      subtitle: 'Тихие рестораны с атмосферой и красивой подачей',
      colors: [Color(0xFFF97316), Color(0xFFFB7185)],
      shadowColor: Color(0x38F97316),
    ),
    _MoodCollection(
      icon: Icons.wb_sunny_rounded,
      title: 'Для позднего завтрака',
      subtitle: 'Светлые кафе с бранчами, кофе и десертами',
      colors: [Color(0xFF059669), Color(0xFF14B8A6)],
      shadowColor: Color(0x38059669),
    ),
  ];

  static const _events = <_HomeEvent>[
    _HomeEvent(
      month: 'Мар',
      day: '09',
      title: 'Jazz & Dinner в Blue Room',
      meta: '20:30 • 2,1 км • от 1 500 ₽',
      accent: Color(0xFF0F172A),
      isPrimary: false,
    ),
    _HomeEvent(
      month: 'Мар',
      day: '09',
      title: 'Киновечер под открытым небом',
      meta: '21:00 • Центральный парк • бесплатно',
      accent: AppColors.primary,
      isPrimary: true,
    ),
  ];

  List<Place> get _selectedPlaces {
    return MockData.places
        .where((place) => place.category == _selectedCategory)
        .toList();
  }

  List<Place> get _popularPlaces {
    return MockData.places.take(3).toList();
  }

  List<Place> get _nearbyPlaces {
    return MockData.places.take(4).toList();
  }

  Future<void> _openPopularSection() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PlacesSectionScreen(
          title: 'Популярное сегодня',
          subtitle: 'Все популярные места в одной ленте',
          places: _popularPlaces,
          onOpenPlace: widget.onOpenPlace,
        ),
      ),
    );
  }

  Future<void> _openNearbyMapSection() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _MapOverviewScreen(
          title: 'На карте',
          places: _nearbyPlaces,
          onOpenPlace: widget.onOpenPlace,
        ),
      ),
    );
  }

  Future<void> _openMoodCollectionsSection() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _MoodCollectionsScreen(collections: _moodCollections),
      ),
    );
  }

  Future<void> _openEventsCalendarSection() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _EventsCalendarScreen(events: _events, isDark: Theme.of(context).brightness == Brightness.dark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 132),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHeader(
            isDark: isDark,
            notificationCount: MockData.notifications.length > 3
                ? 3
                : MockData.notifications.length,
            onNotificationsTap: widget.onOpenNotifications,
          ),
          const SizedBox(height: 18),
          _HeroCard(
            isDark: isDark,
            onPressed: widget.onOpenFilters,
          ),
          const SizedBox(height: 30),
          _SectionTitle(
            title: 'Категории',
            actionLabel: null,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = MockData.categories[index];
                final isSelected = category == _selectedCategory;
                return _CategoryChip(
                  label: category,
                  icon: _categoryIcons[category] ?? Icons.place_rounded,
                  selected: isSelected,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          _SectionTitle(
            title: 'Популярное сегодня',
            actionLabel: 'Все',
            isDark: isDark,
            onActionTap: _openPopularSection,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 224,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _popularPlaces.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final place = _popularPlaces[index];
                return _PopularPlaceCard(
                  place: place,
                  isDark: isDark,
                  onTap: () => widget.onOpenPlace(place),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          _SectionTitle(
            title: 'Рядом с вами',
            actionLabel: 'На карте',
            isDark: isDark,
            onActionTap: _openNearbyMapSection,
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nearbyPlaces.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.94,
            ),
            itemBuilder: (context, index) {
              final place = _nearbyPlaces[index];
              final meta = _nearbyMeta(place, index);
              return _NearbyPlaceCard(
                place: place,
                meta: meta,
                isDark: isDark,
                onTap: () => widget.onOpenPlace(place),
              );
            },
          ),
          const SizedBox(height: 30),
          _SectionTitle(
            title: 'Подборки для настроения',
            actionLabel: 'Смотреть',
            isDark: isDark,
            onActionTap: _openMoodCollectionsSection,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _moodCollections.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final collection = _moodCollections[index];
                return _MoodCollectionCard(collection: collection);
              },
            ),
          ),
          const SizedBox(height: 30),
          _SectionTitle(
            title: 'События сегодня',
            actionLabel: 'Календарь',
            isDark: isDark,
            onActionTap: _openEventsCalendarSection,
          ),
          const SizedBox(height: 14),
          Column(
            children: _events
                .map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EventCard(event: event, isDark: isDark),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          if (_selectedPlaces.isNotEmpty) ...[
            Text(
              'Под вашу категорию: ${_selectedCategory.toLowerCase()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Сейчас выбрано ${_selectedPlaces.length} мест. Фильтр влияет на подборки выше и помогает быстрее перейти к нужному сценарию.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: bodyTextColor,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  _NearbyMeta _nearbyMeta(Place place, int index) {
    return switch (index) {
      0 => const _NearbyMeta(
          leadLabel: '5 мин пешком',
          statusLabel: 'Открыто до 23:00',
          accentBackground: Color(0xFFECFDF5),
          accentForeground: Color(0xFF059669),
          statusColor: Color(0xFF059669),
          icon: Icons.local_cafe_rounded,
        ),
      1 => const _NearbyMeta(
          leadLabel: '8 мин пешком',
          statusLabel: 'Есть очередь',
          accentBackground: Color(0xFFFFF1F2),
          accentForeground: Color(0xFFF43F5E),
          statusColor: Color(0xFFF43F5E),
          icon: Icons.ramen_dining_rounded,
        ),
      2 => const _NearbyMeta(
          leadLabel: '12 мин на такси',
          statusLabel: 'Вид на закат',
          accentBackground: Color(0xFFEFF6FF),
          accentForeground: Color(0xFF0284C7),
          statusColor: Color(0xFF0284C7),
          icon: Icons.deck_rounded,
        ),
      _ => const _NearbyMeta(
          leadLabel: 'Живая музыка в 21:00',
          statusLabel: 'Сегодня вход свободный',
          accentBackground: Color(0xFFF5F3FF),
          accentForeground: Color(0xFF7C3AED),
          statusColor: Color(0xFF7C3AED),
          icon: Icons.music_note_rounded,
        ),
    };
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.isDark,
    required this.notificationCount,
    required this.onNotificationsTap,
  });

  final bool isDark;
  final int notificationCount;
  final Future<void> Function() onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primarySoft],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x402563EB),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineMedium,
              children: [
                const TextSpan(text: 'Привет 👋 '),
                TextSpan(
                  text: 'Гость',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? AppColors.darkText : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onNotificationsTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xDD13203A) : const Color(0xE6FFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          size: 18,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xDD13203A) : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$notificationCount',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.isDark, required this.onTap});

  final bool isDark;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
              ),
              const SizedBox(width: 12),
              Text(
                'Поиск мест...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.isDark, required this.onPressed});

  final bool isDark;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF163777), Color(0xFF13203A)]
              : const [Color(0xFFEEF6FF), Color(0xFFDBEAFE)],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -62,
            right: -72,
            child: Container(
              height: 190,
              width: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -16,
            right: 8,
            child: Icon(
              Icons.explore_rounded,
              size: 92,
              color: AppColors.primary.withValues(alpha: 0.22),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Не знаешь куда сходить?',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Открой для себя лучшие заведения города',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.82)
                          : AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Найти место',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    required this.isDark,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final bool isDark;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        if (actionLabel != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  actionLabel!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionScaffold extends StatelessWidget {
  const _SectionScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                  ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: child),
    );
  }
}

class _PlacesSectionScreen extends StatelessWidget {
  const _PlacesSectionScreen({
    required this.title,
    required this.subtitle,
    required this.places,
    required this.onOpenPlace,
  });

  final String title;
  final String subtitle;
  final List<Place> places;
  final ValueChanged<Place> onOpenPlace;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SectionScaffold(
      title: title,
      subtitle: subtitle,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: places.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) => _PopularPlaceCard(
          place: places[index],
          isDark: isDark,
          onTap: () => onOpenPlace(places[index]),
        ),
      ),
    );
  }
}

class _MapOverviewScreen extends StatefulWidget {
  const _MapOverviewScreen({
    required this.title,
    required this.places,
    required this.onOpenPlace,
  });

  final String title;
  final List<Place> places;
  final ValueChanged<Place> onOpenPlace;

  @override
  State<_MapOverviewScreen> createState() => _MapOverviewScreenState();
}

class _MapOverviewScreenState extends State<_MapOverviewScreen> {
  late Place _selectedPlace = widget.places.first;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SectionScaffold(
      title: widget.title,
      subtitle: 'Карта и список ближайших мест',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Stack(
            children: [
              SizedBox(
                height: 320,
                child: QaidaMapboxMap(
                  places: widget.places,
                  focusPlace: _selectedPlace,
                  onPlaceTap: (place) => setState(() => _selectedPlace = place),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _MapPlaceSheet(
                  place: _selectedPlace,
                  isDark: isDark,
                  onOpenPlace: () => widget.onOpenPlace(_selectedPlace),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.places.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NearbyPlaceCard(
                    place: entry.value,
                    meta: _mapMeta(entry.key),
                    isDark: isDark,
                    onTap: () => setState(() => _selectedPlace = entry.value),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  _NearbyMeta _mapMeta(int index) {
    return switch (index) {
      0 => const _NearbyMeta(
          leadLabel: '2 мин пешком',
          statusLabel: 'Отмечено на карте',
          accentBackground: Color(0xFFEFF6FF),
          accentForeground: AppColors.primary,
          statusColor: AppColors.primary,
          icon: Icons.place_rounded,
        ),
      1 => const _NearbyMeta(
          leadLabel: '5 мин пешком',
          statusLabel: 'Удобный маршрут',
          accentBackground: Color(0xFFECFDF5),
          accentForeground: Color(0xFF059669),
          statusColor: Color(0xFF059669),
          icon: Icons.route_rounded,
        ),
      _ => const _NearbyMeta(
          leadLabel: 'Открыть маршрут',
          statusLabel: 'Посмотреть на карте',
          accentBackground: Color(0xFFF5F3FF),
          accentForeground: Color(0xFF7C3AED),
          statusColor: Color(0xFF7C3AED),
          icon: Icons.navigation_rounded,
        ),
    };
  }
}

class _MapPlaceSheet extends StatelessWidget {
  const _MapPlaceSheet({
    required this.place,
    required this.isDark,
    required this.onOpenPlace,
  });

  final Place place;
  final bool isDark;
  final VoidCallback onOpenPlace;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xDD0F172A) : Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MapPlaceSheetContent(place: place, isDark: isDark),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onOpenPlace,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Открыть'),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _MapPlaceSheetContent(place: place, isDark: isDark)),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: onOpenPlace,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Открыть'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _MapPlaceSheetContent extends StatelessWidget {
  const _MapPlaceSheetContent({required this.place, required this.isDark});

  final Place place;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 62,
            height: 62,
            child: QaidaNetworkImage(imageUrl: place.imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${place.neighborhood} · ${place.distanceKm.toStringAsFixed(1)} км',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 4),
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MoodCollectionsScreen extends StatelessWidget {
  const _MoodCollectionsScreen({required this.collections});

  final List<_MoodCollection> collections;

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: 'Подборки',
      subtitle: 'Собранные сценарии для настроения',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: collections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) => SizedBox(
          height: 180,
          child: _MoodCollectionCard(collection: collections[index]),
        ),
      ),
    );
  }
}

class _EventsCalendarScreen extends StatelessWidget {
  const _EventsCalendarScreen({required this.events, required this.isDark});

  final List<_HomeEvent> events;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: 'Календарь',
      subtitle: 'Все события на сегодня',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _EventCard(event: events[index], isDark: isDark),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0)),
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1A2463EB),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                      spreadRadius: 0,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x0D0F172A),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? Colors.white
                          : (isDark ? AppColors.darkText : const Color(0xFF475569)),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularPlaceCard extends StatelessWidget {
  const _PopularPlaceCard({
    required this.place,
    required this.isDark,
    required this.onTap,
  });

  final Place place;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      QaidaNetworkImage(imageUrl: place.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                place.rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                place.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${place.category} • ${place.priceLabel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyPlaceCard extends StatelessWidget {
  const _NearbyPlaceCard({
    required this.place,
    required this.meta,
    required this.isDark,
    required this.onTap,
  });

  final Place place;
  final _NearbyMeta meta;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: meta.accentBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(meta.icon, color: meta.accentForeground),
              ),
              const Spacer(),
              Text(
                place.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                meta.leadLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                meta.statusLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: meta.statusColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodCollectionCard extends StatelessWidget {
  const _MoodCollectionCard({required this.collection});

  final _MoodCollection collection;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: collection.colors,
        ),
        boxShadow: [
          BoxShadow(
            color: collection.shadowColor,
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(collection.icon, color: Colors.white),
          ),
          const Spacer(),
          Text(
            collection.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            collection.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.isDark});

  final _HomeEvent event;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: event.accent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.month,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: event.isPrimary ? 0.7 : 0.6),
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  event.day,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.meta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.arrow_outward_rounded,
              size: 20,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodCollection {
  const _MoodCollection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.shadowColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Color shadowColor;
}

class _NearbyMeta {
  const _NearbyMeta({
    required this.leadLabel,
    required this.statusLabel,
    required this.accentBackground,
    required this.accentForeground,
    required this.statusColor,
    required this.icon,
  });

  final String leadLabel;
  final String statusLabel;
  final Color accentBackground;
  final Color accentForeground;
  final Color statusColor;
  final IconData icon;
}

class _HomeEvent {
  const _HomeEvent({
    required this.month,
    required this.day,
    required this.title,
    required this.meta,
    required this.accent,
    required this.isPrimary,
  });

  final String month;
  final String day;
  final String title;
  final String meta;
  final Color accent;
  final bool isPrimary;
}