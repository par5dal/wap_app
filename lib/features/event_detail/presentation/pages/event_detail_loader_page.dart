// lib/features/event_detail/presentation/pages/event_detail_loader_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/features/home/domain/usecases/get_event_by_id.dart';
import 'package:wap_app/shared/widgets/glowing_logo.dart';

/// Página intermedia que carga un evento por ID desde la API y luego navega
/// a la ruta [AppRoute.eventDetailDirect] pasando el objeto Event como extra.
///
/// Usar goRouter.go() en lugar de incrustar [EventDetailPage] directamente en
/// build() evita que GoRouter destruya un Navigator anidado al hacer pop.
class EventDetailLoaderPage extends StatefulWidget {
  const EventDetailLoaderPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailLoaderPage> createState() => _EventDetailLoaderPageState();
}

class _EventDetailLoaderPageState extends State<EventDetailLoaderPage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<GetEventByIdUseCase>().call(widget.eventId);
    if (!mounted) return;

    result.fold((failure) => setState(() => _error = failure.message), (event) {
      // Si hay rutas previas en el stack, reemplazamos el loader por el detalle
      // (pushReplacement) para que el botón «atrás» lleve de vuelta a la
      // pantalla anterior (notificaciones, favoritos, listado…) sin pasar por
      // esta pantalla vacía.
      // Si el stack está vacío (cold-start) usamos go para que «atrás» vaya al home.
      // El ID del evento se incluye en el path para que GoRouter pueda reconstruir
      // la ruta correctamente si GoRouterRefreshStream limpia el extra efímero.
      if (context.canPop()) {
        context.pushReplacement('/event-detail/${event.id}', extra: event);
      } else {
        goRouter.go('/event-detail/${event.id}', extra: event);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: GlowingLogo(
          size: 120,
          logoAssetPath: 'assets/images/icon_light.png',
        ),
      ),
    );
  }
}
