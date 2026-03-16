import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _leftStripController;
  late final AnimationController _rightStripController;

  static const _topRowCards = [
    _OnboardingCardData(
      title: 'Choco Café',
      subtitle: 'Кафе · 4.8 ★',
      icon: Icons.local_cafe_rounded,
      iconColor: Color(0xFF60A5FA),
      iconBackground: Color(0x403882F6),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: _featurePills.map((pill) {
                              return _FeaturePill(
                                label: pill.$1,
                                icon: pill.$2,
                                iconColor: pill.$3,
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: _StartButton(onPressed: widget.onStart),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Text(
                            '50+ мест · Алматы',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 0.2,
                                ),
      endColor: Color(0xFF201010),
    ),
      icon: Icons.park_rounded,
      iconColor: Color(0xFFFBBF24),
      iconBackground: Color(0x2EFBBF24),
      startColor: Color(0xFF2E2A1A),
      endColor: Color(0xFF201C0F),
    ),
  ];

  static const _bottomRowCards = [
    _OnboardingCardData(
      title: 'Jazz Club',
      subtitle: 'Клуб · 4.9 ★',
      icon: Icons.music_note_rounded,
      iconColor: Color(0xFF818CF8),
      iconBackground: Color(0x33818CF8),
      startColor: Color(0xFF1C1C3A),
      endColor: Color(0xFF12122A),
    ),
    _OnboardingCardData(
      title: 'La Piazza',
      subtitle: 'Пицца · 4.7 ★',
      icon: Icons.local_pizza_rounded,
      iconColor: Color(0xFFF472B6),
      iconBackground: Color(0x33F472B6),
      startColor: Color(0xFF2A1C2A),
      endColor: Color(0xFF1A0F1A),
    ),
    _OnboardingCardData(
      title: 'Book Café',
      subtitle: 'Кафе · 4.8 ★',
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFF2DD4BF),
      iconBackground: Color(0x2E2DD4BF),
      startColor: Color(0xFF1A2A2E),
      endColor: Color(0xFF0F1820),
    ),
    _OnboardingCardData(
      title: 'FitZone',
      subtitle: 'Спорт · 4.6 ★',
      icon: Icons.fitness_center_rounded,
      iconColor: Color(0xFFFB923C),
      iconBackground: Color(0x33FB923C),
      startColor: Color(0xFF2E1C1A),
      endColor: Color(0xFF200E0C),
    ),
    _OnboardingCardData(
      title: 'Cinema X',
      subtitle: 'Кино · 4.5 ★',
      icon: Icons.movie_rounded,
      iconColor: Color(0xFF60A5FA),
      iconBackground: Color(0x3360A5FA),
      startColor: Color(0xFF1A1C2E),
      endColor: Color(0xFF0F1020),
    ),
  ];

  static const _featurePills = [
    ('Рестораны', Icons.restaurant_rounded, Color(0xFFF87171)),
    ('Кафе', Icons.local_cafe_rounded, Color(0xFF60A5FA)),
    ('Развлечения', Icons.celebration_rounded, Color(0xFFA78BFA)),
    ('Природа', Icons.park_rounded, Color(0xFF4ADE80)),
  ];

  @override
  void initState() {
    super.initState();
    _leftStripController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
    _rightStripController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _leftStripController.dispose();
    _rightStripController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF08080F),
      body: Stack(
        children: [
          const Positioned(
            top: -60,
            left: -80,
            child: _Orb(width: 320, height: 320, color: Color(0x1F2463EB)),
          ),
          const Positioned(
            top: 40,
            right: -60,
            child: _Orb(width: 260, height: 260, color: Color(0x1A7C3AED)),
          ),
          const Positioned(
            bottom: 120,
            left: -20,
            right: -20,
            child: Center(
              child: _Orb(width: 400, height: 200, color: Color(0x142463EB)),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFF7FBFF)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const _BrandBlock(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.16, 0.84, 1.0],
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AnimatedStrip(
                              controller: _leftStripController,
                              items: _topRowCards,
                              direction: _StripDirection.left,
                            ),
                            const SizedBox(height: 14),
                            _AnimatedStrip(
                              controller: _rightStripController,
                              items: _bottomRowCards,
                              direction: _StripDirection.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 48 + bottomInset),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _featurePills.indexed.map((entry) {
                                final pill = entry.$2;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: entry.$1 == _featurePills.length - 1
                                        ? 0
                                        : 8,
                                  ),
                                  child: _FeaturePill(
                                    label: pill.$1,
                                    icon: pill.$2,
                                    iconColor: pill.$3,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StartButton(onPressed: widget.onStart),
                        const SizedBox(height: 16),
                        Text(
                          '50+ мест · Алматы',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.2,
                              ),
                        ),
                      ],
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

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF7C3AED)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x802463EB),
                blurRadius: 40,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(0.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.5),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), AppColors.primary],
          ).createShader(bounds),
          child: Text(
            'Qaida',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Алматы · Гид по местам',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF64748B),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _AnimatedStrip extends StatelessWidget {
  const _AnimatedStrip({
    required this.controller,
    required this.items,
    required this.direction,
  });

  final AnimationController controller;
  final List<_OnboardingCardData> items;
  final _StripDirection direction;

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 420 ? 144.0 : 160.0;
        final loopWidth = (cardWidth * items.length) + (gap * (items.length - 1));
        final doubled = [...items, ...items];
        final stripWidth = (cardWidth * doubled.length) + (gap * (doubled.length - 1));

        return SizedBox(
          height: 124,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final progress = controller.value;
                final offset = direction == _StripDirection.left
                    ? -loopWidth * progress
                    : -loopWidth + (loopWidth * progress);

                return OverflowBox(
                  maxWidth: stripWidth,
                  minWidth: stripWidth,
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: Offset(offset, 0),
                    child: SizedBox(
                      width: stripWidth,
                      child: Row(
                        children: doubled.indexed.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: entry.$1 == doubled.length - 1 ? 0 : gap,
                            ),
                            child: _MovingPlaceCard(
                              data: entry.$2,
                              width: cardWidth,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              },
            );
          },
        );
      },
    );
  }
}

class _MovingPlaceCard extends StatelessWidget {
  const _MovingPlaceCard({required this.data, required this.width});

  final _OnboardingCardData data;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFF7FBFF)],
        ),
        border: Border.all(color: const Color(0x2E94A3B8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: data.iconBackground,
            ),
            child: Icon(data.icon, color: data.iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x2E94A3B8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF5BA8FF)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x382463EB),
              blurRadius: 30,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x8CFFFFFF)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Начать',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

enum _StripDirection { left, right }

class _OnboardingCardData {
  const _OnboardingCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.startColor,
    required this.endColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color startColor;
  final Color endColor;
}
