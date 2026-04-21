// lib/features/manage_event/presentation/widgets/wizard_step_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/manage_event/domain/entities/category_entity.dart';
import 'package:wap_app/features/manage_event/presentation/bloc/manage_event_bloc.dart';

class WizardStepDetails extends StatefulWidget {
  final VoidCallback onNext;
  const WizardStepDetails({super.key, required this.onNext});

  @override
  State<WizardStepDetails> createState() => _WizardStepDetailsState();
}

class _WizardStepDetailsState extends State<WizardStepDetails> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  DateTime? _startDt;
  DateTime? _endDt;
  List<String> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    final form = context.read<ManageEventBloc>().state.formData;
    _titleCtrl = TextEditingController(text: form.title);
    _descCtrl = TextEditingController(text: form.description);
    _priceCtrl = TextEditingController(
      text: form.price != null ? form.price.toString() : '',
    );
    _startDt = form.startDatetime;
    _endDt = form.endDatetime;
    _selectedCategoryIds = List<String>.from(form.categoryIds);
  }

  KeyboardActionsConfig _buildKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _descFocus,
          toolbarButtons: [
            (node) => TextButton(
              onPressed: () => node.unfocus(),
              child: Text(
                context.l10n.ok,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        KeyboardActionsItem(
          focusNode: _priceFocus,
          toolbarButtons: [
            (node) => TextButton(
              onPressed: () => node.unfocus(),
              child: Text(
                context.l10n.ok,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void _showCategoryPicker(
    BuildContext context,
    List<CategoryEntity> categories,
  ) {
    String searchTerm = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          final filtered = categories
              .where(
                (c) => c.name.toLowerCase().contains(searchTerm.toLowerCase()),
              )
              .toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.35,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                // ── Sticky header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Seleccionar categorías',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            tooltip: context.l10n.closeAction,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) {
                          setStateModal(() => searchTerm = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar categoría...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchTerm.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setStateModal(() => searchTerm = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                // ── Scrollable list ────────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron categorías',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final category = filtered[index];
                            final isSelected = _selectedCategoryIds.contains(
                              category.id,
                            );

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCategoryIds.remove(category.id);
                                  } else {
                                    _selectedCategoryIds.add(category.id);
                                  }
                                });
                                setStateModal(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withAlpha(30),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Checkbox
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedCategoryIds.remove(
                                              category.id,
                                            );
                                          } else {
                                            _selectedCategoryIds.add(
                                              category.id,
                                            );
                                          }
                                        });
                                        setStateModal(() {});
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    // Icon
                                    if (category.svg != null &&
                                        category.svg!.isNotEmpty)
                                      SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: SvgPicture.string(
                                          category.svg!,
                                          colorFilter: ColorFilter.mode(
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            BlendMode.srcIn,
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.category_outlined,
                                        size: 24,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    const SizedBox(width: 12),
                                    // Name
                                    Expanded(
                                      child: Text(
                                        category.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDt == null || _endDt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.manageEventPickDates)),
      );
      return;
    }
    if (_endDt!.isBefore(_startDt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.manageEventEndBeforeStart)),
      );
      return;
    }
    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.manageEventPickCategory)),
      );
      return;
    }
    context.read<ManageEventBloc>().add(
      ManageEventDetailsUpdated(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        startDatetime: _startDt!,
        endDatetime: _endDt!,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        categoryIds: _selectedCategoryIds,
      ),
    );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.select<ManageEventBloc, List<CategoryEntity>>(
      (b) => b.state.categories,
    );

    return KeyboardActions(
      config: _buildKeyboardConfig(context),
      disableScroll: true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  focusNode: _titleFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _descFocus.requestFocus(),
                  decoration: InputDecoration(
                    labelText: context.l10n.manageEventTitle,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.fieldRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  focusNode: _descFocus,
                  decoration: InputDecoration(
                    labelText: context.l10n.manageEventDescription,
                    border: const OutlineInputBorder(),
                  ),
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 1000,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.fieldRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceCtrl,
                  focusNode: _priceFocus,
                  decoration: InputDecoration(
                    labelText: context.l10n.manageEventPrice,
                    border: const OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return context.l10n.fieldRequired;
                    }
                    final d = double.tryParse(v);
                    if (d == null || d < 0) {
                      return context.l10n.manageEventInvalidPrice;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.manageEventDates,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _DateTimePicker(
                  label: context.l10n.manageEventStartDate,
                  value: _startDt,
                  onChanged: (dt) => setState(() => _startDt = dt),
                  firstDate: DateTime.now(),
                ),
                const SizedBox(height: 8),
                _DateTimePicker(
                  label: context.l10n.manageEventEndDate,
                  value: _endDt,
                  onChanged: (dt) => setState(() => _endDt = dt),
                  firstDate: _startDt ?? DateTime.now(),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.manageEventCategories,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                // Selected categories display
                if (_selectedCategoryIds.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedCategoryIds
                        .map(
                          (catId) =>
                              categories.firstWhere((c) => c.id == catId),
                        )
                        .map((cat) {
                          return Chip(
                            avatar: cat.svg != null && cat.svg!.isNotEmpty
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.string(
                                      cat.svg!,
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).colorScheme.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  )
                                : null,
                            label: Text(cat.name),
                            onDeleted: () {
                              setState(
                                () => _selectedCategoryIds.remove(cat.id),
                              );
                            },
                          );
                        })
                        .toList(),
                  ),
                const SizedBox(height: 8),
                // Category picker button
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(
                    _selectedCategoryIds.isEmpty
                        ? context.l10n.manageEventPickCategory
                        : context.l10n.categoryAddMore,
                  ),
                  onPressed: () => _showCategoryPicker(context, categories),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(context.l10n.next),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;

  static const _minutes = [0, 15, 30, 45];

  const _DateTimePicker({
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now;
    final first = firstDate ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null) return;
    final h = value?.hour ?? 0;
    final m = _minutes.contains(value?.minute ?? 0) ? (value?.minute ?? 0) : 0;
    onChanged(DateTime(date.year, date.month, date.day, h, m));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat('EEE d MMM', locale);

    final hour = value?.hour ?? 0;
    final minute = _minutes.contains(value?.minute ?? -1)
        ? (value?.minute ?? 0)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Row(
          children: [
            // Day button
            Expanded(
              flex: 5,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(
                  value != null ? dateFmt.format(value!) : '—',
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => _pickDate(context),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Hour dropdown
            SizedBox(
              width: 70,
              child: InputDecorator(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: DropdownButton<int>(
                  value: hour,
                  isExpanded: true,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  items: List.generate(24, (i) => i)
                      .map(
                        (h) => DropdownMenuItem(
                          value: h,
                          child: Text(
                            h.toString().padLeft(2, '0'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (h) {
                    if (h == null) return;
                    final base = value ?? DateTime.now();
                    onChanged(
                      DateTime(base.year, base.month, base.day, h, minute),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Minute dropdown (00 / 15 / 30 / 45)
            SizedBox(
              width: 70,
              child: InputDecorator(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: DropdownButton<int>(
                  value: minute,
                  isExpanded: true,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  items: _minutes
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            m.toString().padLeft(2, '0'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (m) {
                    if (m == null) return;
                    final base = value ?? DateTime.now();
                    onChanged(
                      DateTime(base.year, base.month, base.day, hour, m),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
