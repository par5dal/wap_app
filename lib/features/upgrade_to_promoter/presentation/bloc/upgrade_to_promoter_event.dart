// lib/features/upgrade_to_promoter/presentation/bloc/upgrade_to_promoter_event.dart

part of 'upgrade_to_promoter_bloc.dart';

abstract class UpgradeToPromoterEvent extends Equatable {
  const UpgradeToPromoterEvent();
  @override
  List<Object?> get props => [];
}

class UpgradeToPromoterRequested extends UpgradeToPromoterEvent {
  const UpgradeToPromoterRequested();
}
