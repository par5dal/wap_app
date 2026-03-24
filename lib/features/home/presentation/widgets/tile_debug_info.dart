import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wap_app/features/home/presentation/providers/event_tile_provider.dart';

/// Widget de debug que muestra métricas del sistema de tiles
/// Solo se muestra en modo debug (kDebugMode)
class TileDebugInfo extends StatefulWidget {
  final EventTileProvider? tileProvider;
  final GoogleMapController? mapController;

  const TileDebugInfo({
    super.key,
    required this.tileProvider,
    this.mapController,
  });

  @override
  State<TileDebugInfo> createState() => _TileDebugInfoState();
}

class _TileDebugInfoState extends State<TileDebugInfo> {
  double? _currentMapZoom;

  @override
  void initState() {
    super.initState();
    _updateMapZoom();
  }

  Future<void> _updateMapZoom() async {
    if (widget.mapController != null) {
      final zoom = await widget.mapController!.getZoomLevel();
      if (mounted) {
        setState(() {
          _currentMapZoom = zoom;
        });
      }
    }
    // Actualizar cada segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _updateMapZoom();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Solo mostrar en modo debug
    if (!kDebugMode || widget.tileProvider == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      bottom: 108,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.black26,
              blurRadius: 4,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: widget.tileProvider!,
          builder: (context, child) {
            final stats = widget.tileProvider!.getCacheStats();
            final textColor = isDark ? Colors.white : Colors.black87;
            final textStyle = TextStyle(color: textColor, fontSize: 13);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🗺️ Map Debug',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                // ZOOM REAL DEL MAPA (Google Maps: 1-20)
                if (_currentMapZoom != null)
                  Text(
                    'Zoom Mapa: ${_currentMapZoom!.toStringAsFixed(1)}',
                    style: textStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                // Zoom del sistema de tiles (6-11)
                Text(
                  'Zoom Tiles: ${stats['current_zoom']}',
                  style: textStyle.copyWith(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Eventos: ${stats['total_events']}', style: textStyle),
                Text(
                  'Tiles: ${stats['loaded_tiles']}/${stats['total_tiles']}',
                  style: textStyle,
                ),
                Text(
                  'Caché: ${_formatPercentage(stats['cache_hit_rate'])}',
                  style: textStyle,
                ),
                // Nota: Markers gestionados por ClusterManager, no por TileProvider
                if (stats['is_loading'] == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cargando...',
                          style: TextStyle(fontSize: 12, color: textColor),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatPercentage(dynamic value) {
    if (value == null) return '0.0%';
    if (value is num) {
      return '${value.toStringAsFixed(1)}%';
    }
    return '0.0%';
  }
}
