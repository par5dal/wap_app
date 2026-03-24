// lib/features/home/presentation/pages/events_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/home/presentation/widgets/event_list_card.dart';
import 'package:wap_app/features/home/presentation/widgets/filter_overlay.dart';

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<HomeBloc>().state;
    _searchController.text = state.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<HomeBloc>().add(SearchEvents(query));
  }

  void _showFilterOverlay() {
    final bloc = context.read<HomeBloc>();
    final currentState = bloc.state;

    // Extraer categorías únicas de todos los eventos cargados
    final availableCategories =
        currentState.allEvents
            .where((event) => event.categorySlug != null)
            .map((event) => event.categorySlug!)
            .toSet()
            .toList()
          ..sort();

    // Mapa de SVG por slug de categoría (mismo que usan los markers del mapa)
    final categorySvgMap = <String, String?>{};
    for (final event in currentState.allEvents) {
      if (event.categorySlug != null &&
          !categorySvgMap.containsKey(event.categorySlug)) {
        categorySvgMap[event.categorySlug!] = event.categorySvg;
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withAlpha(51),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 128,
              left: 16,
            ),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                alignment: Alignment.topLeft,
                child: FilterOverlay(
                  selectedStartDate: currentState.filterStartDate,
                  selectedEndDate: currentState.filterEndDate,
                  selectedCategories: currentState.filterCategories,
                  onlyFree: currentState.filterOnlyFree,
                  minPrice: currentState.filterMinPrice,
                  maxPrice: currentState.filterMaxPrice,
                  availableCategories: availableCategories,
                  categorySvgMap: categorySvgMap,
                  onApply: (filters) {
                    bloc.add(
                      FilterEvents(
                        startDate: filters['startDate'],
                        endDate: filters['endDate'],
                        categories: filters['categories'],
                        onlyFree: filters['onlyFree'],
                        minPrice: filters['minPrice'],
                        maxPrice: filters['maxPrice'],
                      ),
                    );
                    Navigator.of(dialogContext).pop(); // Usar dialogContext
                  },
                  onClear: () {
                    bloc.add(const ClearFilters());
                    Navigator.of(dialogContext).pop(); // Usar dialogContext
                  },
                  onClose: () {
                    Navigator.of(dialogContext).pop(); // Usar dialogContext
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botón de volver
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),

                // Campo de búsqueda
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: context.l10n.plansListSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _handleSearch('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: context.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    onChanged: _handleSearch,
                  ),
                ),
                const SizedBox(width: 8),

                // Botón de filtros
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return IconButton(
                      onPressed: _showFilterOverlay,
                      icon: const Icon(Icons.filter_list),
                      style: IconButton.styleFrom(
                        backgroundColor: state.hasActiveFilters
                            ? context.colorScheme.primaryContainer
                            : context.colorScheme.surface,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Lista de eventos
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                // Usar visibleEvents en vez de events para mostrar solo los del viewport
                final eventsToShow = state.visibleEvents;

                if (state.isLoading && eventsToShow.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (eventsToShow.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: context.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.plansListEmpty,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.plansListMoveMap,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: eventsToShow.length,
                    itemBuilder: (context, index) {
                      final event = eventsToShow[index];
                      return EventListCard(
                        event: event,
                        // No pasar onTap para que use el comportamiento por defecto
                        // (ir a EventDetailPage)
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
