import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_button.dart';
import '../../shared/widgets/wise/wise_input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ctrl = ref.read(authControllerProvider.notifier);
    await ctrl.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    final err = ref.read(authControllerProvider).error;
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString()), behavior: SnackBarBehavior.floating),
      );
    } else if (mounted) {
      context.go(RouteNames.profileSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;
    final loading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.person_add_rounded, color: cs.primary, size: 28),
                ),
                const SizedBox(height: 24),
                Text('Create account', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Join MediNova — your AI health companion',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 40),

                WiseInput(
                  controller: _nameCtrl,
                  hint: 'Your full name',
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v?.trim().length ?? 0) >= 2 ? null : 'Enter your name',
                ),
                const SizedBox(height: 16),

                WiseInput(
                  controller: _emailCtrl,
                  hint: 'you@email.com',
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v?.contains('@') ?? false) ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),

                WiseInput(
                  controller: _passCtrl,
                  hint: 'Min 8 characters',
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscure,
                  suffixIcon: _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixTap: () => setState(() => _obscure = !_obscure),
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v?.length ?? 0) >= 8 ? null : 'Minimum 8 characters',
                ),
                const SizedBox(height: 16),

                WiseInput(
                  controller: _confCtrl,
                  hint: 'Repeat password',
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  validator: (v) => v == _passCtrl.text ? null : 'Passwords do not match',
                ),
                const SizedBox(height: 32),

                WiseButton(label: 'Create Account', onPressed: _register, loading: loading),
                const SizedBox(height: 24),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Already have an account? ', style: tt.bodyMedium),
                  TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('Sign In'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
