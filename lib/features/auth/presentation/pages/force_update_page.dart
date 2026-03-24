// lib/features/auth/presentation/pages/force_update_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/shared/widgets/glowing_logo.dart';

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  static const _androidUrl = 'market://details?id=com.jovelupe.wap';
  static const _iosUrl = 'https://apps.apple.com/app/id6759071222';

  Future<void> _openStore() async {
    final storeUrl = Platform.isIOS ? _iosUrl : _androidUrl;
    final uri = Uri.parse(storeUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Fallback to web URL for Android in case the Play Store app is missing
      if (!Platform.isIOS) {
        await launchUrl(
          Uri.parse(
            'https://play.google.com/store/apps/details?id=com.jovelupe.wap',
          ),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                GlowingLogo(
                  size: 160,
                  logoAssetPath: 'assets/images/icon_light.png',
                ),
                const SizedBox(height: 40),
                Text(
                  t.forceUpdateTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  t.forceUpdateMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      t.forceUpdateButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
