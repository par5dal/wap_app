# Implementación de Sistema de Tiles para Mapa en Flutter

## 📑 Tabla de Contenidos

1. [Contexto](#-contexto)
2. [¿Qué es el Sistema de Tiles?](#-qué-es-el-sistema-de-tiles)
3. [Dependencias de Flutter Necesarias](#-dependencias-de-flutter-necesarias)
4. [Matemática de Tiles (Slippy Map Tiles)](#-matemática-de-tiles-slippy-map-tiles)
5. [Endpoint del Backend](#-endpoint-del-backend)
6. [Implementación en Flutter](#-implementación-en-flutter)
7. [Sistema de Clustering Visual de Markers](#-sistema-de-clustering-visual-de-markers)
   - [Algoritmo Grid-Based](#-algoritmo-de-clustering-grid-based)
   - [Sistema Acumulativo de Markers](#-sistema-acumulativo-de-markers-muy-importante)
   - [Diseño de Markers Personalizados](#-diseño-de-markers-personalizados)
   - [Gestión de Clicks en Clusters](#️-gestión-inteligente-de-clicks-en-clusters)
   - [InfoWindow con Navegación](#-infowindow-con-navegación-para-eventos-co-ubicados)
8. [Librería de Clustering Recomendada](#-librería-de-clustering-recomendada-para-flutter)
9. [Integración Completa: Tiles + Clustering](#-integración-completa-tiles--clustering--markers)
10. [Optimizaciones Adicionales](#-optimizaciones-adicionales)
11. [Puntos Críticos de Implementación](#-puntos-críticos-de-implementación)
12. [Métricas de Éxito](#-métricas-de-éxito)
13. [Checklist de Implementación](#-checklist-de-implementación-completa)
14. [Resultado Esperado](#-resultado-esperado)
15. [Arquitectura Final](#-arquitectura-final-del-sistema)
16. [Referencias](#-referencias)

---

## 📋 Contexto
La aplicación web Next.js ya implementa un sistema de tiles optimizado para mostrar eventos en el mapa, similar a como lo hacen Booking o Airbnb. Necesito implementar el mismo sistema en la aplicación Flutter que consume el mismo backend NestJS.

## 🎯 ¿Qué es el Sistema de Tiles?

En lugar de solicitar todos los eventos visibles en el viewport cada vez que el usuario mueve el mapa (sistema de clustering antiguo), el sistema de tiles divide el mundo en una cuadrícula de "tiles" o "baldosas" geográficas basadas en el estándar **Slippy Map Tiles** (compatible con OpenStreetMap, Google Maps, Mapbox).

### Ventajas sobre Clustering Tradicional:
- ✅ **Caché eficiente**: Los tiles individuales se cachean (85-95% cache hit rate)
- ✅ **Menos requests**: Solo se cargan tiles nuevos, no todo el viewport
- ✅ **Fluidez**: Los markers no "parpadean" al mover el mapa
- ✅ **Menos datos**: ~90% menos transferencia de datos
- ✅ **Experiencia fluida**: Como Booking/Airbnb

### Flujo del Usuario:
```
Usuario mueve mapa →
Se calculan tiles visibles (z/x/y) →
Se cargan solo tiles no cacheados →
Markers permanecen estables →
UX fluida y rápida
```

---

## 📦 Dependencias de Flutter Necesarias

Antes de comenzar la implementación, asegúrate de tener estas dependencias en tu `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP Client
  dio: ^5.4.0

  # State Management
  provider: ^6.1.1  # o riverpod, bloc, etc. según tu arquitectura

  # Google Maps
  google_maps_flutter: ^2.5.0

  # Clustering
  google_maps_cluster_manager: ^3.0.0

  # SVG Support (para iconos de categorías)
  flutter_svg: ^2.0.9

  # Utilidades
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### Configuración de Google Maps

#### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="TU_GOOGLE_MAPS_API_KEY"/>
  </application>
</manifest>
```

#### iOS (`ios/Runner/AppDelegate.swift`):
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 🧮 Matemática de Tiles (Slippy Map Tiles)

### Sistema de Coordenadas
Los tiles usan un sistema de coordenadas `z/x/y`:
- **z**: Nivel de zoom (6-16 recomendado para eventos)
- **x**: Coordenada X del tile (columna)
- **y**: Coordenada Y del tile (fila)

### Fórmulas Necesarias

#### 1. Convertir Lat/Lng a Coordenadas de Tile
```dart
class TileCoords {
  final int z; // Zoom level
  final int x; // X coordinate
  final int y; // Y coordinate

  TileCoords({required this.z, required this.x, required this.y});

  String get key => '$z/$x/$y';
}

TileCoords latLngToTile(double lat, double lng, int zoom) {
  final n = pow(2, zoom);

  final x = ((lng + 180) / 360 * n).floor();

  final latRad = lat * pi / 180;
  final y = ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * n).floor();

  return TileCoords(z: zoom, x: x, y: y);
}
```

#### 2. Convertir Tile a Bounding Box
```dart
class TileBounds {
  final double north;
  final double south;
  final double east;
  final double west;

  TileBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });
}

TileBounds tileToBounds(int z, int x, int y) {
  final n = pow(2, z);

  final west = (x / n) * 360 - 180;
  final east = ((x + 1) / n) * 360 - 180;

  final north = _tile2lat(y, z);
  final south = _tile2lat(y + 1, z);

  return TileBounds(north: north, south: south, east: east, west: west);
}

double _tile2lat(int y, int z) {
  final n = pow(2, z);
  final latRad = atan(sinh(pi * (1 - (2 * y) / n)));
  return latRad * 180 / pi;
}
```

#### 3. Calcular Tiles del Viewport
```dart
List<TileCoords> getTilesForViewport({
  required double swLat,
  required double swLng,
  required double neLat,
  required double neLng,
  required int zoom,
}) {
  // Tiles de las esquinas
  final sw = latLngToTile(swLat, swLng, zoom);
  final ne = latLngToTile(neLat, neLng, zoom);

  final tiles = <TileCoords>[];

  // Generar todos los tiles en el rectángulo
  for (int x = sw.x; x <= ne.x; x++) {
    for (int y = ne.y; y <= sw.y; y++) {
      tiles.add(TileCoords(z: zoom, x: x, y: y));
    }
  }

  return tiles;
}
```

#### 4. Calcular Tiles con Buffer (Opcional)
```dart
/// Calcula tiles expandiendo el viewport con un buffer
/// MAX_TILES = 50 para evitar cargas excesivas
List<TileCoords> getTilesForViewportWithBuffer({
  required double swLat,
  required double swLng,
  required double neLat,
  required double neLng,
  required int zoom,
  int bufferSize = 0, // tiles extra alrededor
}) {
  const int MAX_TILES = 50;
  const int MIN_ZOOM = 6;

  int currentZoom = max(MIN_ZOOM, min(12, zoom));

  List<TileCoords> tiles = [];

  // Calcular iterativamente el zoom correcto
  do {
    final sw = latLngToTile(swLat, swLng, currentZoom);
    final ne = latLngToTile(neLat, neLng, currentZoom);

    // Expandir con buffer
    final minX = max(0, sw.x - bufferSize);
    final maxX = min(pow(2, currentZoom) - 1, ne.x + bufferSize);
    final minY = max(0, ne.y - bufferSize);
    final maxY = min(pow(2, currentZoom) - 1, sw.y + bufferSize);

    final tilesX = maxX - minX + 1;
    final tilesY = maxY - minY + 1;
    final totalTiles = tilesX * tilesY;

    if (totalTiles > MAX_TILES && currentZoom > MIN_ZOOM) {
      currentZoom--;
    } else {
      // Generar tiles
      tiles.clear();
      for (int x = minX; x <= maxX; x++) {
        for (int y = minY; y <= maxY; y++) {
          tiles.add(TileCoords(z: currentZoom, x: x, y: y));
        }
      }
      break;
    }
  } while (currentZoom >= MIN_ZOOM);

  return tiles;
}
```

#### 5. Calcular Zoom Óptimo
```dart
/// Determina el zoom óptimo según la distancia visible
/// MUY CONSERVADOR para evitar cargar demasiados tiles
int getOptimalZoom(double latitudeDelta) {
  if (latitudeDelta > 50) return 6;   // Continente/multi-país
  if (latitudeDelta > 25) return 7;   // País muy grande
  if (latitudeDelta > 12) return 8;   // País/región grande
  if (latitudeDelta > 6) return 9;    // Región
  if (latitudeDelta > 3) return 10;   // Ciudad grande
  if (latitudeDelta > 1.5) return 10; // Ciudad
  if (latitudeDelta > 0.7) return 11; // Distrito
  return 11; // Máximo zoom 11 para limitar tiles
}
```

---

## 🔌 Endpoint del Backend

### URL Base
```
GET /events/tiles/:z/:x/:y
```

### Ejemplo
```
GET https://api.whataplan.net/events/tiles/12/2048/1536
```

### Query Parameters (Opcionales - Filtros)
```
?search=concierto
&categories=1,5,8
&dateFrom=2026-02-15T00:00:00Z
&dateTo=2026-03-15T00:00:00Z
&priceMin=0
&priceMax=50
```

### Headers
```
Accept-Language: es
x-lang: es
```

### Respuesta del Backend
```json
{
  "tile": {
    "z": 12,
    "x": 2048,
    "y": 1536
  },
  "bounds": {
    "north": 40.5,
    "south": 40.4,
    "east": -3.6,
    "west": -3.7
  },
  "metadata": {
    "event_count": 23,
    "cached": true,
    "generated_at": "2026-02-08T12:00:00Z"
  },
  "events": [
    {
      "id": 123,
      "event_id": 123,
      "title": "Concierto de Rock",
      "slug": "concierto-rock-madrid",
      "latitude": 40.416775,
      "longitude": -3.703790,
      "start_datetime": "2026-03-01T20:00:00Z",
      "price": 25.50,
      "min_price": 25.50,
      "venue_name": "Sala Riviera",
      "google_place_id": "ChIJ...",
      "primary_image_url": "https://...",
      "primary_category_id": 5,
      "primary_category_name": "Música",
      "primary_category_icon": "<svg>...</svg>",
      "category_name": "Música",
      "category_svg": "<svg>...</svg>",
      "secondary_categories": [
        {
          "id": 8,
          "name": "Rock"
        }
      ]
    }
  ]
}
```

---

## 📦 Implementación en Flutter

### Estructura Recomendada

```
lib/
├── models/
│   ├── tile_coords.dart
│   ├── tile_response.dart
│   └── map_event.dart
├── services/
│   ├── tile_math_service.dart
│   └── event_tile_service.dart
├── providers/
│   └── event_tile_provider.dart
└── widgets/
    └── event_map_widget.dart
```

### 1. Modelo de Datos (tile_response.dart)
```dart
class TileResponse {
  final TileInfo tile;
  final TileBounds bounds;
  final TileMetadata metadata;
  final List<MapEvent> events;

  TileResponse({
    required this.tile,
    required this.bounds,
    required this.metadata,
    required this.events,
  });

  factory TileResponse.fromJson(Map<String, dynamic> json) {
    return TileResponse(
      tile: TileInfo.fromJson(json['tile']),
      bounds: TileBounds.fromJson(json['bounds']),
      metadata: TileMetadata.fromJson(json['metadata']),
      events: (json['events'] as List)
          .map((e) => MapEvent.fromJson(e))
          .toList(),
    );
  }
}

class TileInfo {
  final int z;
  final int x;
  final int y;

  TileInfo({required this.z, required this.x, required this.y});

  String get key => '$z/$x/$y';

  factory TileInfo.fromJson(Map<String, dynamic> json) {
    return TileInfo(
      z: json['z'],
      x: json['x'],
      y: json['y'],
    );
  }
}

class TileMetadata {
  final int eventCount;
  final bool cached;
  final String generatedAt;

  TileMetadata({
    required this.eventCount,
    required this.cached,
    required this.generatedAt,
  });

  factory TileMetadata.fromJson(Map<String, dynamic> json) {
    return TileMetadata(
      eventCount: json['event_count'],
      cached: json['cached'],
      generatedAt: json['generated_at'],
    );
  }
}
```

### 2. Servicio de Tiles (event_tile_service.dart)
```dart
import 'package:dio/dio.dart';

class EventTileService {
  final Dio _dio;

  EventTileService(this._dio);

  /// Obtiene eventos de un tile específico
  Future<TileResponse> getTile({
    required int z,
    required int x,
    required int y,
    String? search,
    List<int>? categories,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMin,
    double? priceMax,
    String locale = 'es',
  }) async {
    final queryParams = <String, dynamic>{};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categories != null && categories.isNotEmpty) {
      queryParams['categories'] = categories.join(',');
    }
    if (dateFrom != null) {
      queryParams['dateFrom'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      queryParams['dateTo'] = dateTo.toIso8601String();
    }
    if (priceMin != null) {
      queryParams['priceMin'] = priceMin;
    }
    if (priceMax != null) {
      queryParams['priceMax'] = priceMax;
    }

    final response = await _dio.get(
      '/events/tiles/$z/$x/$y',
      queryParameters: queryParams,
      options: Options(
        headers: {
          'Accept-Language': locale,
          'x-lang': locale,
        },
      ),
    );

    return TileResponse.fromJson(response.data);
  }

  /// Obtiene múltiples tiles en paralelo
  Future<List<TileResponse>> getTiles({
    required List<TileCoords> tiles,
    String? search,
    List<int>? categories,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMin,
    double? priceMax,
    String locale = 'es',
  }) async {
    final futures = tiles.map((tile) => getTile(
      z: tile.z,
      x: tile.x,
      y: tile.y,
      search: search,
      categories: categories,
      dateFrom: dateFrom,
      dateTo: dateTo,
      priceMin: priceMin,
      priceMax: priceMax,
      locale: locale,
    ));

    return await Future.wait(futures);
  }
}
```

### 3. Provider con Caché (event_tile_provider.dart)

**IMPORTANTE**: Implementar caché en memoria con las siguientes características:

```dart
import 'package:flutter/foundation.dart';

class EventTileProvider extends ChangeNotifier {
  final EventTileService _service;
  final TileMathService _tileMath;

  // CACHÉ DE TILES (clave: "z/x/y", valor: TileResponse)
  final Map<String, TileResponse> _tileCache = {};

  // CACHÉ DE MARKERS (clave: eventId, valor: Marker)
  // SISTEMA ACUMULATIVO: nunca se eliminan markers
  final Map<int, Marker> _markerCache = {};

  // Configuración de caché
  static const Duration _cacheStaleTime = Duration(minutes: 10);
  static const Duration _cacheGcTime = Duration(minutes: 30);

  // Timestamps de tiles para expiración
  final Map<String, DateTime> _tileCacheTimes = {};

  // Metadata
  int _totalTiles = 0;
  int _loadedTiles = 0;
  int _cachedTiles = 0;
  bool _isLoading = false;

  EventTileProvider(this._service, this._tileMath);

  // Getters
  bool get isLoading => _isLoading;
  int get totalTiles => _totalTiles;
  int get loadedTiles => _loadedTiles;
  double get cacheHitRate =>
      _totalTiles > 0 ? (_cachedTiles / _totalTiles) * 100 : 0;

  List<MapEvent> get allEvents {
    // Deduplicar eventos por ID de todos los tiles
    final eventsMap = <int, MapEvent>{};
    for (final tileResponse in _tileCache.values) {
      for (final event in tileResponse.events) {
        if (!eventsMap.containsKey(event.id)) {
          eventsMap[event.id] = event;
        }
      }
    }
    return eventsMap.values.toList();
  }

  /// Obtiene tiles para el viewport actual
  Future<void> loadTilesForViewport({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    required double latitudeDelta,
    String? search,
    List<int>? categories,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMin,
    double? priceMax,
    int bufferSize = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Calcular zoom óptimo
      final zoom = _tileMath.getOptimalZoom(latitudeDelta);

      // 2. Calcular tiles necesarios
      final tiles = _tileMath.getTilesForViewportWithBuffer(
        swLat: swLat,
        swLng: swLng,
        neLat: neLat,
        neLng: neLng,
        zoom: zoom,
        bufferSize: bufferSize,
      );

      _totalTiles = tiles.length;

      // 3. Limpiar caché antiguo (GC)
      _cleanOldCache();

      // 4. Filtrar tiles que NO están en caché o están stale
      final now = DateTime.now();
      final tilesToFetch = tiles.where((tile) {
        final key = tile.key;
        final cached = _tileCache.containsKey(key);

        if (!cached) return true;

        final cacheTime = _tileCacheTimes[key];
        if (cacheTime == null) return true;

        final isStale = now.difference(cacheTime) > _cacheStaleTime;
        return isStale;
      }).toList();

      _cachedTiles = _totalTiles - tilesToFetch.length;
      _loadedTiles = _cachedTiles;

      if (tilesToFetch.isEmpty) {
        // Todos los tiles están en caché
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 5. Cargar tiles nuevos/stale
      final responses = await _service.getTiles(
        tiles: tilesToFetch,
        search: search,
        categories: categories,
        dateFrom: dateFrom,
        dateTo: dateTo,
        priceMin: priceMin,
        priceMax: priceMax,
      );

      // 6. Actualizar caché
      for (final response in responses) {
        final key = response.tile.key;
        _tileCache[key] = response;
        _tileCacheTimes[key] = now;
        _loadedTiles++;
      }

    } catch (e) {
      debugPrint('Error loading tiles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia tiles antiguos (Garbage Collection)
  void _cleanOldCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _tileCacheTimes.forEach((key, cacheTime) {
      if (now.difference(cacheTime) > _cacheGcTime) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _tileCache.remove(key);
      _tileCacheTimes.remove(key);
    }
  }

  /// Sistema acumulativo de markers
  /// Los markers NUNCA se eliminan, solo se agregan nuevos
  void updateMarkers(GoogleMapController mapController) {
    for (final event in allEvents) {
      if (!_markerCache.containsKey(event.id)) {
        // Crear nuevo marker
        final marker = Marker(
          markerId: MarkerId(event.id.toString()),
          position: LatLng(event.latitude, event.longitude),
          // ... configuración del marker
        );

        _markerCache[event.id] = marker;
      }
    }

    // El mapa maneja automáticamente qué markers mostrar
  }

  Set<Marker> get markers => _markerCache.values.toSet();

  /// Limpia toda la caché
  void clearCache() {
    _tileCache.clear();
    _tileCacheTimes.clear();
    _markerCache.clear();
    notifyListeners();
  }
}
```

### 4. Widget del Mapa (event_map_widget.dart)

```dart
class EventMapWidget extends StatefulWidget {
  final MapFilters? filters;

  const EventMapWidget({Key? key, this.filters}) : super(key: key);

  @override
  State<EventMapWidget> createState() => _EventMapWidgetState();
}

class _EventMapWidgetState extends State<EventMapWidget> {
  GoogleMapController? _mapController;
  Timer? _boundsUpdateTimer;

  @override
  void initState() {
    super.initState();
    // Cargar tiles inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTilesForCurrentViewport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventTileProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              markers: provider.markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(40.4168, -3.7038), // Madrid
                zoom: 6,
              ),
            ),

            // Indicador de carga
            if (provider.isLoading)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Cargando tiles ${provider.loadedTiles}/${provider.totalTiles}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Debug info (solo en desarrollo)
            if (kDebugMode)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🗺️ Tiles Debug',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Eventos: ${provider.allEvents.length}'),
                      Text('Tiles: ${provider.loadedTiles}/${provider.totalTiles}'),
                      Text('Caché: ${provider.cacheHitRate.toStringAsFixed(1)}%'),
                      Text('Markers: ${provider.markers.length}'),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    // Cancelar timer anterior
    _boundsUpdateTimer?.cancel();
  }

  void _onCameraIdle() {
    // Debounce: esperar 600ms después de que el usuario deje de mover
    _boundsUpdateTimer?.cancel();
    _boundsUpdateTimer = Timer(Duration(milliseconds: 600), () {
      _loadTilesForCurrentViewport();
    });
  }

  Future<void> _loadTilesForCurrentViewport() async {
    if (_mapController == null) return;

    final bounds = await _mapController!.getVisibleRegion();
    final zoom = await _mapController!.getZoomLevel();

    final swLat = bounds.southwest.latitude;
    final swLng = bounds.southwest.longitude;
    final neLat = bounds.northeast.latitude;
    final neLng = bounds.northeast.longitude;

    final latitudeDelta = neLat - swLat;

    final provider = context.read<EventTileProvider>();

    await provider.loadTilesForViewport(
      swLat: swLat,
      swLng: swLng,
      neLat: neLat,
      neLng: neLng,
      latitudeDelta: latitudeDelta,
      search: widget.filters?.search,
      categories: widget.filters?.categories,
      dateFrom: widget.filters?.dateFrom,
      dateTo: widget.filters?.dateTo,
      priceMin: widget.filters?.priceMin,
      priceMax: widget.filters?.priceMax,
      bufferSize: 0, // Sin buffer inicial
    );
  }

  @override
  void dispose() {
    _boundsUpdateTimer?.cancel();
    super.dispose();
  }
}
```

---

## 🎯 Puntos Críticos de Implementación

### 1. **Caché Acumulativo de Markers**
```dart
// ✅ CORRECTO: Sistema acumulativo
// Los markers se agregan pero NUNCA se eliminan
// El mapa/clusterer maneja automáticamente la visibilidad

final Map<int, Marker> _markerCache = {};

// Solo agregar nuevos
for (final event in newEvents) {
  if (!_markerCache.containsKey(event.id)) {
    _markerCache[event.id] = createMarker(event);
  }
}

// NO eliminar markers viejos
// El mapa gestiona qué mostrar según viewport/zoom
```

### 2. **Debounce de Movimientos del Mapa**
```dart
// Esperar 600ms después de que el usuario deje de mover
Timer? _boundsUpdateTimer;

void _onCameraMove(CameraPosition position) {
  _boundsUpdateTimer?.cancel();
}

void _onCameraIdle() {
  _boundsUpdateTimer?.cancel();
  _boundsUpdateTimer = Timer(Duration(milliseconds: 600), () {
    _loadTilesForCurrentViewport();
  });
}
```

### 3. **Deduplicación de Eventos**
```dart
// Múltiples tiles pueden contener el mismo evento
// Usar Map para deduplicar por ID

final eventsMap = <int, MapEvent>{};
for (final tileResponse in _tileCache.values) {
  for (final event in tileResponse.events) {
    eventsMap[event.id] = event; // Solo guarda una instancia
  }
}
final uniqueEvents = eventsMap.values.toList();
```

### 4. **Gestión del Caché**
```dart
// StaleTime: 10 minutos - tiles son estables
static const Duration _cacheStaleTime = Duration(minutes: 10);

// GcTime: 30 minutos - limpieza de tiles antiguos
static const Duration _cacheGcTime = Duration(minutes: 30);

// Verificar si un tile está stale
final isStale = DateTime.now().difference(cacheTime) > _cacheStaleTime;

// Limpiar tiles más antiguos que GcTime
void _cleanOldCache() {
  final now = DateTime.now();
  _tileCacheTimes.forEach((key, cacheTime) {
    if (now.difference(cacheTime) > _cacheGcTime) {
      _tileCache.remove(key);
      _tileCacheTimes.remove(key);
    }
  });
}
```

### 5. **Límite de Tiles**
```dart
// Máximo 50 tiles para evitar cargas excesivas
const int MAX_TILES = 50;

// Si hay demasiados tiles, reducir zoom automáticamente
if (totalTiles > MAX_TILES && currentZoom > MIN_ZOOM) {
  currentZoom--;
  // Recalcular tiles con zoom menor
}
```

---

## 📊 Métricas de Éxito

### Objetivos de Rendimiento:
- ✅ Cache hit rate: **85-95%**
- ✅ Tiempo de carga inicial: **< 2 segundos**
- ✅ Tiempo al mover mapa: **< 500ms**
- ✅ Reducción de datos: **~90%** vs clustering
- ✅ UX fluida: Sin parpadeos de markers

### Debugging en Desarrollo:
Mostrar en pantalla (solo debug):
```
🗺️ Tiles Debug
Eventos: 42
Tiles: 9/9
Grid: 3×3
Caché: 88.9%
Zoom: 12
LatΔ: 1.23
Markers: 156
```

---

## 🎨 Sistema de Clustering Visual de Markers

### ¿Por qué se necesita clustering visual?

Aunque el sistema de tiles ya optimiza la **carga de datos desde el backend**, cuando hay muchos eventos cercanos en el mapa, los markers se superponen y se vuelve difícil de usar. El **clustering visual** agrupa markers cercanos en el cliente para mejorar la visualización.

### 🔑 Concepto Clave: Tiles ≠ Clustering Visual

- **Tiles** = Sistema de carga de datos (backend → frontend)
- **Clustering Visual** = Agrupación de markers en pantalla (frontend only)

```
Backend (Tiles)          Frontend (Clustering Visual)
     ↓                            ↓
Tiles con eventos  →  Cache  →  Markers individuales  →  Clusterer  →  Pantalla
  (z/x/y)              local     (lat/lng/data)          agrupa cerca    grupos
```

### 📊 Algoritmo de Clustering: Grid-Based

El frontend Next.js usa **@googlemaps/markerclusterer** que implementa un algoritmo **Grid-Based Clustering**:

#### Funcionamiento:
1. **Grid Virtual**: Divide el viewport en una cuadrícula virtual (no relacionada con tiles de datos)
2. **Asignación**: Cada marker se asigna a una celda del grid según su posición
3. **Agrupación**: Si hay múltiples markers en la misma celda, se agrupan en un cluster
4. **Rendering**: Se muestra el cluster con el número de eventos agrupados

#### Características:
- **Zoom-aware**: El tamaño del grid se ajusta con el nivel de zoom
- **Viewport-aware**: Solo agrupa markers visibles
- **Performante**: O(n) - lineal respecto al número de markers
- **No usa distancia euclidiana**: Usa celdas de grid (más rápido)

---

## 🎯 Sistema Acumulativo de Markers (MUY IMPORTANTE)

### Concepto Crítico

El sistema implementa un **caché acumulativo de markers** que es fundamental para la fluidez:

```dart
// ❌ INCORRECTO: Recrear markers cada vez
void updateMarkers(List<Event> newEvents) {
  markers.clear(); // ¡NO HACER ESTO!
  for (event in newEvents) {
    markers.add(createMarker(event));
  }
}

// ✅ CORRECTO: Sistema acumulativo
final Map<int, Marker> _markerCache = {};

void updateMarkers(List<Event> newEvents) {
  // Solo AGREGAR markers nuevos, NUNCA eliminar
  for (event in newEvents) {
    if (!_markerCache.containsKey(event.id)) {
      _markerCache[event.id] = createMarker(event);
    }
  }
  // El clusterer maneja automáticamente cuáles mostrar
}
```

### ¿Por qué es crucial?

1. **Sin parpadeos**: Los markers no desaparecen y reaparecen
2. **Mejor performance**: No recrear objetos innecesariamente
3. **Clustering estable**: El clusterer trabaja con un conjunto estable de markers
4. **UX fluida**: Al mover el mapa, los markers permanecen

### Flujo Completo:

```
Tiles cargados (eventos) →
  ↓
Deduplicar por ID →
  ↓
¿Marker ya existe en caché?
  ├─ SÍ: Actualizar solo si cambió (hover, etc.)
  └─ NO: Crear nuevo marker y agregar a caché
      ↓
Agregar nuevos markers al clusterer →
  ↓
Clusterer decide qué mostrar según viewport/zoom →
  ↓
Render en pantalla
```

---

## 🎨 Diseño de Markers Personalizados

### Markers Individuales: SVG con Icono de Categoría

El frontend Next.js crea markers personalizados con SVG:

```typescript
// Características del marker:
- Círculo con gradiente cyan → pink
- Borde blanco de 2.5-3px
- Sombra con filtro SVG
- Icono de categoría centrado (blanco)
- Tamaño: 48px normal, 56px hover
- zIndex dinámico (hover = 1000)
```

#### Código de referencia (TypeScript → traducir a Flutter):

```typescript
const createMarkerElement = (event: MapEvent, isHovered: boolean) => {
  const scale = isHovered ? 56 : 48;
  const circleRadius = scale / 2 - 2;
  const iconSize = scale * 0.45;
  const categoryIcon = event.primary_category_icon || event.category_svg;

  // SVG con:
  // - linearGradient (cyan → pink)
  // - filter con feGaussianBlur para sombra
  // - circle con fill="url(#gradient)"
  // - g con el SVG del icono de categoría (filtrado a blanco)

  return markerElement;
};
```

### Clusters: Círculo con Contador

```typescript
// Clusters (grupos de markers):
- Círculo de 50px
- Mismo gradiente cyan → pink
- Borde blanco de 3px
- Número de eventos centrado
- Font: Arial, bold, 14px
- zIndex: 1000 + count
```

---

## 🖱️ Gestión Inteligente de Clicks en Clusters

### Problema: Eventos en la Misma Ubicación

Cuando hay múltiples eventos en **exactamente la misma ubicación** (mismo lat/lng), el clustering visual no funciona correctamente porque los markers están superpuestos, no "cercanos".

### Solución Implementada:

El frontend usa un **algoritmo de detección de co-ubicación**:

```typescript
// 1. Detectar si el bounds del cluster es muy pequeño
const latDiff = Math.abs(ne.lat() - sw.lat());
const lngDiff = Math.abs(ne.lng() - sw.lng());

if (latDiff < 0.0001 && lngDiff < 0.0001) {
  // Eventos en la misma ubicación

  if (currentZoom >= 16) {
    // Ya estamos en zoom máximo → mostrar InfoWindow con navegación
    // Extraer todos los eventos del cluster
    const events = cluster.markers.map(m => m.pointData);

    // Mostrar InfoWindow con:
    // - Evento actual (índice 0)
    // - Botones "Anterior" / "Siguiente"
    // - Badge "1 de N"
  } else {
    // Zoom < 16 → hacer zoom hasta 16
    map.setZoom(Math.min(currentZoom + 2, 16));
  }
} else {
  // Eventos dispersos → fitBounds normal con límite zoom 16
  map.fitBounds(cluster.bounds);
}
```

### Flujo de Co-ubicación:

```
Click en cluster →
  ↓
¿Bounds muy pequeño? (< 0.0001°)
  ├─ SÍ: Eventos en misma ubicación
  │     ├─ ¿Zoom >= 16?
  │     │   ├─ SÍ: Mostrar InfoWindow con navegación
  │     │   └─ NO: Hacer zoom +2 (máx 16)
  │     └─
  └─ NO: Eventos dispersos → fitBounds
```

### Implementación en Flutter:

```dart
void onClusterTap(Cluster cluster) {
  final bounds = cluster.bounds;
  final latDiff = (bounds.northeast.latitude - bounds.southwest.latitude).abs();
  final lngDiff = (bounds.northeast.longitude - bounds.southwest.longitude).abs();

  const threshold = 0.0001;
  final areCo located = latDiff < threshold && lngDiff < threshold;

  if (areColocated) {
    // Eventos en misma ubicación
    if (_currentZoom >= 16) {
      // Mostrar InfoWindow con navegación entre eventos
      final events = cluster.markers.map((m) => m.data).toList();
      _showColocatedEventsInfoWindow(events, cluster.position);
    } else {
      // Hacer zoom
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          cluster.position,
          min(_currentZoom + 2, 16),
        ),
      );
    }
  } else {
    // Eventos dispersos: fitBounds con límite zoom 16
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );

    // Limitar zoom después de fitBounds
    Future.delayed(Duration(milliseconds: 500), () async {
      final zoom = await _mapController.getZoomLevel();
      if (zoom > 16) {
        _mapController.animateCamera(CameraUpdate.zoomTo(16));
      }
    });
  }
}
```

---

## 📱 InfoWindow con Navegación para Eventos Co-ubicados

Cuando hay múltiples eventos en la misma ubicación, se muestra un InfoWindow especial:

### Características:

1. **Badge de posición**: "1 de 5" en esquina superior izquierda
2. **Botones de navegación**: "Anterior" y "Siguiente"
3. **Estado de índice**: Mantiene el evento actual seleccionado
4. **Imagen y datos**: Del evento actual

### Estado necesario:

```dart
List<MapEvent> _colocatedEvents = [];
int _currentEventIndex = 0;
MapEvent? _selectedEvent;

void _showColocatedEventsInfoWindow(List<MapEvent> events, LatLng position) {
  setState(() {
    _colocatedEvents = events;
    _currentEventIndex = 0;
    _selectedEvent = events[0];
  });
}

void _nextEvent() {
  setState(() {
    _currentEventIndex = (_currentEventIndex + 1) % _colocatedEvents.length;
    _selectedEvent = _colocatedEvents[_currentEventIndex];
  });
}

void _previousEvent() {
  setState(() {
    _currentEventIndex =
      (_currentEventIndex - 1 + _colocatedEvents.length) % _colocatedEvents.length;
    _selectedEvent = _colocatedEvents[_currentEventIndex];
  });
}
```

---

## 📦 Librería de Clustering Recomendada para Flutter

### Google Maps Cluster Manager

**Package**: `google_maps_cluster_manager`

```yaml
dependencies:
  google_maps_cluster_manager: ^3.0.0
```

### Características:

- ✅ Grid-based clustering (mismo algoritmo)
- ✅ Zoom-aware
- ✅ Personalización de clusters
- ✅ Manejo de clicks
- ✅ Performance optimizado

### Configuración Básica:

```dart
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class EventMapWidget extends StatefulWidget {
  @override
  _EventMapWidgetState createState() => _EventMapWidgetState();
}

class _EventMapWidgetState extends State<EventMapWidget> {
  late ClusterManager _clusterManager;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    _clusterManager = ClusterManager<MapEvent>(
      _markerCache.values.toList(), // Lista de eventos (con LatLng)
      _updateMarkers,
      markerBuilder: _markerBuilder,
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
      extraPercent: 0.2, // 20% extra del viewport para clustering
      stopClusteringZoom: 17.0,
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  Future<Marker> _markerBuilder(Cluster<MapEvent> cluster) {
    if (cluster.isMultiple) {
      // Cluster: múltiples eventos
      return Future.value(
        Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          icon: await _createClusterIcon(cluster.count),
          onTap: () => _onClusterTap(cluster),
        ),
      );
    } else {
      // Marker individual
      final event = cluster.items.first;
      return Future.value(
        Marker(
          markerId: MarkerId(event.id.toString()),
          position: LatLng(event.latitude, event.longitude),
          icon: await _createMarkerIcon(event),
          onTap: () => _onMarkerTap(event),
        ),
      );
    }
  }

  void onCameraMove(CameraPosition position) {
    _clusterManager.onCameraMove(position);
  }

  void onCameraIdle() {
    _clusterManager.updateMap();
  }
}
```

### Crear Iconos Personalizados:

```dart
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<BitmapDescriptor> _createMarkerIcon(MapEvent event) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(48, 48);

  // 1. Dibujar círculo con gradiente
  final gradient = ui.Gradient.linear(
    Offset(0, 0),
    Offset(size.width, size.height),
    [Color(0xFF06B6D4), Color(0xFFEC4899)],
  );

  final paint = Paint()
    ..shader = gradient
    ..style = PaintingStyle.fill;

  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width / 2 - 2,
    paint,
  );

  // 2. Borde blanco
  final borderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width / 2 - 2,
    borderPaint,
  );

  // 3. Icono de categoría (SVG o icono)
  // Usar flutter_svg para renderizar el SVG de categoría

  // 4. Convertir a imagen
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}

Future<BitmapDescriptor> _createClusterIcon(int count) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(50, 50);

  // 1. Círculo con gradiente
  final gradient = ui.Gradient.linear(
    Offset(0, 0),
    Offset(size.width, size.height),
    [Color(0xFF06B6D4), Color(0xFFEC4899)],
  );

  final paint = Paint()
    ..shader = gradient
    ..style = PaintingStyle.fill;

  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width / 2,
    paint,
  );

  // 2. Borde blanco
  final borderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width / 2,
    borderPaint,
  );

  // 3. Texto con el número
  final textPainter = TextPainter(
    text: TextSpan(
      text: count.toString(),
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    ),
  );

  // 4. Convertir a imagen
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}
```

---

## 🔄 Integración Completa: Tiles + Clustering + Markers

### Flujo Completo del Sistema:

```
1. Usuario mueve mapa
   ↓
2. Calcular tiles necesarios (z/x/y)
   ↓
3. Cargar tiles desde backend (o caché)
   ↓
4. Deduplicar eventos por ID
   ↓
5. Sistema acumulativo de markers:
   - Verificar caché de markers
   - Solo crear markers nuevos
   - Actualizar markers existentes si cambió algo (hover)
   ↓
6. ClusterManager procesa markers:
   - Divide viewport en grid
   - Agrupa markers cercanos
   - Calcula clusters
   ↓
7. Render:
   - Markers individuales (con icon personalizado)
   - Clusters (con contador)
   ↓
8. Click en cluster:
   - Si co-ubicados (< 0.0001°) → InfoWindow con navegación
   - Si dispersos → fitBounds
   ↓
9. Click en marker individual → InfoWindow de evento
```

### Código Integrado Completo:

```dart
class EventMapWidget extends StatefulWidget {
  @override
  _EventMapWidgetState createState() => _EventMapWidgetState();
}

class _EventMapWidgetState extends State<EventMapWidget> {
  GoogleMapController? _mapController;
  ClusterManager<MapEvent>? _clusterManager;

  // Sistema acumulativo
  final Map<int, MapEvent> _eventsCache = {};

  // Clustering visual
  Set<Marker> _markers = {};

  // Co-ubicación
  List<MapEvent> _colocatedEvents = [];
  int _currentEventIndex = 0;
  MapEvent? _selectedEvent;

  // Tiles
  late EventTileProvider _tileProvider;

  @override
  void initState() {
    super.initState();
    _tileProvider = context.read<EventTileProvider>();

    // Inicializar cluster manager
    _clusterManager = ClusterManager<MapEvent>(
      [], // Inicialmente vacío
      _updateMarkers,
      markerBuilder: _markerBuilder,
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
      extraPercent: 0.2,
      stopClusteringZoom: 17.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventTileProvider>(
      builder: (context, provider, child) {
        // Actualizar caché acumulativo con nuevos eventos
        _updateEventsCache(provider.allEvents);

        // Actualizar cluster manager con eventos actuales
        _clusterManager?.setItems(_eventsCache.values.toList());

        return GoogleMap(
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          markers: _markers,
          // ... resto de configuración
        );
      },
    );
  }

  void _updateEventsCache(List<MapEvent> newEvents) {
    for (final event in newEvents) {
      // Sistema acumulativo: solo agregar si no existe
      if (!_eventsCache.containsKey(event.id)) {
        _eventsCache[event.id] = event;
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _clusterManager?.setMapId(controller.mapId);
  }

  void _onCameraMove(CameraPosition position) {
    _clusterManager?.onCameraMove(position);
  }

  void _onCameraIdle() async {
    // 1. Actualizar clustering visual
    _clusterManager?.updateMap();

    // 2. Cargar tiles del viewport actual (con debounce en provider)
    final bounds = await _mapController?.getVisibleRegion();
    if (bounds != null) {
      // El provider tiene debounce interno
      _tileProvider.loadTilesForViewport(/* ... */);
    }
  }

  Future<Marker> _markerBuilder(Cluster<MapEvent> cluster) async {
    if (cluster.isMultiple) {
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: await _createClusterIcon(cluster.count),
        onTap: () => _onClusterTap(cluster),
      );
    } else {
      final event = cluster.items.first;
      return Marker(
        markerId: MarkerId(event.id.toString()),
        position: LatLng(event.latitude, event.longitude),
        icon: await _createMarkerIcon(event),
        onTap: () => _onMarkerTap(event),
      );
    }
  }

  void _onClusterTap(Cluster<MapEvent> cluster) async {
    // Algoritmo de co-ubicación (ver sección anterior)
    // ...
  }

  void _onMarkerTap(MapEvent event) {
    // Buscar eventos co-ubicados
    final colocated = _eventsCache.values
        .where((e) =>
          e.latitude == event.latitude &&
          e.longitude == event.longitude
        )
        .toList();

    if (colocated.length > 1) {
      // Múltiples eventos en misma ubicación
      setState(() {
        _colocatedEvents = colocated;
        _currentEventIndex = colocated.indexOf(event);
        _selectedEvent = event;
      });
    } else {
      // Evento único
      setState(() {
        _colocatedEvents = [];
        _currentEventIndex = 0;
        _selectedEvent = event;
      });
    }
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }
}
```

---

## 🚀 Optimizaciones Adicionales

### 1. **Clustering Client-Side** (Opcional)
Si hay muchos eventos en un solo tile (>100), implementar clustering visual con Supercluster:
```dart
// Usar google_maps_cluster_manager package
ClusterManager(
  markers: _markerCache.values.toSet(),
  // ...
)
```

### 2. **Prefetch Predictivo** (Opcional)
Pre-cargar tiles adyacentes mientras el usuario navega:
```dart
// Buffer de 1 tile
await provider.loadTilesForViewport(
  // ...
  bufferSize: 1, // Cargar tiles alrededor
);
```

### 3. **Persistencia en Disco** (Opcional)
Usar Hive o SharedPreferences para persistir caché entre sesiones:
```dart
// Guardar tiles en disco
await Hive.box('tiles').put(tileKey, tileResponse);

// Cargar desde disco
final cachedTile = Hive.box('tiles').get(tileKey);
```

---

## ✅ Checklist de Implementación Completa

### Sistema de Tiles (Backend → Frontend)
- [ ] Implementar TileMathService con todas las fórmulas
  - [ ] latLngToTile
  - [ ] tileToBounds
  - [ ] getTilesForViewport
  - [ ] getTilesForViewportWithBuffer
  - [ ] getOptimalZoom
- [ ] Crear modelos de datos (TileResponse, MapEvent, TileMetadata, etc.)
- [ ] Implementar EventTileService con Dio
  - [ ] getTile (individual)
  - [ ] getTiles (múltiples en paralelo)
- [ ] Crear EventTileProvider con caché en memoria
  - [ ] Caché de tiles (Map<String, TileResponse>)
  - [ ] StaleTime: 10 minutos
  - [ ] GcTime: 30 minutos
  - [ ] Garbage collection automática
- [ ] Implementar deduplicación de eventos por ID
- [ ] Agregar debounce a movimientos del mapa (600ms)
- [ ] Implementar indicador de carga con progreso
- [ ] Configurar límite de 50 tiles máximo
- [ ] Agregar zoom óptimo automático

### Sistema de Clustering Visual (Frontend only)
- [ ] Instalar google_maps_cluster_manager package
- [ ] Implementar sistema acumulativo de markers
  - [ ] Caché de markers (Map<int, Marker>)
  - [ ] Solo AGREGAR markers nuevos, NUNCA eliminar
- [ ] Configurar ClusterManager
  - [ ] Levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0]
  - [ ] extraPercent: 0.2
  - [ ] stopClusteringZoom: 17.0
- [ ] Crear markers personalizados con gradiente
  - [ ] Círculo 48px (normal) / 56px (hover)
  - [ ] Gradiente cyan → pink
  - [ ] Borde blanco 2.5-3px
  - [ ] Icono de categoría centrado (blanco)
- [ ] Crear clusters personalizados con contador
  - [ ] Círculo 50px
  - [ ] Mismo gradiente
  - [ ] Número centrado en blanco

### Gestión de Clicks y Co-ubicación
- [ ] Implementar algoritmo de detección de co-ubicación
  - [ ] Threshold: 0.0001° (lat/lng)
  - [ ] Zoom máximo para co-ubicación: 16
- [ ] Implementar click en cluster
  - [ ] Co-ubicados + zoom < 16: hacer zoom +2
  - [ ] Co-ubicados + zoom >= 16: mostrar InfoWindow con navegación
  - [ ] Dispersos: fitBounds con límite zoom 16
- [ ] Implementar InfoWindow con navegación
  - [ ] Badge "1 de N"
  - [ ] Botones Anterior/Siguiente
  - [ ] Estado de índice actual
- [ ] Implementar click en marker individual
  - [ ] Detectar eventos co-ubicados
  - [ ] Mostrar navegación si hay múltiples

### Integración y Testing
- [ ] Integrar tiles + clustering + markers
- [ ] Testear cache hit rate de tiles (objetivo: >85%)
- [ ] Testear fluidez del mapa (sin parpadeos)
- [ ] Testear con filtros (search, categories, dates, price)
- [ ] Testear eventos en misma ubicación
- [ ] Testear clusters dispersos y co-ubicados
- [ ] Testear en diferentes niveles de zoom
- [ ] Agregar debug info (solo desarrollo)
  - [ ] Eventos totales
  - [ ] Tiles cargados/totales
  - [ ] Cache hit rate
  - [ ] Markers en caché
  - [ ] Zoom actual
- [ ] Optimizar rendimiento en dispositivos lentos
- [ ] Testear consumo de memoria
- [ ] Asegurar que no haya memory leaks

---

## 🎉 Resultado Esperado

Al finalizar la implementación, la app Flutter debe tener:

### Sistema de Tiles (Carga de Datos)
✅ **Carga optimizada** de eventos por tiles geográficos
✅ **Cache hit rate 85-95%** en navegación del mapa
✅ **Menos consumo de datos** (~90% reducción vs clustering antiguo)
✅ **Debounce de 600ms** en movimientos para evitar cargas excesivas
✅ **Límite de 50 tiles** para proteger performance
✅ **Zoom automático** según viewport (6-16)

### Sistema de Clustering Visual (Agrupación en Pantalla)
✅ **Markers agrupados** cuando están cerca (grid-based clustering)
✅ **Sin parpadeos** gracias al sistema acumulativo de markers
✅ **Markers personalizados** con gradiente cyan → pink e icono de categoría
✅ **Clusters personalizados** con contador de eventos
✅ **Clustering inteligente** que se ajusta al nivel de zoom

### Gestión Avanzada de Eventos
✅ **Detección de co-ubicación** (eventos en misma ubicación)
✅ **InfoWindow con navegación** para eventos co-ubicados
✅ **Click en clusters** con comportamiento inteligente:
  - Co-ubicados: zoom o navegación según nivel
  - Dispersos: fitBounds automático
✅ **Límite de zoom 16** en fitBounds para evitar zoom excesivo

### Experiencia de Usuario
✅ **Mapa fluido** sin parpadeos ni saltos
✅ **Navegación suave** entre eventos en misma ubicación
✅ **UX similar a Booking/Airbnb**
✅ **Performance óptimo** incluso en dispositivos lentos
✅ **Compatibilidad total** con el backend NestJS
✅ **Misma funcionalidad** que la app web Next.js

### Debug Info (Solo Desarrollo)
✅ **Estadísticas en pantalla**:
  - Eventos totales cargados
  - Tiles: cargados/totales
  - Cache hit rate (%)
  - Markers en caché
  - Zoom y LatΔ actuales

---

## 📐 Arquitectura Final del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                         USUARIO MUEVE MAPA                      │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    1. SISTEMA DE TILES                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Calcular bounds del viewport                          │   │
│  │ • Calcular zoom óptimo (latitudeDelta)                  │   │
│  │ • Generar coordenadas z/x/y de tiles necesarios         │   │
│  │ • Limitar a máximo 50 tiles                             │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    2. CARGA DE TILES                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Verificar caché (StaleTime: 10min)                    │   │
│  │ • Cargar tiles faltantes desde backend (paralelo)       │   │
│  │ • Actualizar caché con nuevos tiles                     │   │
│  │ • Garbage collection (GcTime: 30min)                    │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                 3. DEDUPLICACIÓN DE EVENTOS                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Unir eventos de todos los tiles                       │   │
│  │ • Deduplicar por ID (Map<int, Event>)                   │   │
│  │ • Obtener lista única de eventos                        │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│              4. SISTEMA ACUMULATIVO DE MARKERS                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Verificar caché de markers (Map<int, Marker>)         │   │
│  │ • Solo CREAR markers nuevos (NUNCA eliminar)            │   │
│  │ • Actualizar markers si cambió estado (hover, etc)      │   │
│  │ • Mantener caché persistente de markers                 │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│               5. CLUSTERING VISUAL (ClusterManager)             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Dividir viewport en grid virtual                      │   │
│  │ • Asignar markers a celdas del grid                     │   │
│  │ • Agrupar markers en misma celda → cluster              │   │
│  │ • Ajustar tamaño de grid según zoom                     │   │
│  │ • Stop clustering en zoom >= 17                         │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                      6. RENDERING                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ MARKERS INDIVIDUALES:                                   │   │
│  │ • Círculo 48px con gradiente cyan → pink                │   │
│  │ • Borde blanco 2.5px                                    │   │
│  │ • Icono de categoría centrado (blanco)                  │   │
│  │                                                         │   │
│  │ CLUSTERS:                                               │   │
│  │ • Círculo 50px con mismo gradiente                      │   │
│  │ • Borde blanco 3px                                      │   │
│  │ • Número de eventos centrado                            │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                   7. INTERACCIÓN USUARIO                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ CLICK EN MARKER INDIVIDUAL:                             │   │
│  │ • Buscar eventos co-ubicados (mismo lat/lng)            │   │
│  │ • Si hay múltiples → InfoWindow con navegación          │   │
│  │ • Si es único → InfoWindow normal                       │   │
│  │                                                         │   │
│  │ CLICK EN CLUSTER:                                       │   │
│  │ • Calcular si co-ubicados (bounds < 0.0001°)            │   │
│  │ • Co-ubicados + zoom < 16 → Hacer zoom +2               │   │
│  │ • Co-ubicados + zoom >= 16 → InfoWindow navegación      │   │
│  │ • Dispersos → fitBounds (límite zoom 16)                │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

                          ↓ RESULTADO ↓

┌─────────────────────────────────────────────────────────────────┐
│            ✨ MAPA FLUIDO, RÁPIDO Y SIN PARPADEOS ✨            │
│                                                                 │
│  • Cache hit rate: 85-95%                                       │
│  • Markers estables (no recreación constante)                  │
│  • Clustering inteligente                                      │
│  • Gestión perfecta de eventos co-ubicados                     │
│  • UX profesional estilo Booking/Airbnb                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 Referencias

- **Slippy Map Tiles**: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
- **Google Maps Flutter**: https://pub.dev/packages/google_maps_flutter
- **Provider Pattern**: https://pub.dev/packages/provider
- **Dio HTTP Client**: https://pub.dev/packages/dio

---

**¡Éxito con la implementación! 🚀**
