// lib/features/upgrade_to_promoter/presentation/pages/upgrade_to_promoter_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/upgrade_to_promoter/presentation/bloc/upgrade_to_promoter_bloc.dart';

class UpgradeToPromoterPage extends StatelessWidget {
  const UpgradeToPromoterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UpgradeToPromoterBloc>(),
      child: const _UpgradeToPromoterView(),
    );
  }
}

class _UpgradeToPromoterView extends StatelessWidget {
  const _UpgradeToPromoterView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UpgradeToPromoterBloc, UpgradeToPromoterState>(
      listener: (context, state) {
        if (state is UpgradeToPromoterSuccess) {
          context.go('/promoter-dashboard');
        } else if (state is UpgradeToPromoterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // ── Hero ──────────────────────────────────────────────────────
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
                            context.l10n.upgradeToPromoterHeroTitle,
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
                            context.l10n.upgradeToPromoterHeroSubtitle,
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

            // ── Benefits ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    context.l10n.upgradeToPromoterBenefitsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _BenefitCard(
                    icon: Icons.add_circle_outline,
                    title: context.l10n.upgradeToPromoterBenefit1,
                  ),
                  const SizedBox(height: 10),
                  _BenefitCard(
                    icon: Icons.people_outline,
                    title: context.l10n.upgradeToPromoterBenefit2,
                  ),
                  const SizedBox(height: 10),
                  _BenefitCard(
                    icon: Icons.bar_chart_outlined,
                    title: context.l10n.upgradeToPromoterBenefit3,
                  ),
                  const SizedBox(height: 10),
                  _BenefitCard(
                    icon: Icons.notifications_outlined,
                    title: context.l10n.upgradeToPromoterBenefit4,
                  ),

                  // ── CTA ────────────────────────────────────────────────
                  const SizedBox(height: 28),
                  BlocBuilder<UpgradeToPromoterBloc, UpgradeToPromoterState>(
                    builder: (context, state) {
                      final isLoading = state is UpgradeToPromoterLoading;
                      return FilledButton(
                        onPressed: isLoading
                            ? null
                            : () => context.read<UpgradeToPromoterBloc>().add(
                                const UpgradeToPromoterRequested(),
                              ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(context.l10n.upgradeToPromoterCta),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _BenefitCard({required this.icon, required this.title});

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
