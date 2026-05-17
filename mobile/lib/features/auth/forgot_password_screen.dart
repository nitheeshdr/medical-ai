import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/wise/wise_button.dart';
import '../../shared/widgets/wise/wise_input.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  String? _emailError;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Enter your email address');
      return;
    }
    await ref.read(authControllerProvider.notifier).resetPassword(email);
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: kAccent),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _sent ? _SuccessView(email: _emailCtrl.text) : _FormView(
            emailCtrl: _emailCtrl,
            emailError: _emailError,
            isLoading: isLoading,
            onChanged: (_) => setState(() => _emailError = null),
            onSend: _send,
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final String? emailError;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  const _FormView({
    required this.emailCtrl, required this.emailError,
    required this.isLoading, required this.onChanged, required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: kAccentLight, borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.lock_reset_rounded, color: kAccent, size: 32),
        ),
        const SizedBox(height: 24),
        const Text('Forgot Password?',
            style: TextStyle(color: kPrimaryText, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        const Text('Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(color: kSecondaryText, fontSize: 15, height: 1.4)),
        const SizedBox(height: 32),
        WiseInput(
          label: 'Email Address',
          hint: 'you@example.com',
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          error: emailError,
          onChanged: onChanged,
        ),
        const SizedBox(height: 24),
        WiseButton(
          label: 'Send Reset Link',
          onPressed: isLoading ? null : onSend,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: kSuccessLight, borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.mark_email_read_rounded, color: kSuccessGreen, size: 40),
        ),
        const SizedBox(height: 24),
        const Text('Check your inbox',
            style: TextStyle(color: kPrimaryText, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('We sent a password reset link to\n$email',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kSecondaryText, fontSize: 15, height: 1.5)),
        const SizedBox(height: 32),
        WiseButton(
          label: 'Back to Sign In',
          style: WiseButtonStyle.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
