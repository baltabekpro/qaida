import 'package:flutter/material.dart';

class Place {
  const Place({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.neighborhood,
    required this.category,
    required this.priceLabel,
    required this.rating,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.matchScore,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final String neighborhood;
  final String category;
  final String priceLabel;
  final double rating;
  final double distanceKm;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final int matchScore;
  final IconData icon;
  final Color startColor;
  final Color endColor;
}
