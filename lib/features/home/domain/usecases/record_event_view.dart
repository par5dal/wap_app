// lib/features/home/domain/usecases/record_event_view.dart

import 'package:wap_app/features/home/domain/repositories/event_repository.dart';

class RecordEventViewUseCase {
  final EventRepository repository;

  RecordEventViewUseCase(this.repository);

  Future<void> call(String eventId) async {
    await repository.recordView(eventId);
  }
}
