// lib/shared/widgets/custom_text.dart

import 'package:flutter/material.dart';

enum TextType {
  title, // Texto grande, negrita, con sombra neón
  subtitle, // Texto mediano, gris, negrita
  body, // Texto normal
}

class CustomText extends StatelessWidget {
  final String text;
  final TextType type;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomText(
    this.text, {
    super.key,
    this.type = TextType.body,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  // Constructores nombrados para facilitar uso
  const CustomText.title(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = TextType.title;

  const CustomText.subtitle(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = TextType.subtitle;

  const CustomText.body(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : type = TextType.body;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case TextType.title:
        return _buildTitle(context);
      case TextType.subtitle:
        return _buildSubtitle(context);
      case TextType.body:
        return _buildBody(context);
    }
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayLarge!;

    return Stack(
      children: [
        // Sombra neón difuminada (color primario)
        Text(
          text,
          textAlign: textAlign ?? TextAlign.center,
          maxLines: maxLines,
          overflow: overflow,

          style: textStyle.copyWith(
            shadows: [
              Shadow(
                color: theme.colorScheme.primary.withAlpha(204),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        // Texto principal
        Text(
          text,
          textAlign: textAlign ?? TextAlign.center,
          maxLines: maxLines,
          overflow: overflow,
          style: textStyle,
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      textAlign: textAlign ?? TextAlign.center,
      maxLines: maxLines,
      overflow: overflow,
      style: theme.textTheme.headlineMedium,
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      textAlign: textAlign ?? TextAlign.center,
      maxLines: maxLines,
      overflow: overflow,
      style: theme.textTheme.bodyLarge,
    );
  }
}
