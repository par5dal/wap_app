// lib/features/auth/presentation/pages/forgot_password_page.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/core/validators/validators.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/shared/widgets/custom_button.dart';
import 'package:wap_app/shared/widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      final dio = sl<Dio>();
      await dio.post(
        '/auth/password/reset-request',
        data: {'email': _emailController.text.trim()},
      );
      // Always show success for security (don't reveal if email exists)
      if (mounted) setState(() => _submitted = true);
    } catch (_) {
      // Still show success to avoid email enumeration
      if (mounted) setState(() => _submitted = true);
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
        title: Text(t.forgotPasswordPageTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _submitted
              ? _buildSuccess(context, t)
              : _buildForm(context, t),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations t) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.lock_reset, size: 72, color: context.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            t.forgotPasswordPageTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            t.forgotPasswordPageSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withAlpha(153),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          CustomTextField(
            label: t.loginPageEmailHint,
            hint: 'tu@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) => Validators.email(value, t),
            enabled:
                !_isLoading &&
                (widget.initialEmail == null || widget.initialEmail!.isEmpty),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: t.forgotPasswordPageSendButton,
            icon: Icons.send,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _sendResetLink,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Icon(
          Icons.mark_email_read_outlined,
          size: 72,
          color: context.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          t.forgotPasswordPageSuccessTitle,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          t.forgotPasswordPageSuccessMessage,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withAlpha(153),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        CustomButton(
          text: t.forgotPasswordPageBackToLogin,
          type: ButtonType.outlined,
          icon: Icons.arrow_back,
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ],
    );
  }
}
