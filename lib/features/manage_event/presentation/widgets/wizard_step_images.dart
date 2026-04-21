// lib/features/manage_event/presentation/widgets/wizard_step_images.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/manage_event/domain/entities/event_form_data.dart';
import 'package:wap_app/features/manage_event/presentation/bloc/manage_event_bloc.dart';

class WizardStepImages extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const WizardStepImages({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ManageEventBloc, ManageEventState>(
            builder: (context, state) {
              final images = state.formData.images;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    context.l10n.manageEventImagesTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.manageEventImagesSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (images.isNotEmpty)
                    ...images.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final img = entry.value;
                      return _ImageTile(
                        image: img,
                        index: idx,
                        isPrimary: img.isPrimary,
                        onRemove: () => context.read<ManageEventBloc>().add(
                          ManageEventImageRemoved(img.localId ?? ''),
                        ),
                        onSetPrimary: () => context.read<ManageEventBloc>().add(
                          ManageEventPrimaryImageSet(img.localId ?? ''),
                        ),
                      );
                    }),
                  if (images.length < 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(context.l10n.manageEventAddImage),
                        onPressed: () => _pickImage(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: Text(context.l10n.back),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onNext,
                  child: Text(context.l10n.next),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    // Ask the user to choose between camera and gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(ctx.l10n.manageEventImageSourceCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(ctx.l10n.manageEventImageSourceGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 90);
    if (xFile == null || !context.mounted) return;

    // Crop image
    final cropped = await ImageCropper().cropImage(
      sourcePath: xFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Image', lockAspectRatio: true),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
      ],
    );

    if (cropped == null || !context.mounted) return;

    const uuid = Uuid();
    final imageData = EventImageData(
      localId: uuid.v4(),
      localFile: File(cropped.path),
      isPrimary: context.read<ManageEventBloc>().state.formData.images.isEmpty,
    );
    context.read<ManageEventBloc>().add(ManageEventImageAdded(imageData));
  }
}

class _ImageTile extends StatelessWidget {
  final EventImageData image;
  final int index;
  final bool isPrimary;
  final VoidCallback onRemove;
  final VoidCallback onSetPrimary;

  const _ImageTile({
    required this.image,
    required this.index,
    required this.isPrimary,
    required this.onRemove,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isPrimary ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            child: SizedBox(
              width: 80,
              height: 70,
              child: image.localFile != null
                  ? Image.file(image.localFile!, fit: BoxFit.cover)
                  : image.uploadedUrl != null
                  ? Image.network(image.uploadedUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${context.l10n.manageEventImage} ${index + 1}',
              style: theme.textTheme.bodySmall,
            ),
          ),
          // Star button: tap to set as primary
          IconButton(
            tooltip: isPrimary ? context.l10n.manageEventPrimaryImage : null,
            icon: Icon(
              isPrimary ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isPrimary
                  ? Colors.amber
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onPressed: isPrimary ? null : onSetPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}
