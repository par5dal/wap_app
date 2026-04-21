// lib/features/manage_event/presentation/pages/manage_event_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/manage_event/presentation/bloc/manage_event_bloc.dart';
import 'package:wap_app/features/manage_event/presentation/widgets/wizard_step_details.dart';
import 'package:wap_app/features/manage_event/presentation/widgets/wizard_step_images.dart';
import 'package:wap_app/features/manage_event/presentation/widgets/wizard_step_publish.dart';
import 'package:wap_app/features/manage_event/presentation/widgets/wizard_step_venue.dart';

class ManageEventPage extends StatelessWidget {
  final String? eventId; // null = create mode

  const ManageEventPage({super.key, this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ManageEventBloc>()
            ..add(ManageEventInitialized(editEventId: eventId)),
      child: _ManageEventView(isEditMode: eventId != null),
    );
  }
}

class _ManageEventView extends StatefulWidget {
  final bool isEditMode;
  const _ManageEventView({required this.isEditMode});

  @override
  State<_ManageEventView> createState() => _ManageEventViewState();
}

class _ManageEventViewState extends State<_ManageEventView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepLabels = [
      context.l10n.manageEventStep1,
      context.l10n.manageEventStep2,
      context.l10n.manageEventStep3,
      context.l10n.manageEventStep4,
    ];

    return BlocListener<ManageEventBloc, ManageEventState>(
      listener: (context, state) {
        if (state.status == ManageEventStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditMode
                    ? context.l10n.manageEventUpdateSuccess
                    : context.l10n.manageEventCreateSuccess,
              ),
            ),
          );
          context.go('/promoter-dashboard');
        } else if (state.status == ManageEventStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditMode
                ? context.l10n.manageEventEditTitle
                : context.l10n.manageEventCreateTitle,
          ),
        ),
        body: BlocBuilder<ManageEventBloc, ManageEventState>(
          builder: (context, state) {
            if (state.status == ManageEventStatus.loading ||
                state.status == ManageEventStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Step progress indicator
                _StepIndicator(steps: stepLabels, currentStep: _currentStep),
                // Rejection banner
                if (state.moderationStatus == 'REJECTED')
                  _RejectionBanner(comment: state.moderationComment),
                // Wizard pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      WizardStepDetails(onNext: () => _goToStep(1)),
                      WizardStepVenue(
                        onNext: () => _goToStep(2),
                        onBack: () => _goToStep(0),
                      ),
                      WizardStepImages(
                        onNext: () => _goToStep(3),
                        onBack: () => _goToStep(1),
                      ),
                      WizardStepPublish(onBack: () => _goToStep(2)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RejectionBanner extends StatelessWidget {
  final String? comment;
  const _RejectionBanner({this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightError.withAlpha(20),
            AppColors.lightError.withAlpha(10),
          ],
        ),
        border: Border(left: BorderSide(color: AppColors.lightError, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.lightError.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.gavel_rounded,
                  color: AppColors.lightError,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evento rechazado por el administrador',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.lightError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Revisa el motivo, realiza los cambios necesarios y vuelve a enviar.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.lightError.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Moderation comment block
          if (comment != null && comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightError.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightError.withAlpha(50)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: AppColors.lightError.withAlpha(150),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(200),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const _StepIndicator({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          final isActive = idx == currentStep;
          final isDone = idx < currentStep;

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Left half-line (absent for first step)
                    Expanded(
                      child: idx > 0
                          ? Container(
                              height: 1.5,
                              color: idx <= currentStep
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                            )
                          : const SizedBox(),
                    ),
                    // Circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? theme.colorScheme.primary
                            : isActive
                            ? Colors.transparent
                            : theme.colorScheme.surfaceContainerHighest,
                        border: isActive ? null : null,
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(
                                Icons.check,
                                size: 14,
                                color: theme.colorScheme.onPrimary,
                              )
                            : isActive
                            ? Image.asset(
                                'assets/images/icon_light.png',
                                width: 28,
                                height: 28,
                              )
                            : Text(
                                '${idx + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    // Right half-line (absent for last step)
                    Expanded(
                      child: idx < steps.length - 1
                          ? Container(
                              height: 1.5,
                              color: idx < currentStep
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
