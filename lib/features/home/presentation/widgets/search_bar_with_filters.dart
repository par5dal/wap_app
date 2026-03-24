// lib/features/home/presentation/widgets/search_bar_with_filters.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/l10n/app_localizations.dart';

class PlaceSuggestion {
  final String description;
  final String mapboxId;

  PlaceSuggestion({required this.description, required this.mapboxId});
}

class SearchBarWithFilters extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSearchChanged;
  final Function(LatLng, String)? onLocationSelected;
  final String mapboxAccessToken;
  final bool hasActiveFilters; // Nuevo parámetro

  const SearchBarWithFilters({
    super.key,
    required this.searchController,
    required this.onFilterTap,
    required this.onSearchChanged,
    this.onLocationSelected,
    required this.mapboxAccessToken,
    this.hasActiveFilters = false, // Por defecto false
  });

  @override
  State<SearchBarWithFilters> createState() => _SearchBarWithFiltersState();
}

class _SearchBarWithFiltersState extends State<SearchBarWithFilters> {
  bool _hasText = false;
  final Dio _dio = Dio();
  // session_token agrupa suggest+retrieve en una sola sesión de facturación
  String _sessionToken = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    _hasText = widget.searchController.text.isNotEmpty;
    widget.searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.searchController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    // También filtrar por texto mientras el usuario escribe
    widget.onSearchChanged(widget.searchController.text);
  }

  void _clearSearch() {
    widget.searchController.clear();
    widget.onSearchChanged('');
  }

  Future<List<PlaceSuggestion>> _fetchPlaceSuggestions(String query) async {
    if (query.length < 3 || widget.mapboxAccessToken.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/search/searchbox/v1/suggest',
        queryParameters: {
          'q': query,
          'session_token': _sessionToken,
          'language': 'es',
          'country': 'es',
          // Listar tipos geográficos primero para que ciudades/regiones
          // aparezcan antes que POIs cuando el texto coincide con ambos.
          'types': 'place,region,district,locality,neighborhood,address,poi',
          'access_token': widget.mapboxAccessToken,
        },
      );

      if (response.statusCode == 200) {
        final suggestions = response.data['suggestions'] as List;
        return suggestions
            .map((s) {
              final name = (s['name'] as String?) ?? '';
              final placeFormatted = (s['place_formatted'] as String?) ?? '';
              final fullAddress = (s['full_address'] as String?) ?? '';
              // POI/lugar: "Catedral de León, León, España"
              // Dirección pura: usar full_address
              final String description;
              if (name.isNotEmpty &&
                  placeFormatted.isNotEmpty &&
                  name != placeFormatted) {
                description = '$name, $placeFormatted';
              } else if (name.isNotEmpty) {
                description = fullAddress.isNotEmpty ? fullAddress : name;
              } else {
                description = fullAddress;
              }
              return PlaceSuggestion(
                description: description,
                mapboxId: (s['mapbox_id'] as String?) ?? '',
              );
            })
            .where((s) => s.mapboxId.isNotEmpty && s.description.isNotEmpty)
            .toList();
      } else {
        debugPrint('Mapbox Suggest error: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error fetching Mapbox suggestions: $e');
    }

    return [];
  }

  Future<LatLng?> _getPlaceCoordinates(String mapboxId) async {
    if (mapboxId.isEmpty || widget.mapboxAccessToken.isEmpty) return null;

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/search/searchbox/v1/retrieve/$mapboxId',
        queryParameters: {
          'session_token': _sessionToken,
          'access_token': widget.mapboxAccessToken,
        },
      );

      if (response.statusCode == 200) {
        final features = response.data['features'] as List;
        if (features.isNotEmpty) {
          final coords = features[0]['geometry']['coordinates'] as List;
          // Regenerar token: cada par suggest+retrieve es una sesión de facturación
          _sessionToken = const Uuid().v4();
          return LatLng(
            (coords[1] as num).toDouble(),
            (coords[0] as num).toDouble(),
          );
        }
      } else {
        debugPrint('Mapbox Retrieve error: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error fetching Mapbox coordinates: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        // Botón de filtros (separado)
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              // Estilo activo (con filtros): backgroundColor sólido
              // Estilo inactivo (sin filtros): transparent con borde
              color: widget.hasActiveFilters
                  ? context.colorScheme.primaryContainer
                  : context.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.lightPrimary.withAlpha(51),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: widget.onFilterTap,
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtros',
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: widget.hasActiveFilters
                    ? context.colorScheme.onPrimaryContainer
                    : AppColors.lightPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Campo de búsqueda con autocompletado de Mapbox Searchbox
        Expanded(
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(28),
            child: TypeAheadField<PlaceSuggestion>(
              controller: widget.searchController,
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: t.navBarSearch,
                    filled: true,
                    fillColor: context.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: AppColors.lightPrimary.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: AppColors.lightPrimary.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: AppColors.lightPrimary,
                        width: 1,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: context.colorScheme.error,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: context.colorScheme.error,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    suffixIcon: _hasText
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear, size: 20),
                            tooltip: 'Limpiar búsqueda',
                            style: IconButton.styleFrom(
                              foregroundColor: context.colorScheme.onSurface
                                  .withAlpha(179),
                            ),
                          )
                        : null,
                  ),
                  style: context.textTheme.bodyMedium,
                );
              },
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty || pattern.length < 3) {
                  return [];
                }
                return await _fetchPlaceSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.location_on, size: 20),
                  title: Text(
                    suggestion.description,
                    style: context.textTheme.bodyMedium,
                  ),
                  dense: true,
                );
              },
              onSelected: (suggestion) async {
                // Obtener coordenadas del lugar seleccionado
                final latLng = await _getPlaceCoordinates(suggestion.mapboxId);

                // Limpiar el campo de búsqueda
                widget.searchController.clear();
                widget.onSearchChanged('');

                if (latLng != null && widget.onLocationSelected != null) {
                  widget.onLocationSelected!(latLng, suggestion.description);

                  // Cerrar el teclado después del desplazamiento del mapa
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) {
                      FocusScope.of(context).unfocus();
                    }
                  });
                }
              },
              decorationBuilder: (context, child) {
                return Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: child,
                );
              },
              offset: const Offset(0, 8),
              constraints: const BoxConstraints(maxHeight: 300),
              emptyBuilder: (context) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
