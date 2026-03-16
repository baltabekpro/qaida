import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/models/place.dart';
import '../../app/theme/app_colors.dart';

const _mapboxAccessToken = String.fromEnvironment(
  'MAPBOX_ACCESS_TOKEN',
  defaultValue: '',
);
const _lightMapStyle = 'navigation-day-v1';
const _darkMapStyle = 'navigation-night-v1';
const _openStreetMapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

class QaidaMapboxMap extends StatelessWidget {
  const QaidaMapboxMap({
    super.key,
    required this.places,
    required this.focusPlace,
    this.onPlaceTap,
    this.interactive = true,
  });

  final List<Place> places;
  final Place focusPlace;
  final ValueChanged<Place>? onPlaceTap;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final center = LatLng(focusPlace.latitude, focusPlace.longitude);
    final markerPlaces = places.isEmpty ? [focusPlace] : places;
    final hasMapboxToken = _mapboxAccessToken.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13.3,
              interactionOptions: InteractionOptions(
                flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: hasMapboxToken
                    ? 'https://api.mapbox.com/styles/v1/mapbox/${isDark ? _darkMapStyle : _lightMapStyle}/tiles/512/{z}/{x}/{y}@2x?access_token={accessToken}'
                    : _openStreetMapUrl,
                additionalOptions: hasMapboxToken
                    ? const {
                        'accessToken': _mapboxAccessToken,
                      }
                    : const {},
                userAgentPackageName: 'qaida.mobile.app',
                retinaMode: true,
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: center,
                    radius: 52,
                    useRadiusInMeter: true,
                    color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.14),
                    borderColor: AppColors.primary.withValues(alpha: isDark ? 0.32 : 0.24),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: markerPlaces
                    .map(
                      (place) => Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 104,
                        height: 72,
                        child: _QaidaMapMarker(
                          place: place,
                          selected: place.id == focusPlace.id,
                          onTap: onPlaceTap == null ? null : () => onPlaceTap!(place),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: isDark ? 0.16 : 0.06),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
                    ],
                    stops: const [0, 0.18, 0.72, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: _MapChromePill(
              icon: Icons.explore_rounded,
              label: interactive ? 'Живая карта' : 'Локация',
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: _MapChromePill(
              icon: Icons.place_rounded,
              label: '${markerPlaces.length}',
            ),
          ),
        ],
      ),
    );
  }
}

class _QaidaMapMarker extends StatelessWidget {
  const _QaidaMapMarker({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final Place place;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: selected ? 1 : 0.94,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xEE0F172A),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: selected ? 0.22 : 0.18),
                    blurRadius: selected ? 16 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.place_rounded,
                      size: 15,
                      color: selected ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 58),
                    child: Text(
                      place.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: selected ? const Color(0xFF0F172A) : Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -2),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xEE0F172A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapChromePill extends StatelessWidget {
  const _MapChromePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1F0F172A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF0F172A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}