// lib/features/manage_event/presentation/widgets/wizard_step_venue.dart

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/manage_event/domain/entities/event_form_data.dart';
import 'package:wap_app/features/manage_event/domain/entities/saved_venue_entity.dart';
import 'package:wap_app/features/manage_event/presentation/bloc/manage_event_bloc.dart';

class WizardStepVenue extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const WizardStepVenue({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<WizardStepVenue> createState() => _WizardStepVenueState();
}

class _WizardStepVenueState extends State<WizardStepVenue>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  final _dio = Dio();
  final _sessionToken = const Uuid().v4();
  Timer? _debounce;
  List<_MapboxSuggestion> _suggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchCtrl.dispose();
    _dio.close();
    super.dispose();
  }

  void _selectVenue(SelectedVenue venue) {
    context.read<ManageEventBloc>().add(ManageEventVenueSelected(venue));
    widget.onNext();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    if (val.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchMapbox(val.trim());
    });
  }

  Future<void> _searchMapbox(String query) async {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim() ?? '';
    if (token.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/search/searchbox/v1/suggest',
        queryParameters: {
          'q': query,
          'access_token': token,
          'session_token': _sessionToken,
          'limit': 5,
          'language': 'es',
          'country': 'es',
        },
      );

      final suggestions =
          (response.data['suggestions'] as List?)
              ?.map((s) => s as Map<String, dynamic>)
              .toList() ??
          [];

      final results = <_MapboxSuggestion>[];
      for (final s in suggestions) {
        final mapboxId = s['mapbox_id'] as String?;
        if (mapboxId == null || mapboxId.isEmpty) continue;
        final name = (s['name'] as String?) ?? '';
        final placeFormatted = (s['place_formatted'] as String?) ?? '';
        final fullAddress = (s['full_address'] as String?) ?? '';
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
        if (description.isEmpty) continue;
        results.add(
          _MapboxSuggestion(
            mapboxId: mapboxId,
            name: name,
            fullAddress: description,
            lat: 0,
            lng: 0,
          ),
        );
      }

      if (mounted) setState(() => _suggestions = results);
    } catch (e) {
      debugPrint('Mapbox suggest error: $e');
      if (mounted) setState(() => _suggestions = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _retrieveAndSelect(_MapboxSuggestion suggestion) async {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim() ?? '';
    if (token.isEmpty) return;

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/search/searchbox/v1/retrieve/${suggestion.mapboxId}',
        queryParameters: {
          'access_token': token,
          'session_token': _sessionToken,
        },
      );

      final features =
          (response.data['features'] as List?)
              ?.map((f) => f as Map<String, dynamic>)
              .toList() ??
          [];
      if (features.isEmpty) return;

      final feature = features.first;
      final coords = (feature['geometry']?['coordinates'] as List?) ?? [];
      if (coords.length < 2) return;

      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();

      _selectVenue(
        SelectedVenue(
          name: suggestion.name,
          address: suggestion.fullAddress,
          lat: lat,
          lng: lng,
        ),
      );
    } catch (_) {
      // silently fail — user can try again
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedVenues = context.select<ManageEventBloc, List<SavedVenueEntity>>(
      (b) => b.state.savedVenues,
    );
    final selectedVenue = context.select<ManageEventBloc, SelectedVenue?>(
      (b) => b.state.formData.venue,
    );

    return Column(
      children: [
        if (selectedVenue != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedVenue.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedVenue.address,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => context.read<ManageEventBloc>().add(
                    const ManageEventVenueCleared(),
                  ),
                ),
              ],
            ),
          ),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.manageEventMyVenues),
            Tab(text: context.l10n.manageEventSearchVenue),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Saved venues
              savedVenues.isEmpty
                  ? Center(child: Text(context.l10n.manageEventNoSavedVenues))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: savedVenues.length,
                      itemBuilder: (ctx, i) {
                        final v = savedVenues[i];
                        return ListTile(
                          leading: const Icon(Icons.store_outlined),
                          title: Text(v.name),
                          subtitle: Text(v.address),
                          onTap: () => _selectVenue(
                            SelectedVenue(
                              id: v.id,
                              name: v.name,
                              address: v.address,
                              lat: v.lat,
                              lng: v.lng,
                            ),
                          ),
                        );
                      },
                    ),
              // Tab 2: Mapbox search
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: context.l10n.manageEventSearchPlaceholder,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  if (_isSearching)
                    const Center(child: CircularProgressIndicator()),
                  Expanded(
                    child: _suggestions.isEmpty && _searchCtrl.text.isNotEmpty
                        ? Center(child: Text(context.l10n.manageEventNoResults))
                        : ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (ctx, i) {
                              final s = _suggestions[i];
                              return ListTile(
                                leading: const Icon(Icons.place_outlined),
                                title: Text(s.name),
                                subtitle: Text(s.fullAddress),
                                onTap: () => _retrieveAndSelect(s),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: Text(context.l10n.back),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: selectedVenue != null ? widget.onNext : null,
                  child: Text(context.l10n.next),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapboxSuggestion {
  final String mapboxId;
  final String name;
  final String fullAddress;
  final double lat;
  final double lng;

  _MapboxSuggestion({
    required this.mapboxId,
    required this.name,
    required this.fullAddress,
    required this.lat,
    required this.lng,
  });
}
