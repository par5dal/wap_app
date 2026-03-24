// lib/shared/widgets/base_page.dart

import 'package:flutter/material.dart';

/// Página base con comportamiento responsive estándar
class BasePage extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool useSafeArea;
  final bool enableScroll;
  final EdgeInsets? padding;
  final Widget? drawer;
  final Color? backgroundColor;

  const BasePage({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
    this.showAppBar = true,
    this.useSafeArea = true,
    this.enableScroll = true,
    this.padding,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Añadir padding si se especifica
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Hacer scroll automático si está habilitado
    if (enableScroll) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }

    // Usar SafeArea si está habilitado
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppBar
          ? AppBar(title: title != null ? Text(title!) : null, actions: actions)
          : null,
      drawer: drawer,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
