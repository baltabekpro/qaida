import 'package:flutter/material.dart';

class QaidaNotification {
  const QaidaNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final IconData icon;
  final Color color;
}
