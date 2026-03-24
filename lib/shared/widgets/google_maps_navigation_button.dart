// lib/shared/widgets/google_maps_navigation_button.dart

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wap_app/shared/widgets/custom_button.dart';

/// Widget que encapsula la lógica de navegación a Google Maps
/// Puede usarse como botón independiente o integrado en otros widgets
class GoogleMapsNavigationButton extends StatelessWidget {
  final String? googlePlaceId;
  final double? latitude;
  final double? longitude;
  final String? venueName;
  final String buttonText;
  final ButtonType buttonType;
  final IconData? icon;

  const GoogleMapsNavigationButton({
    super.key,
    this.googlePlaceId,
    this.latitude,
    this.longitude,
    this.venueName,
    required this.buttonText,
    this.buttonType = ButtonType.outlined,
    this.icon,
  });

  Future<void> _openGoogleMaps(BuildContext context) async {
    // Determinar el destino: prioridad place ID > nombre > coordenadas
    final hasName = venueName != null && venueName!.isNotEmpty;
    final hasCoords = latitude != null && longitude != null;
    final hasPlaceId = googlePlaceId != null && googlePlaceId!.isNotEmpty;

    if (!hasName && !hasCoords) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay información de ubicación disponible'),
          ),
        );
      }
      return;
    }

    final encodedName = hasName ? Uri.encodeComponent(venueName!) : null;

    // URL universal de Google Maps (abre la app si está instalada, si no la web)
    // destination_place_id > nombre > coordenadas — evita mostrar lat,lon como etiqueta
    String mapsUrl =
        'https://www.google.com/maps/dir/?api=1&travelmode=driving';
    if (hasPlaceId) {
      mapsUrl += '&destination_place_id=$googlePlaceId';
      if (encodedName != null) mapsUrl += '&destination=$encodedName';
    } else if (encodedName != null) {
      mapsUrl += '&destination=$encodedName';
    } else {
      mapsUrl += '&destination=${latitude!},${longitude!}';
    }

    if (Platform.isIOS) {
      // Intentar Google Maps nativo (si está instalado)
      final gmapsDest = hasPlaceId
          ? encodedName ?? '${latitude!},${longitude!}'
          : encodedName ?? '${latitude!},${longitude!}';
      final gmapsNative = Uri.parse(
        'comgooglemaps://?directionsmode=driving&daddr=$gmapsDest',
      );
      if (await canLaunchUrl(gmapsNative)) {
        await launchUrl(gmapsNative, mode: LaunchMode.externalApplication);
        return;
      }
      // Fallback: Apple Maps — usar nombre como destino, no coordenadas
      final appleDest = encodedName ?? '${latitude!},${longitude!}';
      final appleUrl = Uri.parse('https://maps.apple.com/?daddr=$appleDest');
      await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // Android: URL universal de Google Maps
    try {
      await launchUrl(Uri.parse(mapsUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir el mapa: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: buttonText,
      type: buttonType,
      icon: icon,
      onPressed: () => _openGoogleMaps(context),
    );
  }
}
