// lib/features/home/presentation/widgets/filter_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/l10n/app_localizations.dart';

class FilterOverlay extends StatefulWidget {
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final List<String>?
  selectedCategories; // Cambiado a lista para múltiple selección
  final double? minPrice;
  final double? maxPrice;
  final bool? onlyFree; // Nueva opción para eventos gratuitos
  final List<String> availableCategories;
  final Map<String, String?> categorySvgMap;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onClear;
  final VoidCallback onClose;

  const FilterOverlay({
    super.key,
    this.selectedStartDate,
    this.selectedEndDate,
    this.selectedCategories,
    this.minPrice,
    this.maxPrice,
    this.onlyFree,
    required this.availableCategories,
    this.categorySvgMap = const {},
    required this.onApply,
    required this.onClear,
    required this.onClose,
  });

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late List<String> _selectedCategories; // Cambiado a lista
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late bool _onlyFree; // Nueva opción para gratuitos

  // Filtro de fecha predefinido seleccionado
  String? _selectedDateFilter;

  // Estado de expansión de cada sección
  bool _isDateExpanded = true;
  bool _isCategoryExpanded = false;
  bool _isPriceExpanded = false;

  // ScrollController y GlobalKey para la sección de precio
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _priceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedStartDate;
    _endDate = widget.selectedEndDate;
    _selectedCategories = widget.selectedCategories ?? [];
    _onlyFree = widget.onlyFree ?? false;
    _minPriceController = TextEditingController(
      text: widget.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.maxPrice?.toStringAsFixed(0) ?? '',
    );

    // Detectar qué filtro de fecha predefinido corresponde a las fechas seleccionadas
    _selectedDateFilter = _detectDateFilter(_startDate, _endDate);
  }

  /// Detecta qué filtro de fecha predefinido corresponde a las fechas dadas
  String? _detectDateFilter(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      return 'any';
    }

    if (startDate == null || endDate == null) {
      return 'custom'; // Fecha incompleta = personalizada
    }

    final now = DateTime.now();
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endDay = DateTime(endDate.year, endDate.month, endDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Es "Hoy"?
    if (startDay == today && endDay == today) {
      return 'today';
    }

    // Es "Mañana"?
    if (startDay == tomorrow && endDay == tomorrow) {
      return 'tomorrow';
    }

    // Es "Esta semana"?
    if (startDay == today) {
      final daysUntilSunday = 7 - now.weekday;
      final endOfWeek = today.add(Duration(days: daysUntilSunday));
      if (endDay == endOfWeek) {
        return 'this_week';
      }
    }

    // Es "Este fin de semana"?
    final daysUntilSaturday = 6 - now.weekday;
    final saturday = today.add(Duration(days: daysUntilSaturday));
    final sunday = saturday.add(const Duration(days: 1));
    if (startDay == saturday && endDay == sunday) {
      return 'this_weekend';
    }

    // No coincide con ningún predefinido
    return 'custom';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyDateFilter(String filter) {
    setState(() {
      _selectedDateFilter = filter;
      final now = DateTime.now();

      switch (filter) {
        case 'any':
          _startDate = null;
          _endDate = null;
          break;
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'tomorrow':
          final tomorrow = now.add(const Duration(days: 1));
          _startDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
          _endDate = DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            23,
            59,
            59,
          );
          break;
        case 'this_week':
          _startDate = DateTime(now.year, now.month, now.day);
          // Calcular el domingo de esta semana
          final daysUntilSunday = 7 - now.weekday;
          final endOfWeek = now.add(Duration(days: daysUntilSunday));
          _endDate = DateTime(
            endOfWeek.year,
            endOfWeek.month,
            endOfWeek.day,
            23,
            59,
            59,
          );
          break;
        case 'this_weekend':
          // Sábado y domingo de esta semana
          final daysUntilSaturday = 6 - now.weekday;
          final saturday = now.add(Duration(days: daysUntilSaturday));
          _startDate = DateTime(saturday.year, saturday.month, saturday.day);
          final sunday = saturday.add(const Duration(days: 1));
          _endDate = DateTime(
            sunday.year,
            sunday.month,
            sunday.day,
            23,
            59,
            59,
          );
          break;
        case 'custom':
          // No cambiamos las fechas, permitir selección manual
          break;
      }
    });
  }

  void _handleApply() {
    final filters = {
      'startDate': _startDate,
      'endDate': _endDate,
      'categories': _selectedCategories.isEmpty ? null : _selectedCategories,
      'onlyFree': _onlyFree
          ? true
          : null, // Solo enviar true cuando está activo, null cuando está desactivado
      'minPrice': _onlyFree ? 0.0 : double.tryParse(_minPriceController.text),
      'maxPrice': _onlyFree ? 0.0 : double.tryParse(_maxPriceController.text),
    };
    widget.onApply(filters);
  }

  String _getCategoryDisplayName(String slug) {
    return slug
        .split('-')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  /// Genera una lista de descripciones de los filtros activos
  List<Map<String, dynamic>> _getActiveFilters(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final activeFilters = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // Filtro de fecha - detectar tipo basándose en las fechas actuales
    if (_startDate != null || _endDate != null) {
      String dateLabel = '';

      // Detectar si es un filtro de fecha predefinido
      if (_startDate != null && _endDate != null) {
        final startDay = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        final endDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        // Es "Hoy"?
        if (startDay == today && endDay == today) {
          dateLabel = t.filterDateToday;
        }
        // Es "Mañana"?
        else if (startDay == tomorrow && endDay == tomorrow) {
          dateLabel = t.filterDateTomorrow;
        }
        // Es "Esta semana"?
        else if (startDay == today) {
          final daysUntilSunday = 7 - now.weekday;
          final endOfWeek = DateTime(
            now.year,
            now.month,
            now.day,
          ).add(Duration(days: daysUntilSunday));
          if (endDay == endOfWeek) {
            dateLabel = t.filterDateThisWeek;
          }
        }
        // Es "Este fin de semana"?
        else {
          final daysUntilSaturday = 6 - now.weekday;
          final saturday = DateTime(
            now.year,
            now.month,
            now.day,
          ).add(Duration(days: daysUntilSaturday));
          final sunday = saturday.add(const Duration(days: 1));
          if (startDay == saturday && endDay == sunday) {
            dateLabel = t.filterDateThisWeekend;
          }
        }

        // Si no coincide con ningún predefinido, mostrar rango personalizado
        if (dateLabel.isEmpty) {
          dateLabel =
              '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}';
        }
      } else if (_startDate != null) {
        dateLabel =
            '${t.filterDateFrom} ${_startDate!.day}/${_startDate!.month}';
      } else if (_endDate != null) {
        dateLabel = '${t.filterDateTo} ${_endDate!.day}/${_endDate!.month}';
      }

      if (dateLabel.isNotEmpty) {
        activeFilters.add({
          'type': 'date',
          'label': dateLabel,
          'onRemove': () {
            setState(() {
              _selectedDateFilter = 'any';
              _startDate = null;
              _endDate = null;
            });
          },
        });
      }
    }

    // Filtros de categorías
    for (final category in _selectedCategories) {
      activeFilters.add({
        'type': 'category',
        'label': _getCategoryDisplayName(category),
        'svgString': widget.categorySvgMap[category],
        'onRemove': () {
          setState(() {
            _selectedCategories.remove(category);
          });
        },
      });
    }

    // Filtro de planes gratuitos
    if (_onlyFree) {
      activeFilters.add({
        'type': 'free',
        'label': t.filterOnlyFree,
        'onRemove': () {
          setState(() {
            _onlyFree = false;
          });
        },
      });
    }

    // Filtro de precio mínimo
    if (!_onlyFree &&
        _minPriceController.text.isNotEmpty &&
        double.tryParse(_minPriceController.text) != null) {
      activeFilters.add({
        'type': 'minPrice',
        'label':
            '${AppLocalizations.of(context)!.filterPriceMin}: €${_minPriceController.text}',
        'onRemove': () {
          setState(() {
            _minPriceController.clear();
          });
        },
      });
    }

    // Filtro de precio máximo
    if (!_onlyFree &&
        _maxPriceController.text.isNotEmpty &&
        double.tryParse(_maxPriceController.text) != null) {
      activeFilters.add({
        'type': 'maxPrice',
        'label':
            '${AppLocalizations.of(context)!.filterPriceMax}: €${_maxPriceController.text}',
        'onRemove': () {
          setState(() {
            _maxPriceController.clear();
          });
        },
      });
    }

    return activeFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightPrimary.withAlpha(51),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header fijo con botones
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: context.colorScheme.outline.withAlpha(51),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título y botón cerrar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.filterTitle,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, size: 20),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Botones de acción - más compactos
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _selectedCategories = [];
                              _onlyFree = false;
                              _minPriceController.clear();
                              _maxPriceController.clear();
                              _selectedDateFilter = 'any';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                          child: Text(context.l10n.filterClear),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _handleApply(); // _handleApply llama a onApply que ya hace pop
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                          child: Text(context.l10n.filterApply),
                        ),
                      ),
                    ],
                  ),
                  // Lista de filtros activos (si hay alguno)
                  if (_getActiveFilters(context).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.start, // Alinear a la izquierda
                      children: _getActiveFilters(context).map((filter) {
                        final svgString = filter['svgString'] as String?;
                        return Chip(
                          avatar: (svgString != null && svgString.isNotEmpty)
                              ? SvgPicture.string(
                                  svgString,
                                  width: 14,
                                  height: 14,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.lightPrimary,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : null,
                          label: Text(
                            filter['label'] as String,
                            style: const TextStyle(fontSize: 11),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: filter['onRemove'] as VoidCallback,
                          backgroundColor: AppColors.lightPrimary.withAlpha(26),
                          labelStyle: TextStyle(
                            color: AppColors.lightPrimary,
                            fontSize: 11,
                          ),
                          deleteIconColor: AppColors.lightPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 0,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Contenido scrollable
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de Fecha (expandida por defecto)
                    _buildExpandableSection(
                      title: context.l10n.filterSectionDate,
                      isExpanded: _isDateExpanded,
                      onToggle: () {
                        setState(() => _isDateExpanded = !_isDateExpanded);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Filtros de fecha en dos columnas
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildDateFilterButton(
                                      label: context.l10n.filterDateAny,
                                      value: 'any',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDateFilterButton(
                                      label: context.l10n.filterDateToday,
                                      value: 'today',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDateFilterButton(
                                      label: context.l10n.filterDateTomorrow,
                                      value: 'tomorrow',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildDateFilterButton(
                                      label: context.l10n.filterDateThisWeek,
                                      value: 'this_week',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDateFilterButton(
                                      label: context.l10n.filterDateThisWeekend,
                                      value: 'this_weekend',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDateFilterButton(
                                      label: context.l10n.filterDateChoose,
                                      value: 'custom',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_selectedDateFilter == 'custom') ...[
                            const SizedBox(height: 12),
                            Builder(
                              builder: (builderContext) => Row(
                                children: [
                                  Expanded(
                                    child: _DateButton(
                                      label: context.l10n.filterDateFrom,
                                      date: _startDate,
                                      onTap: () async {
                                        // Usar Navigator.of con rootNavigator para mostrar el picker sobre el overlay
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _startDate ?? DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 365),
                                          ),
                                          useRootNavigator: true,
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _startDate = date;
                                            // Si la fecha "Hasta" es anterior a la nueva fecha "Desde", resetearla
                                            if (_endDate != null &&
                                                _endDate!.isBefore(date)) {
                                              _endDate = null;
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _DateButton(
                                      label: context.l10n.filterDateTo,
                                      date: _endDate,
                                      onTap: () async {
                                        final firstDateForPicker =
                                            _startDate ?? DateTime.now();

                                        // Usar Navigator.of con rootNavigator para mostrar el picker sobre el overlay
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _endDate ?? firstDateForPicker,
                                          firstDate: firstDateForPicker,
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 365),
                                          ),
                                          useRootNavigator: true,
                                        );
                                        if (date != null) {
                                          setState(() => _endDate = date);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Sección de Categorías (colapsada por defecto)
                    _buildExpandableSection(
                      title: context.l10n.filterSectionCategory,
                      isExpanded: _isCategoryExpanded,
                      onToggle: () {
                        setState(() {
                          _isCategoryExpanded = !_isCategoryExpanded;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Botón "Todas" en su propia fila
                          Row(
                            children: [
                              Expanded(
                                child: _buildCategoryButton(
                                  label: context.l10n.filterCategoryAll,
                                  isSelected: _selectedCategories.isEmpty,
                                  svgString: null,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategories.clear();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Categorías en dos columnas
                          ...List.generate(
                            (widget.availableCategories.length / 2).ceil(),
                            (rowIndex) {
                              final leftIndex = rowIndex * 2;
                              final rightIndex = leftIndex + 1;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildCategoryButton(
                                        label: _getCategoryDisplayName(
                                          widget.availableCategories[leftIndex],
                                        ),
                                        isSelected: _selectedCategories.contains(
                                          widget.availableCategories[leftIndex],
                                        ),
                                        svgString:
                                            widget.categorySvgMap[widget
                                                .availableCategories[leftIndex]],
                                        onTap: () {
                                          setState(() {
                                            final category = widget
                                                .availableCategories[leftIndex];
                                            if (_selectedCategories.contains(
                                              category,
                                            )) {
                                              _selectedCategories.remove(
                                                category,
                                              );
                                            } else {
                                              _selectedCategories.add(category);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    if (rightIndex <
                                        widget.availableCategories.length) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildCategoryButton(
                                          label: _getCategoryDisplayName(
                                            widget
                                                .availableCategories[rightIndex],
                                          ),
                                          isSelected: _selectedCategories.contains(
                                            widget
                                                .availableCategories[rightIndex],
                                          ),
                                          svgString:
                                              widget.categorySvgMap[widget
                                                  .availableCategories[rightIndex]],
                                          onTap: () {
                                            setState(() {
                                              final category = widget
                                                  .availableCategories[rightIndex];
                                              if (_selectedCategories.contains(
                                                category,
                                              )) {
                                                _selectedCategories.remove(
                                                  category,
                                                );
                                              } else {
                                                _selectedCategories.add(
                                                  category,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ] else
                                      const Expanded(child: SizedBox()),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Sección de Precio (colapsada por defecto)
                    _buildExpandableSection(
                      key: _priceKey,
                      title: context.l10n.filterSectionPrice,
                      isExpanded: _isPriceExpanded,
                      onToggle: () {
                        setState(() => _isPriceExpanded = !_isPriceExpanded);

                        // Hacer scroll a la sección de precio cuando se expanda
                        if (_isPriceExpanded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final context = _priceKey.currentContext;
                            if (context != null) {
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment:
                                    0.0, // Posición en la parte superior visible
                              );
                            }
                          });
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Opción "Gratuitos"
                          CheckboxListTile(
                            title: Text(context.l10n.filterOnlyFree),
                            value: _onlyFree,
                            onChanged: (value) {
                              setState(() {
                                _onlyFree = value ?? false;
                                // Limpiar campos de precio tanto al activar como al desactivar
                                _minPriceController.clear();
                                _maxPriceController.clear();
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: AppColors.lightPrimary,
                          ),
                          const SizedBox(height: 8),
                          // Campos de precio (deshabilitados si _onlyFree está activo)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minPriceController,
                                  enabled: !_onlyFree,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.filterPriceMin,
                                    prefixText: '€ ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _maxPriceController,
                                  enabled: !_onlyFree,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.filterPriceMax,
                                    prefixText: '€ ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterButton({
    required String label,
    required String value,
  }) {
    final isSelected = _selectedDateFilter == value;
    return InkWell(
      onTap: () {
        if (value == 'custom') {
          setState(() => _selectedDateFilter = 'custom');
        } else {
          _applyDateFilter(value);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightPrimary.withAlpha(51)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.lightPrimary
                : Colors.grey.withAlpha(128),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.lightPrimary : Colors.grey[700],
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 18, color: AppColors.lightPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? svgString,
  }) {
    final labelColor = isSelected ? AppColors.lightPrimary : Colors.grey[700]!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightPrimary.withAlpha(51)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.lightPrimary
                : Colors.grey.withAlpha(128),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (svgString != null && svgString.isNotEmpty) ...[
              SvgPicture.string(
                svgString,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: labelColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 18, color: AppColors.lightPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    Key? key,
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightPrimary,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.lightPrimary,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          child,
          const SizedBox(height: 20),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }
}

class _DateButton extends StatefulWidget {
  final String label;
  final DateTime? date;
  final Future<void> Function() onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  State<_DateButton> createState() => _DateButtonState();
}

class _DateButtonState extends State<_DateButton> {
  bool _isPickerOpen = false;

  Future<void> _handleTap() async {
    if (_isPickerOpen) return; // Evitar múltiples aperturas

    setState(() => _isPickerOpen = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) {
        setState(() => _isPickerOpen = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outline.withAlpha(128)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: context.colorScheme.onSurface.withAlpha(179),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.date != null
                    ? '${widget.date!.day}/${widget.date!.month}/${widget.date!.year}'
                    : widget.label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: widget.date != null
                      ? context.colorScheme.onSurface
                      : context.colorScheme.onSurface.withAlpha(128),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
