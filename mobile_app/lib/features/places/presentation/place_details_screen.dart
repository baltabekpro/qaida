import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/models/place.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/qaida_mapbox_map.dart';
import '../../../shared/widgets/qaida_network_image.dart';
import '../../../shared/widgets/qaida_scaffold.dart';

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({
    super.key,
    required this.place,
    required this.saved,
    required this.onSavedToggle,
  });

  final Place place;
  final bool saved;
  final VoidCallback onSavedToggle;

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  _PlaceDetailsTab _activeTab = _PlaceDetailsTab.info;
  String? _fullscreenImage;
  late List<_PlaceReview> _reviews = List.of(_details.initialReviews);
  final Map<int, int> _cartItems = <int, int>{};

  _PlaceDetailsContent get _details => _detailsForPlace(widget.place);

  int get _cartItemsCount =>
      _cartItems.values.fold<int>(0, (sum, count) => sum + count);

  int get _cartTotalAmount {
    var total = 0;
    for (final item in _details.menu) {
      total += _parsePrice(item.price) * (_cartItems[item.id] ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseSurface = isDark ? AppColors.darkBg : const Color(0xFFF1F5F9);

    return QaidaScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight > 760 ? 286.0 : 258.0;

          return Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: baseSurface)),
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 116),
                  child: Column(
                    children: [
                      SizedBox(
                        height: heroHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            QaidaNetworkImage(
                              imageUrl: _details.images.first,
                              fit: BoxFit.cover,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.18),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.28),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 14,
                              right: 14,
                              child: Row(
                                children: [
                                  _HeroCircleButton(
                                    icon: Icons.chevron_left_rounded,
                                    onTap: () => Navigator.of(context).pop(),
                                  ),
                                  const Spacer(),
                                  _HeroCircleButton(
                                    icon: widget.saved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    iconColor: widget.saved
                                        ? const Color(0xFFFACC15)
                                        : Colors.white,
                                    onTap: widget.onSavedToggle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.12),
                                blurRadius: 28,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 56,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFCBD5E1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Детали места',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(letterSpacing: 1.8),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            widget.place.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDBEAFE),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        _details.status,
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _InfoPill(
                                      icon: Icons.star_rounded,
                                      iconColor: const Color(0xFFFBBF24),
                                      text: '${widget.place.rating.toStringAsFixed(1)} (${_reviews.length + 126})',
                                      strong: true,
                                    ),
                                    _InfoPill(
                                      icon: Icons.payments_outlined,
                                      iconColor: const Color(0xFF16A34A),
                                      text: _details.budget,
                                    ),
                                    _InfoPill(
                                      icon: Icons.schedule_rounded,
                                      iconColor: isDark
                                          ? AppColors.darkTextSecondary
                                          : const Color(0xFF64748B),
                                      text: _details.workingHours,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                _DetailsTabBar(
                                  activeTab: _activeTab,
                                  onChanged: (tab) => setState(() => _activeTab = tab),
                                ),
                                const SizedBox(height: 22),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeOutCubic,
                                  child: KeyedSubtree(
                                    key: ValueKey(_activeTab),
                                    child: switch (_activeTab) {
                                      _PlaceDetailsTab.info => _InfoTab(
                                          isDark: isDark,
                                          details: _details,
                                          place: widget.place,
                                          onImageTap: (image) => setState(() => _fullscreenImage = image),
                                          onShare: () => _showMessage('Ссылка на место скопирована'),
                                          onMap: _openPlaceMap,
                                          onSave: () {
                                            widget.onSavedToggle();
                                            _showMessage(widget.saved
                                                ? 'Место убрано из сохранённых'
                                                : 'Место сохранено');
                                          },
                                          onReport: () => _showMessage('Жалоба отправлена'),
                                        ),
                                      _PlaceDetailsTab.menu => _MenuTab(
                                          items: _details.menu,
                                          onImageTap: (image) =>
                                            setState(() => _fullscreenImage = image),
                                          onAddToCart: _addToCart,
                                          cartCountFor: (item) => _cartItems[item.id] ?? 0,
                                        ),
                                      _PlaceDetailsTab.reviews => _ReviewsTab(
                                          reviews: _reviews,
                                          onAddReview: _openAddReview,
                                        ),
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _activeTab == _PlaceDetailsTab.menu
                    ? _MenuCartBar(
                        itemCount: _cartItemsCount,
                        totalLabel: _formatPrice(_cartTotalAmount),
                        onPressed: _cartItemsCount == 0
                            ? null
                            : () => _showMessage('Корзина скоро будет доступна'),
                      )
                    : _BookingBar(
                        onPressed: () => _showMessage('Бронирование скоро будет доступно'),
                      ),
              ),
              if (_fullscreenImage != null)
                _FullscreenGallery(
                  images: _details.images,
                  currentImage: _fullscreenImage!,
                  onSelectImage: (image) => setState(() => _fullscreenImage = image),
                  onClose: () => setState(() => _fullscreenImage = null),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openAddReview() async {
    final result = await showModalBottomSheet<_ReviewDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetFrame(
        title: 'Ваш отзыв',
        child: _AddReviewSheet(initialName: 'Вы', placeTitle: widget.place.title),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _reviews = [
        _PlaceReview(
          id: DateTime.now().millisecondsSinceEpoch,
          user: result.user,
          date: 'Только что',
          text: result.text,
          rating: result.rating,
        ),
        ..._reviews,
      ];
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openPlaceMap() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PlaceMapScreen(place: widget.place),
      ),
    );
  }

  void _addToCart(_MenuItem item) {
    setState(() {
      _cartItems.update(item.id, (count) => count + 1, ifAbsent: () => 1);
    });
  }

  int _parsePrice(String rawPrice) {
    final digits = rawPrice.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  String _formatPrice(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      final reverseIndex = digits.length - index;
      buffer.write(digits[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(' ');
      }
    }
    return '$buffer ₽';
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.black.withValues(alpha: 0.24),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.strong = false,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: strong
                    ? AppColors.primary
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : const Color(0xFF64748B),
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _DetailsTabBar extends StatelessWidget {
  const _DetailsTabBar({required this.activeTab, required this.onChanged});

  final _PlaceDetailsTab activeTab;
  final ValueChanged<_PlaceDetailsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider)),
      ),
      child: Row(
        children: _PlaceDetailsTab.values.map((tab) {
          final selected = tab == activeTab;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 16,
                      color: selected
                          ? AppColors.primary
                          : Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: selected
                                ? AppColors.primary
                                : Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkTextSecondary
                                    : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.isDark,
    required this.details,
    required this.place,
    required this.onImageTap,
    required this.onShare,
    required this.onMap,
    required this.onSave,
    required this.onReport,
  });

  final bool isDark;
  final _PlaceDetailsContent details;
  final Place place;
  final ValueChanged<String> onImageTap;
  final VoidCallback onShare;
  final VoidCallback onMap;
  final VoidCallback onSave;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('info-tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: details.images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final image = details.images[index];
            return _GalleryTile(imageUrl: image, onTap: () => onImageTap(image));
          },
        ),
        const SizedBox(height: 18),
        Text(
          details.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
              ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
            ),
          ),
          child: Column(
            children: [
              _DetailLine(icon: Icons.place_rounded, text: place.neighborhood),
              const SizedBox(height: 12),
              _DetailLine(icon: Icons.route_rounded, text: '${place.distanceKm.toStringAsFixed(1)} км'),
              const SizedBox(height: 12),
              _DetailLine(icon: Icons.language_rounded, text: 'terrace-grill.qaida.app'),
              const SizedBox(height: 12),
              _DetailLine(icon: Icons.phone_rounded, text: '+7 (700) 123-45-67'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _ActionTile(label: 'Поделиться', icon: Icons.share_rounded, onTap: onShare),
        const SizedBox(height: 12),
        _ActionTile(label: 'Открыть в карте', icon: Icons.map_rounded, onTap: onMap),
        const SizedBox(height: 12),
        _ActionTile(label: 'Сохранить в коллекцию', icon: Icons.bookmark_add_outlined, onTap: onSave),
        const SizedBox(height: 12),
        _ActionTile(
          label: 'Пожаловаться',
          icon: Icons.flag_outlined,
          onTap: onReport,
          isDanger: true,
        ),
      ],
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab({
    required this.items,
    required this.onImageTap,
    required this.onAddToCart,
    required this.cartCountFor,
  });

  final List<_MenuItem> items;
  final ValueChanged<String> onImageTap;
  final ValueChanged<_MenuItem> onAddToCart;
  final int Function(_MenuItem item) cartCountFor;

  @override
  Widget build(BuildContext context) {
    final categories = _menuCategories
        .where((category) => items.any((item) => item.category == category.name))
        .toList();

    return Column(
      key: const ValueKey('menu-tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...categories.map((category) {
          final scoped = items.where((item) => item.category == category.name).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _MenuCategorySection(
              category: category,
              items: scoped,
              onImageTap: onImageTap,
              onAddToCart: onAddToCart,
              cartCountFor: cartCountFor,
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.reviews, required this.onAddReview});

  final List<_PlaceReview> reviews;
  final VoidCallback onAddReview;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('reviews-tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Отзывы гостей',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: onAddReview,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: const Color(0xFFEFF6FF),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Написать'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...reviews.map((review) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _ReviewCard(review: review),
            )),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.imageUrl, required this.onTap});

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: QaidaNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkText : const Color(0xFF334155),
                ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDanger
        ? (isDark ? const Color(0x33262525) : const Color(0xFFFFF1F2))
        : (isDark ? AppColors.darkCard : Colors.white);
    final border = isDanger
        ? (isDark ? const Color(0x66B91C1C) : const Color(0xFFFECDD3))
        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9));
    final foreground = isDanger
        ? const Color(0xFFE11D48)
        : (isDark ? AppColors.darkText : const Color(0xFF1E293B));
    final iconColor = isDanger ? const Color(0xFFE11D48) : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
            boxShadow: isDanger
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: foreground),
              ),
              const Spacer(),
              Icon(icon, size: 20, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCategorySection extends StatelessWidget {
  const _MenuCategorySection({
    required this.category,
    required this.items,
    required this.onImageTap,
    required this.onAddToCart,
    required this.cartCountFor,
  });

  final _MenuCategory category;
  final List<_MenuItem> items;
  final ValueChanged<String> onImageTap;
  final ValueChanged<_MenuItem> onAddToCart;
  final int Function(_MenuItem item) cartCountFor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xCC0F172A) : const Color(0xF8F8FAFC),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13203A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Icon(category.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} блюда',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MenuShowcaseCard(
              item: item,
              count: cartCountFor(item),
              onImageTap: () => onImageTap(item.imageUrl),
              onAddToCart: () => onAddToCart(item),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuShowcaseCard extends StatelessWidget {
  const _MenuShowcaseCard({
    required this.item,
    required this.count,
    required this.onImageTap,
    required this.onAddToCart,
  });

  final _MenuItem item;
  final int count;
  final VoidCallback onImageTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    QaidaNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.image_outlined, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        item.price,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const Spacer(),
                      if (count > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '$count',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      Material(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onAddToCart,
                          child: SizedBox(
                            width: 34,
                            height: 34,
                            child: Icon(
                              Icons.add_rounded,
                              color: isDark ? Colors.white : const Color(0xFF475569),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _PlaceReview review;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  review.user.characters.first,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: index < review.rating ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 14, 16, bottomInset > 0 ? bottomInset + 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Забронировать стол'),
          ),
        ),
      ),
    );
  }
}

class _MenuCartBar extends StatelessWidget {
  const _MenuCartBar({
    required this.itemCount,
    required this.totalLabel,
    required this.onPressed,
  });

  final int itemCount;
  final String totalLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 14, 16, bottomInset > 0 ? bottomInset + 12 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xCC09111F)
                : Colors.white.withValues(alpha: 0.82),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF1F5F9),
              ),
            ),
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
              backgroundColor: const Color(0xFF0F172A),
              disabledBackgroundColor: const Color(0xFF334155),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 22),
            ),
            child: Row(
              children: [
                Text(
                  'Корзина',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$itemCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  totalLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF60A5FA),
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenGallery extends StatelessWidget {
  const _FullscreenGallery({
    required this.images,
    required this.currentImage,
    required this.onSelectImage,
    required this.onClose,
  });

  final List<String> images;
  final String currentImage;
  final ValueChanged<String> onSelectImage;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _HeroCircleButton(
                    icon: Icons.close_rounded,
                    onTap: onClose,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: QaidaNetworkImage(
                    imageUrl: currentImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images
                      .map(
                        (image) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () => onSelectImage(image),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 180),
                              scale: currentImage == image ? 1.08 : 1,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: currentImage == image
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Opacity(
                                    opacity: currentImage == image ? 1 : 0.5,
                                    child: QaidaNetworkImage(imageUrl: image, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceMapScreen extends StatelessWidget {
  const _PlaceMapScreen({required this.place});

  final Place place;

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
        title: Text(place.title),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 320,
              width: double.infinity,
              child: QaidaMapboxMap(
                places: [place],
                focusPlace: place,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.neighborhood,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF64748B),
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.route_rounded),
                    label: const Text('Построить маршрут'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetFrame extends StatelessWidget {
  const _BottomSheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullMenuSheet extends StatelessWidget {
  const _FullMenuSheet({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final categories = items.map((item) => item.category).toSet().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        final scoped = items.where((item) => item.category == category).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
                ),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              ...scoped.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF94A3B8),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          item.price,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AddReviewSheet extends StatefulWidget {
  const _AddReviewSheet({required this.initialName, required this.placeTitle});

  final String initialName;
  final String placeTitle;

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  final TextEditingController _controller = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _controller.text.trim().isNotEmpty;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Оцените ваше посещение',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                iconSize: 34,
                icon: Icon(
                  Icons.star_rounded,
                  color: index < _rating ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Комментарий',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Расскажите о ваших впечатлениях...',
              filled: true,
              fillColor: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: canSubmit
                ? () => Navigator.of(context).pop(
                      _ReviewDraft(
                        user: widget.initialName,
                        rating: _rating,
                        text: _controller.text.trim(),
                      ),
                    )
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Отправить отзыв'),
          ),
        ],
      ),
    );
  }
}

enum _PlaceDetailsTab {
  info('Обзор', Icons.info_outline_rounded),
  menu('Меню', Icons.restaurant_menu_rounded),
  reviews('Отзывы', Icons.mode_comment_outlined);

  const _PlaceDetailsTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _PlaceDetailsContent {
  const _PlaceDetailsContent({
    required this.status,
    required this.budget,
    required this.workingHours,
    required this.description,
    required this.images,
    required this.menu,
    required this.initialReviews,
  });

  final String status;
  final String budget;
  final String workingHours;
  final String description;
  final List<String> images;
  final List<_MenuItem> menu;
  final List<_PlaceReview> initialReviews;
}

class _MenuItem {
  const _MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String price;
  final String description;
  final String category;
  final String imageUrl;
}

class _MenuCategory {
  const _MenuCategory(this.name, this.icon);

  final String name;
  final IconData icon;
}

const _menuCategories = <_MenuCategory>[
  _MenuCategory('Закуски', Icons.waves_rounded),
  _MenuCategory('Салаты', Icons.eco_rounded),
  _MenuCategory('Супы', Icons.soup_kitchen_rounded),
  _MenuCategory('Горячее', Icons.local_fire_department_rounded),
  _MenuCategory('Десерты', Icons.cake_rounded),
];

class _PlaceReview {
  const _PlaceReview({
    required this.id,
    required this.user,
    required this.date,
    required this.text,
    required this.rating,
  });

  final int id;
  final String user;
  final String date;
  final String text;
  final int rating;
}

class _ReviewDraft {
  const _ReviewDraft({
    required this.user,
    required this.rating,
    required this.text,
  });

  final String user;
  final int rating;
  final String text;
}

_PlaceDetailsContent _detailsForPlace(Place place) {
  switch (place.id) {
    case 'azure-courtyard':
      return _PlaceDetailsContent(
        status: 'Открыто',
        budget: '₽₽ - ₽₽₽',
        workingHours: '10:00 – 23:00',
        description:
            'Современный ресторан с мягким вечерним светом и панорамным видом на историческую часть города.',
        images: const [
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=1200',
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&q=80&w=1200',
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=1200',
        ],
        menu: const [
          _MenuItem(
            id: 1,
            name: 'Стейк Рибай',
            price: '2400 ₽',
            description: 'Мраморная говядина зернового откорма',
            category: 'Горячее',
            imageUrl: 'https://images.unsplash.com/photo-1600891964092-4316c288032e?auto=format&fit=crop&q=60&w=400',
          ),
          _MenuItem(
            id: 2,
            name: 'Салат Цезарь',
            price: '850 ₽',
            description: 'С креветками на гриле и пармезаном',
            category: 'Салаты',
            imageUrl: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&q=60&w=400',
          ),
          _MenuItem(
            id: 3,
            name: 'Ризотто с грибами',
            price: '1100 ₽',
            description: 'Белые грибы, трюфельное масло',
            category: 'Горячее',
            imageUrl: 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?auto=format&fit=crop&q=60&w=400',
          ),
          _MenuItem(
            id: 4,
            name: 'Тартар из тунца',
            price: '1250 ₽',
            description: 'С авокадо и соусом понзу',
            category: 'Закуски',
            imageUrl: 'https://images.unsplash.com/photo-1546039907-7fa05f864c02?auto=format&fit=crop&q=60&w=400',
          ),
          _MenuItem(
            id: 5,
            name: 'Том Ям',
            price: '950 ₽',
            description: 'Классический острый суп с морепродуктами',
            category: 'Супы',
            imageUrl: 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?auto=format&fit=crop&q=60&w=400',
          ),
          _MenuItem(
            id: 6,
            name: 'Тирамису',
            price: '600 ₽',
            description: 'Домашний десерт с маскарпоне',
            category: 'Десерты',
            imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&q=60&w=400',
          ),
        ],
        initialReviews: const [
          _PlaceReview(
            id: 1,
            user: 'Александр В.',
            date: 'Вчера',
            text: 'Потрясающий вид и очень нежное мясо. Вернемся снова!',
            rating: 5,
          ),
          _PlaceReview(
            id: 2,
            user: 'Марина К.',
            date: '3 дня назад',
            text: 'Уютное место, но вечером лучше бронировать заранее.',
            rating: 4,
          ),
        ],
      );
    default:
      return _PlaceDetailsContent(
        status: 'Открыто',
        budget: '${place.priceLabel} - ${place.priceLabel}',
        workingHours: '09:00 – 22:00',
        description: place.subtitle,
        images: [
          place.imageUrl,
          'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&q=80&w=1200',
          'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&q=80&w=1200',
        ],
        menu: const [
          _MenuItem(
            id: 11,
            name: 'Фирменное блюдо',
            price: '1400 ₽',
            description: 'Главная позиция заведения с сезонной подачей',
            category: 'Горячее',
            imageUrl: 'https://images.unsplash.com/photo-1600891964092-4316c288032e?auto=format&fit=crop&q=60&w=400',
          ),
          _MenuItem(
            id: 12,
            name: 'Лёгкая закуска',
            price: '750 ₽',
            description: 'Идеально к вечеру и неспешной встрече',
            category: 'Закуски',
            imageUrl: 'https://images.unsplash.com/photo-1546039907-7fa05f864c02?auto=format&fit=crop&q=60&w=400',
          ),
          _MenuItem(
            id: 13,
            name: 'Авторский десерт',
            price: '520 ₽',
            description: 'Нежный финиш с мягкой сладостью',
            category: 'Десерты',
            imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&q=60&w=400',
          ),
        ],
        initialReviews: const [
          _PlaceReview(
            id: 21,
            user: 'Гость',
            date: 'Сегодня',
            text: 'Атмосферное место и приятная подача. Зайду ещё.',
            rating: 5,
          ),
          _PlaceReview(
            id: 22,
            user: 'Айжан Т.',
            date: '2 дня назад',
            text: 'Спокойно, вкусно и без лишнего шума.',
            rating: 4,
          ),
        ],
      );
  }
}
