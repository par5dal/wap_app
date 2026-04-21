// lib/features/onboarding/presentation/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/l10n/app_localizations.dart';

// ─── Data ────────────────────────────────────────────────────────────────────

class _FeatureSlideData {
  const _FeatureSlideData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _kSlideCount = 4;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _kSlideCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    sl<SharedPreferences>().setBool('onboarding_seen', true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final featureSlides = [
      _FeatureSlideData(
        title: t.onboardingSlide2Title,
        subtitle: t.onboardingSlide2Subtitle,
        icon: Icons.map_rounded,
        accentColor: const Color(0xFF00D4FF),
      ),
      _FeatureSlideData(
        title: t.onboardingSlide3Title,
        subtitle: t.onboardingSlide3Subtitle,
        icon: Icons.favorite_rounded,
        accentColor: const Color(0xFFFF6B9D),
      ),
      _FeatureSlideData(
        title: t.onboardingSlide4Title,
        subtitle: t.onboardingSlide4Subtitle,
        icon: Icons.rocket_launch_rounded,
        accentColor: const Color(0xFFFF2D78),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A18),
      body: Stack(
        children: [
          // ── PageView ──────────────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _kSlideCount,
            itemBuilder: (context, index) {
              if (index == 0) return _WelcomeSlide(t: t);
              return _FeatureSlide(data: featureSlides[index - 1]);
            },
          ),

          // ── Saltar (top right) ────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: AnimatedOpacity(
                  opacity: _currentPage < _kSlideCount - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _currentPage < _kSlideCount - 1 ? _finish : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                    ),
                    child: Text(t.onboardingSkip),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom controls ───────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 52, left: 32, right: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _kSlideCount,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Gradient action button
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _goToNext,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00D4FF), Color(0xFFFF2D78)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00D4FF,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: Text(
                                _currentPage < _kSlideCount - 1
                                    ? t.onboardingNext
                                    : t.onboardingStart,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slide 1: Welcome / Brand ─────────────────────────────────────────────────

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({required this.t});
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A18), Color(0xFF14102E)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset('assets/images/icon_light.png', width: 200),
              const SizedBox(height: 40),
              Text(
                t.onboardingSlide1Title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.onboardingSlide1Subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                  height: 1.65,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Slides 2 & 3: Feature slides ─────────────────────────────────────────────

class _FeatureSlide extends StatelessWidget {
  const _FeatureSlide({required this.data});
  final _FeatureSlideData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A18),
            Color.lerp(const Color(0xFF0A0A18), data.accentColor, 0.12)!,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Feature icon in a glowing circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.accentColor.withValues(alpha: 0.10),
                  border: Border.all(
                    color: data.accentColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.accentColor.withValues(alpha: 0.20),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(data.icon, size: 48, color: data.accentColor),
              ),
              const SizedBox(height: 36),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                  height: 1.65,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
