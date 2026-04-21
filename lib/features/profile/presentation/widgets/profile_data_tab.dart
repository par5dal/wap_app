import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ProfileDataTab extends StatefulWidget {
  final ProfileEntity? profile;
  final bool isLoading;
  final String? email;
  final String? role;

  const ProfileDataTab({
    super.key,
    required this.profile,
    required this.isLoading,
    this.email,
    this.role,
  });

  @override
  State<ProfileDataTab> createState() => _ProfileDataTabState();
}

class _ProfileDataTabState extends State<ProfileDataTab> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  DateTime? _selectedDate;
  bool _hasInitializedFields = false;
  final Dio _dio = Dio();
  // session_token agrupa suggest+retrieve en una sola sesión de facturación
  final String _sessionToken = const Uuid().v4();

  @override
  void didUpdateWidget(ProfileDataTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != null && !_hasInitializedFields) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    setState(() {
      _firstNameController.text = widget.profile?.firstName ?? '';
      _lastNameController.text = widget.profile?.lastName ?? '';
      _addressController.text = widget.profile?.address ?? '';
      _companyNameController.text = widget.profile?.companyName ?? '';
      _taxIdController.text = widget.profile?.taxId ?? '';
      _websiteUrlController.text = widget.profile?.websiteUrl ?? '';
      _selectedDate = widget.profile?.dateOfBirth;
      _hasInitializedFields = true;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _companyNameController.dispose();
    _taxIdController.dispose();
    _websiteUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.profileSelectImageSource),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.l10n.profileCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.l10n.profileGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result == null || !context.mounted) return;

    final pickedFile = await picker.pickImage(source: result);
    if (pickedFile != null && context.mounted) {
      context.read<ProfileBloc>().add(
        ProfileAvatarUploadRequested(File(pickedFile.path)),
      );
    }
  }

  Future<void> _removeAvatar(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.profileRemoveAvatar),
        content: Text(context.l10n.profileRemoveAvatarConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.remove),
          ),
        ],
      ),
    );

    if (confirmed == true &&
        widget.profile?.avatarUrl != null &&
        context.mounted) {
      context.read<ProfileBloc>().add(
        ProfileAvatarDeleteRequested(widget.profile!.avatarUrl!),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 años
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _saveProfile(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ProfileUpdateRequested(
          firstName: _firstNameController.text.trim().isEmpty
              ? null
              : _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim().isEmpty
              ? null
              : _lastNameController.text.trim(),
          dateOfBirth: _selectedDate,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          companyName: _companyNameController.text.trim().isEmpty
              ? null
              : _companyNameController.text.trim(),
          taxId: _taxIdController.text.trim().isEmpty
              ? null
              : _taxIdController.text.trim(),
          websiteUrl: _websiteUrlController.text.trim().isEmpty
              ? null
              : _websiteUrlController.text.trim(),
        ),
      );
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.logoutDialogTitle),
        content: Text(context.l10n.logoutDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.logoutDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.logoutDialogConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Ejecutar logout
      sl<AppBloc>().add(AppLogoutRequested());
      // Navegar a home después del logout
      context.goNamed(AppRoute.home.name);
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final t = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.deleteAccountConfirmTitle),
        content: Text(t.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.logoutDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.deleteAccountConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final email = widget.email;
      if (email == null || email.isEmpty) return;
      try {
        final dio = sl<Dio>();
        await dio.post(
          '/users/public/request-deletion',
          data: {'email': email},
        );
        if (context.mounted) {
          context.showSuccessSnackBar(t.deleteAccountSuccess);
        }
      } catch (e) {
        if (context.mounted) {
          context.showErrorSnackBar(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profile != null && !_hasInitializedFields) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFields();
      });
    }

    final t = context.l10n;
    final authProvider =
        sl<SharedPreferences>().getString('cached_auth_provider') ?? 'email';
    final isEmailProvider = authProvider == 'email';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Avatar section ──────────────────────────────────────────
            Center(child: _buildAvatarSection(context)),
            const SizedBox(height: 28),

            // ── Personal info card ───────────────────────────────────────
            _SectionCard(
              title: t.profileTabProfile,
              children: [
                // Name row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: t.profileFirstName,
                        hint: t.profileFirstNameHint,
                        enabled: !widget.isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: t.profileLastName,
                        hint: t.profileLastNameHint,
                        enabled: !widget.isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildDateField(context),
                const SizedBox(height: 14),
                _buildAddressField(context),
                if (widget.role == 'PROMOTER' || widget.role == 'ADMIN')
                  ..._buildPromoterFields(),
                const SizedBox(height: 20),
                // Save button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: widget.isLoading
                        ? null
                        : () => _saveProfile(context),
                    icon: widget.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 20),
                    label: Text(
                      t.profileSave,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightSecondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Account actions card ────────────────────────────────────
            _SectionCard(
              title: 'Cuenta',
              children: [
                if (isEmailProvider)
                  _ActionTile(
                    icon: Icons.lock_reset_outlined,
                    label: t.changePasswordProfileTile,
                    onTap: widget.isLoading
                        ? null
                        : () => context.pushNamed(AppRoute.changePassword.name),
                  ),
                if (isEmailProvider) _divider(),
                _ActionTile(
                  icon: Icons.logout,
                  label: t.navBarLogout,
                  color: Colors.red,
                  onTap: widget.isLoading
                      ? null
                      : () => _showLogoutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Danger zone card ────────────────────────────────────────
            _SectionCard(
              title: 'Control de Datos',
              titleColor: Colors.red.shade400,
              children: [
                _ActionTile(
                  icon: Icons.delete_forever_outlined,
                  label: t.deleteAccountProfileTile,
                  color: Colors.red.shade400,
                  onTap: widget.isLoading
                      ? null
                      : () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final hasAvatar = widget.profile?.avatarUrl != null;

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightPrimary.withAlpha(25),
          ),
          child: hasAvatar
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.profile!.avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.lightPrimary,
                ),
        ),
        // Botón para eliminar foto (solo visible si hay avatar)
        if (hasAvatar)
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onTap: widget.isLoading ? null : () => _removeAvatar(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        // Botón para cambiar/agregar foto
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: widget.isLoading ? null : () => _pickImage(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(76)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: !widget.isLoading,
      decoration: InputDecoration(
        labelText: context.l10n.profileDateOfBirth,
        hintText: _selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
            : 'DD/MM/AAAA',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(76)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: widget.isLoading ? null : () => _selectDate(context),
      controller: TextEditingController(
        text: _selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
            : '',
      ),
    );
  }

  List<Widget> _buildPromoterFields() {
    return [
      const SizedBox(height: 14),
      const Divider(),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          'Datos de promotor',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      _buildTextField(
        controller: _companyNameController,
        label: 'Empresa / Organización',
        hint: 'Nombre de tu empresa u organización',
        enabled: !widget.isLoading,
      ),
      const SizedBox(height: 14),
      _buildTextField(
        controller: _taxIdController,
        label: 'NIF / CIF',
        hint: 'Número de identificación fiscal',
        enabled: !widget.isLoading,
      ),
      const SizedBox(height: 14),
      _buildTextField(
        controller: _websiteUrlController,
        label: 'Sitio web',
        hint: 'https://tuempresa.com',
        enabled: !widget.isLoading,
      ),
    ];
  }

  Widget _buildAddressField(BuildContext context) {
    final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim() ?? '';

    return TypeAheadField<Map<String, dynamic>>(
      controller: _addressController,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: !widget.isLoading,
          decoration: InputDecoration(
            labelText: context.l10n.profileAddress,
            hintText: context.l10n.profileAddressHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withAlpha(76)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.lightPrimary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: const Icon(Icons.location_on),
          ),
        );
      },
      suggestionsCallback: (search) async {
        if (search.isEmpty) return [];
        return await _fetchPlaceSuggestions(search, accessToken);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.grey),
          title: Text(
            suggestion['description'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        );
      },
      onSelected: (suggestion) {
        _addressController.text = suggestion['description'] ?? '';
      },
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No se encontraron direcciones'),
      ),
      errorBuilder: (context, error) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: $error'),
      ),
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPlaceSuggestions(
    String input,
    String accessToken,
  ) async {
    if (accessToken.isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/search/searchbox/v1/suggest',
        queryParameters: {
          'q': input,
          'session_token': _sessionToken,
          'language': 'es',
          'country': 'es',
          'access_token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final suggestions = response.data['suggestions'] as List;
        return suggestions
            .map((s) {
              final name = (s['name'] as String?) ?? '';
              final placeFormatted = (s['place_formatted'] as String?) ?? '';
              final fullAddress = (s['full_address'] as String?) ?? '';
              // POI/lugar: "Catedral de León, León, España"
              // Dirección pura: usar full_address
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
              return <String, dynamic>{
                'description': description,
                'mapbox_id': (s['mapbox_id'] as String?) ?? '',
              };
            })
            .where(
              (s) =>
                  (s['mapbox_id'] as String).isNotEmpty &&
                  (s['description'] as String).isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching Mapbox suggestions (profile): $e');
    }

    return [];
  }
}

// ─── Shared card wrapper ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: titleColor ?? context.colorScheme.onSurface.withAlpha(140),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colorScheme.outline.withAlpha(40)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tappable action row ──────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: effectiveColor.withAlpha(128),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _divider() => const Divider(height: 1, indent: 36);
