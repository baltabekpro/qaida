import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class QaidaScaffold extends StatelessWidget {
  const QaidaScaffold({
    super.key,
    required this.body,
    this.bottomNavigation,
    this.extendBody = false,
  });

  final Widget body;
  final Widget? bottomNavigation;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [AppColors.darkBg, AppColors.darkSurfaceSoft]
              : const [Color(0xFFFFFFFF), Color(0xFFF6FAFF)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isDark)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.85, -0.95),
                    radius: 0.9,
                    colors: [
                      AppColors.primarySoft.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: extendBody,
            body: SafeArea(bottom: false, child: body),
          ),
          if (bottomNavigation case final navigation?)
            Positioned(left: 0, right: 0, bottom: 0, child: navigation),
        ],
      ),
    );
  }
}
