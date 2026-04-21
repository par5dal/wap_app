// lib/features/upgrade_to_promoter/presentation/bloc/upgrade_to_promoter_state.dart

part of 'upgrade_to_promoter_bloc.dart';

abstract class UpgradeToPromoterState extends Equatable {
  const UpgradeToPromoterState();
  @override
  List<Object?> get props => [];
}

class UpgradeToPromoterInitial extends UpgradeToPromoterState {
  const UpgradeToPromoterInitial();
}

class UpgradeToPromoterLoading extends UpgradeToPromoterState {
  const UpgradeToPromoterLoading();
}

class UpgradeToPromoterSuccess extends UpgradeToPromoterState {
  const UpgradeToPromoterSuccess();
}

class UpgradeToPromoterFailure extends UpgradeToPromoterState {
  final String message;
  const UpgradeToPromoterFailure(this.message);
  @override
  List<Object?> get props => [message];
}
