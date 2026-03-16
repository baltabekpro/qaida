import 'package:flutter/material.dart';

import '../../app/data/mock_data.dart';
import '../../app/models/place.dart';
import '../../shared/widgets/qaida_bottom_nav.dart';
import '../../shared/widgets/qaida_scaffold.dart';
import '../filter/presentation/filter_flow_screen.dart';
import '../home/presentation/home_screen.dart';
import '../notifications/presentation/notifications_screen.dart';
import '../places/presentation/place_details_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../saved/presentation/saved_screen.dart';
import '../search/presentation/search_screen.dart';

class QaidaShell extends StatefulWidget {
  const QaidaShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<QaidaShell> createState() => _QaidaShellState();
}

class _QaidaShellState extends State<QaidaShell> {
  int _currentIndex = 0;
  final Set<String> _savedIds = {'azure-courtyard', 'luna-terrace'};

  List<Place> get _savedPlaces =>
      MockData.places.where((place) => _savedIds.contains(place.id)).toList();

  void _toggleSaved(String placeId) {
    setState(() {
      if (_savedIds.contains(placeId)) {
        _savedIds.remove(placeId);
      } else {
        _savedIds.add(placeId);
      }
    });
  }

  Future<void> _openPlace(Place place) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaceDetailsScreen(
          place: place,
          saved: _savedIds.contains(place.id),
          onSavedToggle: () {
            _toggleSaved(place.id);
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _openFilters() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const FilterFlowScreen()));
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(items: MockData.notifications),
      ),
    );
  }

  void _openSearchTab() {
    _setCurrentIndex(1);
  }

  void _setCurrentIndex(int value) {
    if (_currentIndex == value) {
      return;
    }

    setState(() => _currentIndex = value);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        savedIds: _savedIds,
        onToggleSaved: _toggleSaved,
        onOpenPlace: _openPlace,
        onOpenFilters: _openFilters,
        onOpenNotifications: _openNotifications,
      ),
      SearchScreen(
        savedIds: _savedIds,
        onToggleSaved: _toggleSaved,
        onOpenPlace: _openPlace,
        onOpenFilters: _openFilters,
      ),
      SavedScreen(
        savedPlaces: _savedPlaces,
        onOpenPlace: _openPlace,
        onToggleSaved: _toggleSaved,
        onOpenSearch: _openSearchTab,
      ),
      ProfileScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return QaidaScaffold(
      extendBody: true,
      bottomNavigation: QaidaBottomNav(
        currentIndex: _currentIndex,
        onTap: _setCurrentIndex,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutQuart,
        switchOutCurve: Curves.easeInQuart,
        transitionBuilder: (child, animation) {
          final scaleAnimation = Tween<double>(
            begin: 0.985,
            end: 1,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: pages[_currentIndex],
        ),
      ),
    );
  }
}
