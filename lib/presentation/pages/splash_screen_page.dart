// lib/presentation/pages/splash_screen_page.dart

import 'package:flutter/material.dart';
import 'package:wap_app/core/theme/app_theme.dart';
import 'package:wap_app/shared/widgets/glowing_logo.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA ADAPTATIVA ---
    // 1. Obtenemos el brillo actual del dispositivo. Esto funciona incluso
    //    antes de que nuestro ThemeCubit se haya inicializado por completo.
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    // 2. Elegimos el tema, el color de fondo y el logo correspondientes.
    final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final logoAssetPath = 'assets/images/icon_light.png';

    // 3. Usamos un widget 'Theme' para asegurar que el 'GlowingLogo'
    //    use los colores correctos (cian en oscuro, morado en claro)
    //    incluso antes de que el ThemeCubit esté activo.
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          // Usa el nuevo widget animado
          child: GlowingLogo(size: 300, logoAssetPath: logoAssetPath),
        ),
      ),
    );
  }
}
