// lib/features/upgrade_to_promoter/presentation/bloc/upgrade_to_promoter_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/features/upgrade_to_promoter/domain/usecases/upgrade_to_promoter_usecase.dart';

part 'upgrade_to_promoter_event.dart';
part 'upgrade_to_promoter_state.dart';

class UpgradeToPromoterBloc
    extends Bloc<UpgradeToPromoterEvent, UpgradeToPromoterState> {
  final UpgradeToPromoterUseCase upgradeToPromoter;
  final SharedPreferences prefs;

  UpgradeToPromoterBloc({required this.upgradeToPromoter, required this.prefs})
    : super(const UpgradeToPromoterInitial()) {
    on<UpgradeToPromoterRequested>(_onUpgradeRequested);
  }

  Future<void> _onUpgradeRequested(
    UpgradeToPromoterRequested event,
    Emitter<UpgradeToPromoterState> emit,
  ) async {
    emit(const UpgradeToPromoterLoading());
    final result = await upgradeToPromoter();
    result.fold((failure) => emit(UpgradeToPromoterFailure(failure.message)), (
      _,
    ) {
      prefs.setString('user_role', 'PROMOTER');
      emit(const UpgradeToPromoterSuccess());
    });
  }
}
