import '../../shared/widgets/wise/wise_button.dart';
import '../../shared/widgets/wise/wise_card.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/route_names.dart';



class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData('AI Healthcare', 'Your personal AI doctor available 24/7 for smart health guidance.', Icons.psychology_rounded),
    _OnboardingData('Prescription Scanner', 'Scan any prescription with your camera. AI reads and explains every medicine.', Icons.document_scanner_rounded),
    _OnboardingData('Medical Reports', 'Upload blood tests, MRIs, and X-rays. Get instant AI-powered explanations.', Icons.analytics_rounded),
    _OnboardingData('AI Chatbot', 'Chat with our medical AI assistant for symptom checking and health advice.', Icons.chat_bubble_rounded),
    _OnboardingData('Health Tracking', 'Monitor sleep, water intake, heart rate, and all your vital metrics.', Icons.monitor_heart_rounded),
    _OnboardingData('Doctor Consultations', 'Book appointments and video call doctors from the comfort of your home.', Icons.video_call_rounded),
    _OnboardingData('Family Monitoring', 'Manage the health of your entire family under one account.', Icons.family_restroom_rounded),
    _OnboardingData('Emergency Healthcare', 'One-tap SOS sends your location to emergency contacts instantly.', Icons.emergency_rounded),
    _OnboardingData('Cloud Medical Storage', 'All your medical documents securely stored and accessible anywhere.', Icons.cloud_done_rounded),
    _OnboardingData('AI Wellness Insights', 'Get personalized AI recommendations for a healthier lifestyle.', Icons.spa_rounded),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardedKey, true);
    if (mounted) context.go(RouteNames.login);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (ctx, i) => _OnboardingPage(data: _pages[i]),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottom(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    final isIOS = Platform.isIOS;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _currentPage ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == _currentPage ? kPrimaryText : kBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: WiseButton(
                  label: 'Back',
                  style: WiseButtonStyle.secondary,
                  onPressed: () => _pageCtrl.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 12),
            Expanded(
              child: WiseButton(
                label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _finish,
          child: const Text('Skip', style: TextStyle(color: kSecondaryText)),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );

    if (isIOS) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: WiseCard(padding: const EdgeInsets.all(20), child: content),
      );
    }
    return Container(
      padding: const EdgeInsets.all(24),
      color: kPrimaryText,
      child: content,
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kBorder, width: 1),
              color: kElevated,
            ),
            child: Icon(data.icon, color: kPrimaryText, size: 64),
          ),
          const SizedBox(height: 48),
          Text(data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kPrimaryText, fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text(data.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kSecondaryText, fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title, subtitle;
  final IconData icon;
  const _OnboardingData(this.title, this.subtitle, this.icon);
}
