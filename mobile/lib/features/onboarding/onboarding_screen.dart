import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/route_names.dart';

// ─── Onboarding — 4 concise feature slides ────────────────────────────────────
// Replaces the old 10-slide carousel that had no data collection.
// After the last slide, the user is taken to Login (or ProfileSetup after sign-up).
// ─────────────────────────────────────────────────────────────────────────────

class _SlideData {
  final IconData icon;
  final Color iconBg;
  final String headline;
  final String body;
  const _SlideData({
    required this.icon,
    required this.iconBg,
    required this.headline,
    required this.body,
  });
}

const _slides = [
  _SlideData(
    icon: Icons.psychology_rounded,
    iconBg: Color(0xFF1A3A5C),
    headline: 'Your AI Health Companion',
    body: 'Ask medical questions, check symptoms, scan prescriptions, and get plain-English explanations of your lab reports — all in one place.',
  ),
  _SlideData(
    icon: Icons.document_scanner_rounded,
    iconBg: Color(0xFF1A3A3A),
    headline: 'Instant Rx & Report Analysis',
    body: 'Point your camera at any prescription or medical report. MediNova reads it, flags interactions, and explains every term in seconds.',
  ),
  _SlideData(
    icon: Icons.monitor_heart_rounded,
    iconBg: Color(0xFF3A1A2C),
    headline: 'Track Every Vital, Every Day',
    body: 'Log water, sleep, steps, heart rate, and blood pressure. Connect a wearable or enter readings manually — your health timeline builds itself.',
  ),
  _SlideData(
    icon: Icons.family_restroom_rounded,
    iconBg: Color(0xFF1A3A1A),
    headline: 'Care for Your Whole Family',
    body: 'Add family members, manage their medications, book doctor consultations, and activate one-tap SOS for emergencies — all from one account.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardedKey, true);
    if (mounted) context.go(RouteNames.login);
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _ctrl,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _SlidePage(data: _slides[i]),
          ),

          // Skip button top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: TextButton(
              onPressed: _finish,
              child: Text('Skip', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 28 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _page ? cs.primary : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      if (_page > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _ctrl.previousPage(
                              duration: const Duration(milliseconds: 380),
                              curve: Curves.easeInOut,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(isLast ? 'Get Started' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _SlideData data;
  const _SlidePage({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon in a styled container
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(data.icon, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 52),
          Text(
            data.headline,
            textAlign: TextAlign.center,
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: tt.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.65,
            ),
          ),
          // Space for bottom controls
          const SizedBox(height: 160),
        ],
      ),
    );
  }
}
