// lib/features/auth/presentation/pages/change_password_page.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/core/validators/validators.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/shared/widgets/custom_button.dart';
import 'package:wap_app/shared/widgets/custom_text_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.authPageConfirmPasswordRequired;
    }
    if (value != _newPasswordController.text) {
      return AppLocalizations.of(context)!.authPagePasswordsDoNotMatch;
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      final dio = sl<Dio>();
      await dio.post(
        '/auth/password/change',
        data: {
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        },
      );
      if (mounted) {
        context.showSuccessSnackBar(
          AppLocalizations.of(context)!.changePasswordPageSuccess,
        );
        GoRouter.of(context).pop();
      }
    } on DioException catch (e) {
      if (mounted) {
        final message =
            e.response?.data?['message'] as String? ?? e.message ?? 'Error';
        context.showErrorSnackBar(message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text(t.changePasswordPageTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                CustomTextField(
                  label: t.changePasswordPageCurrentPassword,
                  hint: '••••••••',
                  controller: _currentPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.validatorRequired;
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: t.changePasswordPageNewPassword,
                  hint: '••••••••',
                  controller: _newPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) => Validators.password(value, t),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: t.changePasswordPageConfirmPassword,
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: _validateConfirmPassword,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: t.changePasswordPageSaveButton,
                  icon: Icons.check,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _changePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
