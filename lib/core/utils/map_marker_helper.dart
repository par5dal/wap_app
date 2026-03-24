// lib/core/utils/map_marker_helper.dart

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wap_app/core/utils/app_logger.dart';

class MapMarkerHelper {
  // Cache para los marcadores SVG
  // IMPORTANTE: Limpiado al iniciar para forzar regeneración con nuevo tamaño
  static final Map<String, BitmapDescriptor> _markerCache = {};

  /// Limpia la caché de markers (útil cuando cambias tamaños)
  static void clearCache() {
    _markerCache.clear();
    AppLogger.info('MapMarkerHelper: Caché de markers limpiada');
  }

  /// Crea un marcador de cluster con el número de eventos agrupados
  /// Estilo igual a los marcadores individuales (gradiente azul-morado)
  static Future<BitmapDescriptor> createClusterMarker({
    required int count,
    double size = 50,
    double pixelRatio = 1.0,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Mismo tamaño que los marcadores individuales
      final double padding = 3;
      final double circleSize = size;
      final double radius = circleSize / 2;
      final double canvasWidth = circleSize + (padding * 2);
      final double canvasHeight = circleSize + (padding * 2);
      final center = Offset(canvasWidth / 2, canvasHeight / 2);

      // 1. Dibujar sombra
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..isAntiAlias = true;

      canvas.drawCircle(
        Offset(center.dx + 0.5, center.dy + 1),
        radius,
        shadowPaint,
      );

      // 2. Dibujar círculo con gradiente azul-morado (igual que marcadores individuales)
      final Rect gradientRect = Rect.fromCircle(center: center, radius: radius);
      final Paint gradientPaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF00E5FF), // Cyan
            Color(0xFFF02193), // Rosa/Morado
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(gradientRect)
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius, gradientPaint);

      // 3. Dibujar borde blanco
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius, borderPaint);

      // 4. Dibujar el número en blanco en el centro
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: count.toString(),
        style: TextStyle(
          fontSize: circleSize * 0.5, // Tamaño proporcional
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            // Sombra para mejor legibilidad
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (canvasWidth - textPainter.width) / 2,
          (canvasHeight - textPainter.height) / 2,
        ),
      );

      // 5. Convertir a imagen
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        canvasWidth.toInt(),
        canvasHeight.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Cleanup
      picture.dispose();

      return BitmapDescriptor.bytes(buffer, imagePixelRatio: pixelRatio);
    } catch (e) {
      AppLogger.error(
        'Error creando marcador de cluster',
        e,
        StackTrace.current,
      );
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  /// Crea un marcador para eventos colocalizados (en las mismas coordenadas)
  /// Similar al cluster pero con estilo más sobrio para distinguirlo
  static Future<BitmapDescriptor> createColocatedMarker({
    required int count,
    double size = 50,
    double pixelRatio = 1.0,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final double padding = 3;
      final double circleSize = size;
      final double radius = circleSize / 2;
      final double canvasWidth = circleSize + (padding * 2);
      final double canvasHeight = circleSize + (padding * 2);
      final center = Offset(canvasWidth / 2, canvasHeight / 2);

      // 1. Dibujar sombra
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..isAntiAlias = true;

      canvas.drawCircle(
        Offset(center.dx + 0.5, center.dy + 1),
        radius,
        shadowPaint,
      );

      // 2. Dibujar círculo con gradiente naranja-morado (para distinguir de clusters)
      final Rect gradientRect = Rect.fromCircle(center: center, radius: radius);
      final Paint gradientPaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF6B35), // Naranja
            Color(0xFFF02193), // Rosa/Morado
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(gradientRect)
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius, gradientPaint);

      // 3. Dibujar borde blanco
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius, borderPaint);

      // 4. Dibujar el número en blanco en el centro
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: count.toString(),
        style: TextStyle(
          fontSize: circleSize * 0.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (canvasWidth - textPainter.width) / 2,
          (canvasHeight - textPainter.height) / 2,
        ),
      );

      // 5. Convertir a imagen
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        canvasWidth.toInt(),
        canvasHeight.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Cleanup
      picture.dispose();

      return BitmapDescriptor.bytes(buffer, imagePixelRatio: pixelRatio);
    } catch (e) {
      AppLogger.error(
        'Error creando marcador de eventos colocalizados',
        e,
        StackTrace.current,
      );
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  /// Convierte un icono de Material a BitmapDescriptor para usar como marcador
  /// Ahora usa el mismo diseño que los marcadores SVG (círculo con gradiente)
  static Future<BitmapDescriptor> createMarkerFromIcon({
    required IconData icon,
    required Color color,
    double size = 50,
    double pixelRatio = 1.0,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Mismo diseño que los marcadores individuales
      final double padding = 3;
      final double circleSize = size;
      final double radius = circleSize / 2;
      final double canvasWidth = circleSize + (padding * 2);
      final double canvasHeight = circleSize + (padding * 2);
      final center = Offset(canvasWidth / 2, canvasHeight / 2);

      // 1. Dibujar sombra
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..isAntiAlias = true;

      canvas.drawCircle(
        Offset(center.dx + 0.5, center.dy + 1),
        radius,
        shadowPaint,
      );

      // 2. Dibujar círculo con gradiente azul-morado
      final Rect gradientRect = Rect.fromCircle(center: center, radius: radius);
      final Paint gradientPaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF00E5FF), // Cyan
            Color(0xFFF02193), // Rosa/Morado
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(gradientRect)
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius, gradientPaint);

      // 3. Dibujar borde blanco
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius, borderPaint);

      // 4. Dibujar el icono en blanco en el centro
      final iconSize = circleSize * 0.5;
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (canvasWidth - textPainter.width) / 2,
          (canvasHeight - textPainter.height) / 2,
        ),
      );

      // 5. Convertir a imagen
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        canvasWidth.toInt(),
        canvasHeight.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Cleanup
      picture.dispose();

      return BitmapDescriptor.bytes(buffer, imagePixelRatio: pixelRatio);
    } catch (e) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  /// Crea un marcador desde un SVG string (círculo como en la web)
  static Future<BitmapDescriptor> createMarkerFromSvg({
    required String svgString,
    required Color color,
    double size = 50,
    double pixelRatio = 1.0,
  }) async {
    // Generar clave de caché basada en el SVG y el tamaño
    final cacheKey = '${svgString.hashCode}_$size';

    // Verificar si ya está en caché
    if (_markerCache.containsKey(cacheKey)) {
      AppLogger.info('Usando marcador SVG desde caché');
      return _markerCache[cacheKey]!;
    }

    try {
      AppLogger.info('Creando marcador desde SVG, tamaño: $size');

      // 1. Cargar el SVG usando la API de flutter_svg 2.x
      final pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
        null,
      );

      // 2. Crear un PictureRecorder para dibujar con mayor resolución
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      // Mismo tamaño que los otros marcadores (sin escalado extra)
      final double padding = 3; // Padding reducido para sombra y borde
      final double circleSize = size;
      final double radius = circleSize / 2;
      final double canvasWidth = circleSize + (padding * 2);
      final double canvasHeight = circleSize + (padding * 2);
      final center = Offset(canvasWidth / 2, canvasHeight / 2);

      // 3. Dibujar sombra
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..isAntiAlias = true;

      canvas.drawCircle(
        Offset(center.dx + 0.5, center.dy + 1),
        radius,
        shadowPaint,
      );

      // 4. Dibujar círculo con gradiente azul-morado (como en la app)
      final Rect gradientRect = Rect.fromCircle(center: center, radius: radius);
      final Paint gradientPaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF00E5FF), // Cyan
            Color(0xFFF02193), // Rosa/Morado
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(gradientRect)
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius, gradientPaint);

      // 5. Dibujar borde blanco
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = true;

      canvas.drawCircle(center, radius, borderPaint);

      // 6. Dibujar el SVG en blanco en el centro
      final svgSize = pictureInfo.size;
      final targetSize = circleSize * 0.5; // 50% del tamaño del círculo
      final svgScale = targetSize / svgSize.width.clamp(1, double.infinity);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(svgScale);
      canvas.translate(-svgSize.width / 2, -svgSize.height / 2);

      // Aplicar color blanco al SVG
      final Paint svgPaint = Paint()
        ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcIn)
        ..isAntiAlias = true;
      canvas.saveLayer(null, svgPaint);
      canvas.drawPicture(pictureInfo.picture);
      canvas.restore();
      canvas.restore();

      // 7. Convertir a imagen con mayor resolución y luego escalar
      final ui.Picture picture = pictureRecorder.endRecording();
      final ui.Image image = await picture.toImage(
        canvasWidth.toInt(),
        canvasHeight.toInt(),
      );

      // 8. Convertir a bytes PNG
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 9. Crear BitmapDescriptor
      final BitmapDescriptor bitmapDescriptor = BitmapDescriptor.bytes(
        pngBytes,
        imagePixelRatio: pixelRatio,
      );

      // Guardar en caché antes de cleanup
      _markerCache[cacheKey] = bitmapDescriptor;

      // Cleanup
      pictureInfo.picture.dispose();
      picture.dispose();

      AppLogger.info('Marcador SVG creado exitosamente y guardado en caché');
      return bitmapDescriptor;
    } catch (e, stackTrace) {
      AppLogger.error('Error creando marcador desde SVG', e, stackTrace);
      // Si falla, usar el método de icono como fallback
      return createMarkerFromIcon(
        icon: Icons.place,
        color: color,
        size: size,
        pixelRatio: pixelRatio,
      );
    }
  }

  /// Obtener icono para cada categoría
  static IconData getCategoryIcon(String? categorySlug) {
    switch (categorySlug?.toLowerCase()) {
      case 'musica':
      case 'music':
        return Icons.music_note;
      case 'deportes':
      case 'sports':
        return Icons.sports_soccer;
      case 'comida':
      case 'food':
        return Icons.restaurant;
      case 'cultura':
      case 'culture':
        return Icons.museum;
      case 'infantil':
      case 'kids':
        return Icons.child_care;
      case 'nocturna':
      case 'nightlife':
        return Icons.nightlife;
      default:
        return Icons.event;
    }
  }

  /// Obtener color para cada categoría
  static Color getCategoryColor(String? categorySlug) {
    switch (categorySlug?.toLowerCase()) {
      case 'musica':
      case 'music':
        return const Color(0xFF9C27B0); // Púrpura
      case 'deportes':
      case 'sports':
        return const Color(0xFF2196F3); // Azul
      case 'comida':
      case 'food':
        return const Color(0xFFFF9800); // Naranja
      case 'cultura':
      case 'culture':
        return const Color(0xFFE91E63); // Rosa
      case 'infantil':
      case 'kids':
        return const Color(0xFF4CAF50); // Verde
      case 'nocturna':
      case 'nightlife':
        return const Color(0xFF673AB7); // Púrpura oscuro
      default:
        return const Color(0xFF00E5FF); // Cyan (color primario de tu app)
    }
  }
}
