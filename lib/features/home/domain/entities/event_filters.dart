// lib/features/home/domain/entities/event_filters.dart

import 'package:equatable/equatable.dart';

class EventFilters extends Equatable {
  final String? search;
  final List<String> categories;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? priceMin;
  final double? priceMax;
  final bool isFree;
  final String? city;

  const EventFilters({
    this.search,
    this.categories = const <String>[],
    this.dateFrom,
    this.dateTo,
    this.priceMin,
    this.priceMax,
    this.isFree = false,
    this.city,
  });

  /// Convierte los filtros a query parameters para la API
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }
    if (categories.isNotEmpty) {
      params['categories'] = categories.join(',');
    }
    if (dateFrom != null) {
      params['dateFrom'] = dateFrom!.toIso8601String();
    }
    if (dateTo != null) {
      params['dateTo'] = dateTo!.toIso8601String();
    }
    if (priceMin != null && priceMin! > 0) {
      params['priceMin'] = priceMin;
    }
    if (isFree) {
      params['priceMax'] = 0;
    } else if (priceMax != null && priceMax! < 1000) {
      params['priceMax'] = priceMax;
    }
    if (city != null && city!.isNotEmpty) {
      params['city'] = city;
    }

    return params;
  }

  /// Crea una copia con algunos valores modificados
  EventFilters copyWith({
    String? search,
    List<String>? categories,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? priceMin,
    double? priceMax,
    bool? isFree,
    String? city,
    bool clearSearch = false,
    bool clearDates = false,
    bool clearPrices = false,
    bool clearCity = false,
  }) {
    return EventFilters(
      search: clearSearch ? null : (search ?? this.search),
      categories: categories ?? this.categories,
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
      priceMin: clearPrices ? null : (priceMin ?? this.priceMin),
      priceMax: clearPrices ? null : (priceMax ?? this.priceMax),
      isFree: isFree ?? this.isFree,
      city: clearCity ? null : (city ?? this.city),
    );
  }

  /// Limpia todos los filtros
  EventFilters clear() {
    return const EventFilters(categories: [], isFree: false);
  }

  /// Verifica si hay alg\u00fan filtro activo
  bool get hasActiveFilters {
    return (search != null && search!.isNotEmpty) ||
        categories.isNotEmpty ||
        dateFrom != null ||
        dateTo != null ||
        (priceMin != null && priceMin! > 0) ||
        priceMax != null ||
        isFree ||
        (city != null && city!.isNotEmpty);
  }

  @override
  List<Object?> get props => [
    search,
    categories,
    dateFrom,
    dateTo,
    priceMin,
    priceMax,
    isFree,
    city,
  ];
}
