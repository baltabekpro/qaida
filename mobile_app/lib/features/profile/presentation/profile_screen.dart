import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/qaida_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  static const _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDmSDHU8OooC4XjK7v7OmG7eXHf6WAJNjhEFpb4dKodjSXAEJBgl2Zl-lj5hBJaoibDb4m7zbETAn9uq3HORRqJhNUYbyNWbvL7MwcP0Ly4-Kl8dvqyLoDn8dFWZaj0nnS-3EIdwZyTIyPp8_py_lPOc74ge2eJRkf6pdjDbNJ8uqwlJr9BiCBo-n_rBDWlmYx-iyaQ85S9I8BqNycQfH7JvEf2XD0DLHxRaF2iSZTmLEHI6IhBWdm9Z_izFzjtsoYoRNuOc-vabw';

  static const _reviewHistoryItems = <String>[
    'Luna Terrace · Отличная терраса и спокойный сервис',
    'Blue Room · Коктейли понравились, музыка немного громкая',
    'Noon Bistro · Хороший бранч и быстрый сервис',
    'Azure Courtyard · Красивый двор, но вечером лучше бронировать',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLightMode = themeMode != ThemeMode.dark;

    return Stack(
      children: [
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 0.8,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _ProfileHero(isDark: isDark),
              const SizedBox(height: 28),
              _StatsRow(isDark: isDark),
              const SizedBox(height: 28),
              _SectionTitle(title: 'Настройки профиля'),
              const SizedBox(height: 12),
              _ProfilePanel(
                isDark: isDark,
                children: [
                  _ProfileActionTile(
                    icon: Icons.person_rounded,
                    label: 'Мои данные',
                    isDark: isDark,
                    onTap: () => _openPage(
                      context,
                      _MyDataScreen(
                        avatarUrl: _avatarUrl,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  _PanelDivider(isDark: isDark),
                  _ProfileActionTile(
                    icon: Icons.rate_review_rounded,
                    leading: _ReviewHistoryIcon(
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF3F495E),
                    ),
                    label: 'История отзывов',
                    isDark: isDark,
                    onTap: () => _openPage(
                      context,
                      _SearchHistoryScreen(historyItems: _reviewHistoryItems),
                    ),
                  ),
                  _PanelDivider(isDark: isDark),
                  _ProfileActionTile(
                    icon: Icons.notifications_rounded,
                    label: 'Уведомления',
                    isDark: isDark,
                    onTap: () => _openPage(
                      context,
                      const _NotificationPreferencesScreen(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfilePanel(
                isDark: isDark,
                children: [
                  _ProfileActionTile(
                    icon: Icons.language_rounded,
                    label: 'Язык',
                    isDark: isDark,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Русский',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                    onTap: () => _openPage(
                      context,
                      const _LanguageScreen(),
                    ),
                  ),
                  _PanelDivider(isDark: isDark),
                  _ThemeTile(
                    isDark: isDark,
                    isLightMode: isLightMode,
                    onChanged: (value) {
                      onThemeModeChanged(
                        value ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),
                  _PanelDivider(isDark: isDark),
                  _ProfileActionTile(
                    icon: Icons.help_rounded,
                    label: 'Помощь',
                    isDark: isDark,
                    onTap: () => _openPage(context, const _HelpScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LogoutButton(
                isDark: isDark,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из профиля?'),
        content: const Text(
          'Это пока демонстрационный экран профиля. Выход можно подключить, когда появится клиентская авторизация.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPage(BuildContext context, Widget page) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ClipOval(
                child: const QaidaNetworkImage(
                  imageUrl: ProfileScreen._avatarUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBg : Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Александр',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'alexander@qaida.app',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('12', 'мест'),
      ('5', 'отзывов'),
      ('24', 'в избранном'),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: item == items.last ? 0 : 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0x2894A3B8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.$1,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              letterSpacing: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              letterSpacing: 1.8,
            ),
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.isDark, required this.children});

  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0x2894A3B8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13203A) : const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: leading ??
                      Icon(
                        icon,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF475569),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewHistoryIcon extends StatelessWidget {
  const _ReviewHistoryIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _ReviewHistoryIconPainter(color),
    );
  }
}

class _ReviewHistoryIconPainter extends CustomPainter {
  const _ReviewHistoryIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final bubblePath = Path()
      ..moveTo(size.width * 0.84, size.height * 0.12)
      ..lineTo(size.width * 0.16, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.08,
        size.height * 0.12,
        size.width * 0.08,
        size.height * 0.20,
      )
      ..lineTo(size.width * 0.08, size.height * 0.76)
      ..lineTo(size.width * 0.26, size.height * 0.60)
      ..lineTo(size.width * 0.84, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.60,
        size.width * 0.92,
        size.height * 0.52,
      )
      ..lineTo(size.width * 0.92, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.12,
        size.width * 0.84,
        size.height * 0.12,
      )
      ..close();

    canvas.drawPath(bubblePath, paint);
  }

  @override
  bool shouldRepaint(covariant _ReviewHistoryIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.isDark,
    required this.isLightMode,
    required this.onChanged,
  });

  final bool isDark;
  final bool isLightMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13203A) : const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.dark_mode_rounded,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Светлая тема',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Switch.adaptive(
            value: isLightMode,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PanelDivider extends StatelessWidget {
  const _PanelDivider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0x2894A3B8),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0x2894A3B8),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x1AF43F5E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFF43F5E)),
              ),
              const SizedBox(width: 16),
              Text(
                'Выйти',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFF43F5E),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSubpageScaffold extends StatelessWidget {
  const _ProfileSubpageScaffold({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBg.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.92),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _MyDataScreen extends StatelessWidget {
  const _MyDataScreen({required this.avatarUrl, required this.isDark});

  final String avatarUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _ProfileSubpageScaffold(
      title: 'Мои данные',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(isDark),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                    ),
                    child: ClipOval(
                      child: QaidaNetworkImage(imageUrl: avatarUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Профиль',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                letterSpacing: 1.8,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Александр',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'alexander@qaida.app',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Личные данные',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          letterSpacing: 1.8,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _InfoField(title: 'Имя', value: 'Александр', isDark: isDark),
                  const SizedBox(height: 12),
                  _InfoField(title: 'Город', value: 'Алматы', isDark: isDark),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Любимые сценарии',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _PrimaryChip(label: 'Кофе'),
                            _PrimaryChip(label: 'Прогулки'),
                            _PrimaryChip(label: 'Тихие ужины'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Сохранить изменения'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPreferencesScreen extends StatefulWidget {
  const _NotificationPreferencesScreen();

  @override
  State<_NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<_NotificationPreferencesScreen> {
  bool _nearbyPlaces = true;
  bool _bookingReminders = true;
  bool _savedCollections = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ProfileSubpageScaffold(
      title: 'Настройки уведомлений',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _SettingsSection(
              title: 'Системные уведомления',
              isDark: isDark,
              children: [
                _NotificationToggleTile(
                  title: 'Новые места рядом',
                  subtitle: 'Когда появляются подходящие места поблизости.',
                  value: _nearbyPlaces,
                  onChanged: (value) => setState(() => _nearbyPlaces = value),
                ),
                const SizedBox(height: 12),
                _NotificationToggleTile(
                  title: 'Напоминания о брони',
                  subtitle: 'За 30 минут до визита и в момент выхода.',
                  value: _bookingReminders,
                  onChanged: (value) => setState(() => _bookingReminders = value),
                ),
                const SizedBox(height: 12),
                _NotificationToggleTile(
                  title: 'Сохранённые коллекции',
                  subtitle: 'Изменения в общих подборках и папках.',
                  value: _savedCollections,
                  onChanged: (value) => setState(() => _savedCollections = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Каналы',
              isDark: isDark,
              children: [
                _ChannelTile(
                  title: 'Push-уведомления',
                  value: 'Включены',
                  primary: true,
                ),
                const SizedBox(height: 12),
                const _ChannelTile(
                  title: 'Email-дайджест',
                  value: '1 раз в неделю',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHistoryScreen extends StatelessWidget {
  const _SearchHistoryScreen({required this.historyItems});

  final List<String> historyItems;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ProfileSubpageScaffold(
      title: 'История отзывов',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _SettingsSection(
              title: 'Последние отзывы',
              isDark: isDark,
              children: historyItems
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.rate_review_rounded,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Быстрые сценарии',
              isDark: isDark,
              children: const [
                _ScenarioHint(title: 'Кофейни рядом', body: 'Для коротких встреч и утреннего кофе.'),
                SizedBox(height: 12),
                _ScenarioHint(title: 'Тихий ужин', body: 'Спокойные рестораны на вечер без громкой посадки.'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageScreen extends StatefulWidget {
  const _LanguageScreen();

  @override
  State<_LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<_LanguageScreen> {
  String _selectedLanguage = 'Русский';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const languages = ['Русский', 'English', 'Қазақша'];

    return _ProfileSubpageScaffold(
      title: 'Язык',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: _SettingsSection(
          title: 'Язык интерфейса',
          isDark: isDark,
          children: languages
              .map(
                (language) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _selectedLanguage = language),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _selectedLanguage == language
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                language,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            if (_selectedLanguage == language)
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
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
      ),
    );
  }
}

class _HelpScreen extends StatelessWidget {
  const _HelpScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ProfileSubpageScaffold(
      title: 'Помощь',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _SettingsSection(
              title: 'Частые вопросы',
              isDark: isDark,
              children: const [
                _HelpTile(
                  title: 'Как работают рекомендации?',
                  body: 'Мы учитываем сценарии поиска, сохранённые места и выбранные фильтры.',
                ),
                SizedBox(height: 12),
                _HelpTile(
                  title: 'Можно ли делиться коллекциями?',
                  body: 'Да, раздел коллекций уже подготовлен под совместные подборки и шаринг.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Связаться с нами',
              isDark: isDark,
              children: const [
                _ContactTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'support@qaida.app',
                  subtitle: 'Ответим по вопросам профиля и рекомендаций.',
                ),
                SizedBox(height: 12),
                _ContactTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Чат поддержки',
                  subtitle: 'Быстрый способ сообщить об ошибке или предложении.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.isDark,
    required this.children,
  });

  final String title;
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  letterSpacing: 1.8,
                ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.title,
    required this.value,
    this.primary = false,
  });

  final String title;
  final String value;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: primary
                      ? AppColors.primary
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.title,
    required this.value,
    required this.isDark,
  });

  final String title;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryChip extends StatelessWidget {
  const _PrimaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
            ),
      ),
    );
  }
}

class _ScenarioHint extends StatelessWidget {
  const _ScenarioHint({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF09111F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(bool isDark) {
  return BoxDecoration(
    color: isDark ? AppColors.darkCard : Colors.white,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(
      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );
}