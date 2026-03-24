// lib/shared/widgets/custom_button.dart

import 'package:flutter/material.dart';
import 'package:wap_app/core/theme/app_theme.dart';

enum ButtonType { primary, secondary, outlined }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final Widget? iconWidget;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.iconWidget,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton(context);
    }

    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(context);
      case ButtonType.secondary:
        return _buildSecondaryButton(context);
      case ButtonType.outlined:
        return _buildOutlinedButton(context);
    }
  }

  Widget _buildLoadingButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width ?? double.infinity,
      height: AppTheme.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
        color: theme.colorScheme.primary.withAlpha(127),
      ),
      child: Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onPrimary;

    return Container(
      width: width ?? double.infinity,
      height: AppTheme.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
        color: theme.colorScheme.primary,
        boxShadow: [
          // Sombra de elevación
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          // Sombra neón cyan sutil
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(102),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (iconWidget != null) ...[
                      // Envolver el iconWidget en un SizedBox para controlar tamaño
                      SizedBox(width: 24, height: 24, child: iconWidget!),
                      const SizedBox(width: 12),
                    ] else if (icon != null) ...[
                      Icon(
                        icon,
                        size: 22,
                        color: textColor, // Usar la variable textColor
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: AppTheme.buttonFontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor, // Usar la variable textColor
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSecondary;

    return Container(
      width: width ?? double.infinity,
      height: AppTheme.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
        color: theme.colorScheme.secondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (iconWidget != null) ...[
                      SizedBox(width: 24, height: 24, child: iconWidget!),
                      const SizedBox(width: 12),
                    ] else if (icon != null) ...[
                      Icon(icon, size: 22, color: textColor),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: AppTheme.buttonFontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Container(
      width: width ?? double.infinity,
      height: AppTheme.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(77),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (iconWidget != null) ...[
                      SizedBox(width: 24, height: 24, child: iconWidget!),
                      const SizedBox(width: 12),
                    ] else if (icon != null) ...[
                      Icon(icon, size: 22, color: textColor),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: AppTheme.buttonFontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
