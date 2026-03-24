// lib/presentation/widgets/shared/theme_switcher_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wap_app/presentation/bloc/theme/theme_cubit.dart';

class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, state) {
        // Elige el icono a mostrar en función del estado actual.
        final IconData icon;
        switch (state) {
          case ThemeMode.light:
            icon = Icons.dark_mode_outlined;
            break;
          case ThemeMode.dark:
            icon = Icons.light_mode_outlined;
            break;
          case ThemeMode.system:
            icon = Icons.brightness_auto_outlined;
            break;
        }
        
        return IconButton(
          icon: Icon(icon),
          tooltip: 'Cambiar tema',
          onPressed: () {
            // Llama al nuevo y simple método 'cycleTheme'.
            context.read<ThemeCubit>().cycleTheme();
          },
        );
      },
    );
  }
}