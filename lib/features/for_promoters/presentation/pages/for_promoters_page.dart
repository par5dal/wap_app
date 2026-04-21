// lib/features/for_promoters/presentation/pages/for_promoters_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';

class ForPromotersPage extends StatelessWidget {
  const ForPromotersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button row
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Image.asset(
                        'assets/images/app_icon.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          context.l10n.forPromotersHeroTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          context.l10n.forPromotersHeroSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black.withValues(alpha: 0.7),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Benefits ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  context.l10n.forPromotersBenefitsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _BenefitCard(
                  icon: Icons.rocket_launch_outlined,
                  title: context.l10n.forPromotersBenefit1Title,
                  description: context.l10n.forPromotersBenefit1Desc,
                ),
                const SizedBox(height: 10),
                _BenefitCard(
                  icon: Icons.trending_up_rounded,
                  title: context.l10n.forPromotersBenefit2Title,
                  description: context.l10n.forPromotersBenefit2Desc,
                ),
                const SizedBox(height: 10),
                _BenefitCard(
                  icon: Icons.explore_outlined,
                  title: context.l10n.forPromotersBenefit3Title,
                  description: context.l10n.forPromotersBenefit3Desc,
                ),
                const SizedBox(height: 10),
                _BenefitCard(
                  icon: Icons.tune_rounded,
                  title: context.l10n.forPromotersBenefit4Title,
                  description: context.l10n.forPromotersBenefit4Desc,
                ),

                // ── CTAs ────────────────────────────────────────────────────
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () =>
                      context.push('/auth', extra: {'role': 'PROMOTER'}),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(context.l10n.forPromotersCtaRegister),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.push('/auth'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(context.l10n.forPromotersCtaLogin),
                ),
                const SizedBox(height: 28),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.lightPrimary, AppColors.lightSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
