import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/qaida_notification.dart';

abstract final class MockData {
  static const categories = <String>['Еда', 'Кафе', 'Бар', 'Парк', 'Кино'];

  static const places = <Place>[
    Place(
      id: 'azure-courtyard',
      title: 'The Terrace Grill',
      subtitle: 'Современный ресторан с мягким вечерним светом',
      neighborhood: 'Старый город',
      category: 'Еда',
      priceLabel: '₽₽',
      rating: 4.9,
      distanceKm: 1.2,
      latitude: 43.2386,
      longitude: 76.9455,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD-z4U99vwYU3x9I8F3lDC1J8ODp-5CnmVlPNTawOY-TJqlDJC7vFYs-sLUlJBPdVgFvOEgXnskL8oKT49-BZmlpMyBi39nEG8BdrZJnw4ZsO6LVf5npGA-V_30vtwz9nX8e0RcnIupW55gp9YNm0UtJVh-gcWviTCYIOB86wbwkbJDEkVSgAhE02iyoX7nzRQoNgkZptJZmULfHK7RtjaUduNnTuQwqN2chkqOO0uNY6Wqi-cdqA6pr8VNpzn5O-XWiCuR9KKR5w',
      matchScore: 96,
      icon: Icons.menu_book_rounded,
      startColor: Color(0xFFB9D8FF),
      endColor: Color(0xFFEAF4FF),
    ),
    Place(
      id: 'sunline-brunch',
      title: 'Morning Dew Cafe',
      subtitle: 'Уютное кафе для позднего завтрака и разговоров',
      neighborhood: 'Набережная',
      category: 'Кафе',
      priceLabel: '₽',
      rating: 4.7,
      distanceKm: 2.4,
      latitude: 43.2451,
      longitude: 76.9582,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCfH-51EfMW2ob-KoN1Zc4hWQLPIO18jeUipOjalEvncrdnBsdvaLvz_p2RwWe6cmkfPUR2LqnXj7kKQCNUMVCmPE5sX0hIPphMZHux0f2XwNP1l19lm8BgsgomxDMY95T8WSQennokKqCp64zPInDnSrt_cKh4ca5E3akhGfMW5xm_c0JfJ_Lap9Nr_JFhE_z3_VlgM2zgn04e1CLsW67mP63ZEVXo0Kt9aG9k3SlfaodbFIAvXfOPe9HJ8RJS3ABTj2oniY2GmA',
      matchScore: 89,
      icon: Icons.wb_sunny_outlined,
      startColor: Color(0xFFFFE2B9),
      endColor: Color(0xFFFFF3E3),
    ),
    Place(
      id: 'atelier-north',
      title: 'Neon Night Bar',
      subtitle: 'Бар с мягким неоном и спокойной посадкой у окна',
      neighborhood: 'Арт-квартал',
      category: 'Бар',
      priceLabel: '₽₽₽',
      rating: 4.8,
      distanceKm: 3.1,
      latitude: 43.2529,
      longitude: 76.9361,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCM-VSis46GaoNL65kDx8fxNkuKrWqVyVgYqYMnm519BLZmPNpOjoF7wXUCeu-5x_SuOgvhacpnr6VDWsoFhPFC7fH0PogVT9_FzV-IVJVSNZyAQmstwq1iXO2g8y1ksYXhVOxi8Va9HWbYPKdMv_5a9ABkhsbzyfWtfPDrDaDydrzbOSsb2i1m-C3D5S6nYk2GXbmez0K0--Y_nbmAhRGOP9UO6VJ0fhL-JP8cQ27MNpSE8MefXzP-5xP5zcYUURP3U8E691T4Xg',
      matchScore: 84,
      icon: Icons.palette_outlined,
      startColor: Color(0xFFD8E8FF),
      endColor: Color(0xFFF7FAFF),
    ),
    Place(
      id: 'luna-terrace',
      title: 'The Choco',
      subtitle: 'Подходит для спокойного вечера и быстрых встреч',
      neighborhood: 'Центр',
      category: 'Кафе',
      priceLabel: '₽₽₽',
      rating: 4.9,
      distanceKm: 1.8,
      latitude: 43.2418,
      longitude: 76.9513,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCr8raYOcx7X8YoZb3obVLrxEweQc9BgjC4cpCM7jW6T_IJ-QRPYOubCP3VHuHtOlIIeECguyddGSd_Fb-8rWe3sc9FXDoLqO2W9fFozmJ7o4GeZKsSt2_MKr5ny_v2ZkMYOXJKV4QEp_hsf_VFKzyEBZ7k129nvFCZc84XkJAjaSqHuJQKA_p53GjvYIV7BO3GcEuW16AtyN3b6I74Iz1R2S8SUA9nGT-4T6cywTuGTyPa3oamjaVUpkGFWHDl-eidZC07BdHs8Q',
      matchScore: 96,
      icon: Icons.nights_stay_outlined,
      startColor: Color(0xFFCCE0FF),
      endColor: Color(0xFFEAF2FF),
    ),
    Place(
      id: 'mint-garden',
      title: 'Парк Культуры',
      subtitle: 'Прогулки, воздух и длинные маршруты без шума',
      neighborhood: 'Парк линия',
      category: 'Парк',
      priceLabel: '₽₽',
      rating: 4.5,
      distanceKm: 4.0,
      latitude: 43.2282,
      longitude: 76.9093,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCQxDi_3kE9DaWqt70QIbcRfWpRzi8FCRKjousHL0lwdXoYziPIEO762_sD65sfpovXU5pmWpwSm9y4JUjw2JT_dijeVpFfd3lwbKDPN-GPwlXMlKRZxRHJOShwXKAWZ9TJLcV6hT8RIXN_drDgFGKhdQX9YCyC9btfyZc4nZl2nPe-qifxSKQWp7DkNaBVrN3y5Oca4UBvOSX6oFVBAHbXjbLRwp75gDyJ8f-1_mtlvSNBkN2eEIGM0D2tm1Ze6w98s3GiDDVcNQ',
      matchScore: 78,
      icon: Icons.spa_outlined,
      startColor: Color(0xFFD7F0DE),
      endColor: Color(0xFFF0FAF4),
    ),
    Place(
      id: 'frame-house',
      title: 'Silver Screen Hall',
      subtitle: 'Камерный кинозал с поздними сеансами',
      neighborhood: 'Северный рынок',
      category: 'Кино',
      priceLabel: '₽₽',
      rating: 4.8,
      distanceKm: 2.9,
      latitude: 43.2624,
      longitude: 76.9286,
      imageUrl:
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
      matchScore: 81,
      icon: Icons.camera_outlined,
      startColor: Color(0xFFFFDDD4),
      endColor: Color(0xFFFFF1EC),
    ),
  ];

  static const notifications = <QaidaNotification>[
    QaidaNotification(
      id: 'new-match',
      title: 'Новая подборка под ваш вечер',
      body: 'Мы нашли 6 спокойных мест с мягким светом и короткой дорогой.',
      timeLabel: '2 мин назад',
      icon: Icons.auto_awesome_outlined,
      color: Color(0xFFD9EBFF),
    ),
    QaidaNotification(
      id: 'saved-update',
      title: 'В сохранённых появился новый повод зайти',
      body: 'Azure Courtyard добавил вечерний сет и позднее бронирование.',
      timeLabel: '35 мин назад',
      icon: Icons.bookmark_added_outlined,
      color: Color(0xFFE7F4DE),
    ),
    QaidaNotification(
      id: 'collection',
      title: 'Собрали маршрут на выходные',
      body: 'Три места рядом друг с другом уже ждут в персональной коллекции.',
      timeLabel: 'Сегодня',
      icon: Icons.route_outlined,
      color: Color(0xFFFFE9D8),
    ),
    QaidaNotification(
      id: 'quiet-hours',
      title: 'Спокойные часы в Luna Terrace',
      body: 'После 21:00 веранду переведут в тихий режим без яркой музыки.',
      timeLabel: 'Вчера',
      icon: Icons.notifications_active_outlined,
      color: Color(0xFFE8E4FF),
    ),
  ];
}
