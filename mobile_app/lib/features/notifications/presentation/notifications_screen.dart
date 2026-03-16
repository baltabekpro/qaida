import 'package:flutter/material.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/models/qaida_notification.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../../../shared/widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.items});

  final List<QaidaNotification> items;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = switch (_tabIndex) {
      1 => widget.items.take(2).toList(),
      2 => widget.items.skip(2).toList(),
      _ => widget.items,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Уведомления',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 12),
        PillTabs(
          tabs: const ['Все', 'Новые', 'Просмотренные'],
          selectedIndex: _tabIndex,
          onChanged: (value) => setState(() => _tabIndex = value),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                blurRadius: 50,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сегодня',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '3 новых события',
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Подобрали места рядом, сохранили обновления по коллекциям и напоминаниям.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationCard(item: item),
          ),
        ),
      ],
    );
  }
}
