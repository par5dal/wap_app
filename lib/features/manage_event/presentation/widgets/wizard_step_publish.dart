// lib/features/manage_event/presentation/widgets/wizard_step_publish.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/manage_event/presentation/bloc/manage_event_bloc.dart';

class WizardStepPublish extends StatefulWidget {
  final VoidCallback onBack;

  const WizardStepPublish({super.key, required this.onBack});

  @override
  State<WizardStepPublish> createState() => _WizardStepPublishState();
}

class _WizardStepPublishState extends State<WizardStepPublish> {
  int _currentImageIndex = 0;

  String _formatEventDateTime(DateTime date) {
    return DateFormat("EEE, dd MMM '\u00b7' HH:mm", 'es').format(date);
  }

  String _formatEventDuration(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    if (endDay != startDay) return _formatEventDateTime(end);
    final duration = end.difference(start);
    if (duration.inMinutes < 60) return '${duration.inMinutes} min';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return minutes == 0 ? '$hours h' : '$hours h $minutes min';
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: context.colorScheme.onPrimary),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label, {
    String? svg,
    bool isPrimary = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isPrimary ? AppColors.primaryGradient : null,
        color: isPrimary ? null : context.colorScheme.surface.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svg != null && svg.isNotEmpty) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.string(
                svg,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageEventBloc, ManageEventState>(
      builder: (context, state) {
        final formData = state.formData;
        final isSubmitting = state.status == ManageEventStatus.submitting;

        final imageWidgets = formData.images
            .map<Widget?>((img) {
              if (img.localFile != null) {
                return Image.file(
                  img.localFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              } else if (img.uploadedUrl != null) {
                return Image.network(
                  img.uploadedUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }
              return null;
            })
            .whereType<Widget>()
            .toList();

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // â”€â”€ Image carousel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    if (imageWidgets.isNotEmpty)
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 300,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: imageWidgets.length > 1,
                              onPageChanged: (index, _) {
                                setState(() => _currentImageIndex = index);
                              },
                            ),
                            items: imageWidgets,
                          ),
                          if (imageWidgets.length > 1)
                            Positioned(
                              bottom: 16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: imageWidgets.asMap().entries.map((
                                  entry,
                                ) {
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == entry.key
                                          ? context.colorScheme.onSurface
                                          : context.colorScheme.onSurface
                                                .withAlpha(97),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                context.l10n.manageEventPreviewBadge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Stack(
                        children: [
                          Container(
                            height: 300,
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.event,
                                size: 80,
                                color: context.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                context.l10n.manageEventPreviewBadge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    // â”€â”€ Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TÃ­tulo
                          Text(
                            formData.title.isNotEmpty ? formData.title : '-',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // UbicaciÃ³n
                          if (formData.venue != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: context.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formData.venue!.name.isNotEmpty
                                        ? '${formData.venue!.name} - ${formData.venue!.address}'
                                        : formData.venue!.address,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: context.colorScheme.onSurface
                                              .withAlpha(179),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Fecha y hora
                          if (formData.startDatetime != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: context.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatEventDateTime(formData.startDatetime!),
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.onSurface
                                        .withAlpha(179),
                                  ),
                                ),
                                if (formData.endDatetime != null) ...[
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.schedule,
                                    size: 20,
                                    color: context.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatEventDuration(
                                      formData.startDatetime!,
                                      formData.endDatetime!,
                                    ),
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: context.colorScheme.onSurface
                                              .withAlpha(179),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Precio
                          Row(
                            children: [
                              Icon(
                                Icons.euro,
                                size: 20,
                                color: context.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formData.price == null || formData.price == 0
                                    ? context.l10n.manageEventFree
                                    : '${formData.price!.toStringAsFixed(2)} €',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withAlpha(179),
                                  fontWeight:
                                      (formData.price == null ||
                                          formData.price == 0)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Categorías (gradient chips con SVG, order preservado)
                          if (formData.categoryIds.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: formData.categoryIds
                                  .map(
                                    (catId) => state.categories.firstWhere(
                                      (c) => c.id == catId,
                                    ),
                                  )
                                  .map(
                                    (c) => _buildCategoryChip(
                                      context,
                                      c.name,
                                      svg: c.svg,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // DescripciÃ³n
                          if (formData.description.isNotEmpty) ...[
                            _buildSection(
                              context,
                              icon: Icons.description,
                              title: context.l10n.eventStatusDescription,
                              child: Text(
                                formData.description,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withAlpha(179),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // â”€â”€ Action buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: context.colorScheme.onSurface.withAlpha(31),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting ? null : widget.onBack,
                            child: Text(context.l10n.back),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => context.read<ManageEventBloc>().add(
                                    const ManageEventSubmitRequested(
                                      publish: false,
                                    ),
                                  ),
                            child: Text(context.l10n.manageEventSaveDraft),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : () => context.read<ManageEventBloc>().add(
                              const ManageEventSubmitRequested(publish: true),
                            ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.l10n.manageEventPublish),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
