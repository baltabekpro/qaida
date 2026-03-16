import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/root/qaida_shell.dart';
import 'theme/app_theme.dart';

class QaidaApp extends StatefulWidget {
  const QaidaApp({super.key});

  @override
  State<QaidaApp> createState() => _QaidaAppState();
}

class _QaidaAppState extends State<QaidaApp> {
  bool _onboardingCompleted = false;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qaida',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: false,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _onboardingCompleted
          ? QaidaShell(
              themeMode: _themeMode,
              onThemeModeChanged: (value) {
                setState(() {
                  _themeMode = value;
                });
              },
            )
          : OnboardingScreen(
              onStart: () {
                setState(() {
                  _onboardingCompleted = true;
                });
              },
            ),
    );
  }
}
