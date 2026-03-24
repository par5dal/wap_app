// lib/features/auth/presentation/pages/unified_auth_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/core/utils/responsive.dart';
import 'package:wap_app/core/validators/validators.dart';
import 'package:wap_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wap_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/shared/widgets/base_page.dart';
import 'package:wap_app/shared/widgets/constrained_content.dart';
import 'package:wap_app/shared/widgets/custom_button.dart';
import 'package:wap_app/shared/widgets/custom_text.dart';
import 'package:wap_app/shared/widgets/custom_text_field.dart';
import 'package:wap_app/shared/widgets/glowing_logo.dart';

enum AuthStep { initial, emailInput, login, register }

class UnifiedAuthPage extends StatefulWidget {
  const UnifiedAuthPage({super.key});

  @override
  State<UnifiedAuthPage> createState() => _UnifiedAuthPageState();
}

class _UnifiedAuthPageState extends State<UnifiedAuthPage> {
  AuthStep _currentStep = AuthStep.initial;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isEmailRegistered = false;
  bool _isCheckingEmail = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailExists() async {
    if (_emailController.text.trim().isEmpty) return;

    setState(() => _isCheckingEmail = true);

    try {
      // Llamar al backend para verificar si el email existe
      final authDataSource = sl<AuthRemoteDataSource>();
      final exists = await authDataSource.checkEmailExists(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isEmailRegistered = exists;
        _currentStep = exists ? AuthStep.login : AuthStep.register;
        _isCheckingEmail = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error checking email', e, stackTrace);

      if (!mounted) return;

      setState(() => _isCheckingEmail = false);
      context.showErrorSnackBar(
        'Error al verificar el email. Por favor, intenta nuevamente.',
      );
    }
  }

  void _submitAuth() {
    if (_formKey.currentState?.validate() != true) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isEmailRegistered) {
      context.read<AuthBloc>().add(
        LoginButtonPressed(email: email, password: password),
      );
    } else {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      context.read<AuthBloc>().add(
        RegisterButtonPressed(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
      );
    }
  }

  String? _validateConfirmPassword(String? value) {
    final t = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return t.authPageConfirmPasswordRequired;
    }
    if (value != _passwordController.text) {
      return t.authPagePasswordsDoNotMatch;
    }
    return null;
  }

  // Calcular altura estimada del contenido según el paso
  double _getEstimatedContentHeight() {
    switch (_currentStep) {
      case AuthStep.initial:
        return 280;
      case AuthStep.emailInput:
        return 280;
      case AuthStep.login:
        return 340;
      case AuthStep.register:
        return 480;
    }
  }

  // Obtener título según el paso
  String _getTitle(AppLocalizations t) {
    switch (_currentStep) {
      case AuthStep.initial:
        return t.authPageWelcome;
      case AuthStep.emailInput:
        return t.authPageEmailOrRegister;
      case AuthStep.login:
        return t.authPageLogin;
      case AuthStep.register:
        return t.authPageCreateAccount;
    }
  }

  // Obtener subtítulo según el paso
  String? _getSubtitle(AppLocalizations t) {
    switch (_currentStep) {
      case AuthStep.initial:
        return t.authPageSubtitle;
      case AuthStep.emailInput:
      case AuthStep.login:
      case AuthStep.register:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFormFailure) {
          context.showErrorSnackBar(state.message);
        } else if (state is AuthRegisterEmailVerificationRequired) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.registerEmailVerifTitle,
              ),
              content: Text(
                AppLocalizations.of(
                  context,
                )!.registerEmailVerifMessage(state.email),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          );
        } else if (state is AuthFormSuccess) {
          // Navegar al home después de login/registro exitoso
          context.goNamed(AppRoute.home.name);
        }
      },
      child: BasePage(
        showAppBar: false,
        enableScroll: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        padding: ResponsiveHelper.getPadding(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          tablet: const EdgeInsets.all(48),
          desktop: const EdgeInsets.all(64),
        ),
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.of(context).size.height;
                final availableHeight =
                    screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    80;

                final contentHeight = _getEstimatedContentHeight();
                final headerHeight = availableHeight - contentHeight - 48;
                final logoSize = (headerHeight * 0.5).clamp(100.0, 200.0);

                return ConstrainedContent(
                  maxWidth: 450,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo fijo
                      GlowingLogo(
                        size: logoSize,
                        logoAssetPath: 'assets/images/icon_light.png',
                      ),

                      SizedBox(height: logoSize > 150 ? 32 : 24),

                      // Título dinámico con animación
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: CustomText.title(
                          _getTitle(t),
                          key: ValueKey(_getTitle(t)),
                        ),
                      ),

                      // Subtítulo dinámico (solo si existe)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: _getSubtitle(t) != null
                            ? Column(
                                children: [
                                  const SizedBox(height: 12),
                                  CustomText.subtitle(_getSubtitle(t)!),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 32),

                      // Contenido dinámico según el paso
                      Form(
                        key: _formKey,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _buildStepContent(context, t),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Botón de retroceso en la esquina superior izquierda
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => GoRouter.of(context).pop(),
                  tooltip: 'Volver',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, AppLocalizations t) {
    switch (_currentStep) {
      case AuthStep.initial:
        return _buildInitialButtons(context, t);
      case AuthStep.emailInput:
        return _buildEmailInput(context, t);
      case AuthStep.login:
        return _buildLoginForm(context, t);
      case AuthStep.register:
        return _buildRegisterForm(context, t);
    }
  }

  Widget _buildInitialButtons(BuildContext context, AppLocalizations t) {
    return Column(
      key: const ValueKey('initial'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: t.authPageContinueWithEmail,
          icon: Icons.email_outlined,
          onPressed: () {
            setState(() => _currentStep = AuthStep.emailInput);
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthFormLoading;
            return CustomButton(
              text: t.authPageContinueWithGoogle,
              type: ButtonType.outlined,
              isLoading: isLoading,
              iconWidget: Image.asset(
                'assets/images/google_logo.png',
                height: 24,
                width: 24,
              ),
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<AuthBloc>().add(const GoogleSignInPressed());
                    },
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthFormLoading;
            return CustomButton(
              text: t.authPageContinueWithApple,
              type: ButtonType.outlined,
              isLoading: isLoading,
              iconWidget: const Icon(Icons.apple, size: 24),
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<AuthBloc>().add(const AppleSignInPressed());
                    },
            );
          },
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () {
              context.pushNamed(AppRoute.forgotPassword.name);
            },
            child: Text(
              t.loginPageForgotPassword,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInput(BuildContext context, AppLocalizations t) {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: t.loginPageEmailHint,
          hint: 'tu@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: (value) => Validators.email(value, t),
          enabled: !_isCheckingEmail,
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: t.authPageContinue,
          icon: Icons.arrow_forward,
          isLoading: _isCheckingEmail,
          onPressed: _isCheckingEmail
              ? null
              : () {
                  if (_formKey.currentState?.validate() == true) {
                    _checkEmailExists();
                  }
                },
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isCheckingEmail
                ? null
                : () {
                    setState(() {
                      _currentStep = AuthStep.initial;
                      _emailController.clear();
                    });
                  },
            child: Text(
              t.authPageGoBack,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, AppLocalizations t) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _emailController.text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        CustomTextField(
          label: t.loginPagePasswordHint,
          hint: '••••••••',
          controller: _passwordController,
          obscureText: true,
          prefixIcon: Icons.lock_outlined,
          validator: (value) => Validators.password(value, t),
        ),

        const SizedBox(height: 16),

        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthFormLoading;
            return CustomButton(
              text: t.loginPageLoginButton,
              icon: Icons.login,
              isLoading: isLoading,
              onPressed: isLoading ? null : _submitAuth,
            );
          },
        ),

        const SizedBox(height: 4),

        Center(
          child: TextButton(
            onPressed: () {
              context.pushNamed(
                AppRoute.forgotPassword.name,
                extra: _emailController.text.trim(),
              );
            },
            child: Text(
              t.loginPageForgotPassword,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _currentStep = AuthStep.emailInput;
                _passwordController.clear();
              });
            },
            child: Text(
              t.authPageChangeEmail,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context, AppLocalizations t) {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _emailController.text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Nombre
        CustomTextField(
          label: t.profileFirstName,
          hint: 'Juan',
          controller: _firstNameController,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Apellidos
        CustomTextField(
          label: t.profileLastName,
          hint: 'García',
          controller: _lastNameController,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Los apellidos son requeridos';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: t.loginPagePasswordHint,
          hint: '••••••••',
          controller: _passwordController,
          obscureText: true,
          prefixIcon: Icons.lock_outlined,
          validator: (value) => Validators.password(value, t),
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: t.authPageConfirmPassword,
          hint: '••••••••',
          controller: _confirmPasswordController,
          obscureText: true,
          prefixIcon: Icons.lock_outlined,
          validator: _validateConfirmPassword,
        ),

        const SizedBox(height: 24),

        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthFormLoading;
            return CustomButton(
              text: t.registerPageRegisterButton,
              icon: Icons.person_add,
              isLoading: isLoading,
              onPressed: isLoading ? null : _submitAuth,
            );
          },
        ),

        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _currentStep = AuthStep.emailInput;
                _firstNameController.clear();
                _lastNameController.clear();
                _passwordController.clear();
                _confirmPasswordController.clear();
              });
            },
            child: Text(
              t.authPageChangeEmail,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
