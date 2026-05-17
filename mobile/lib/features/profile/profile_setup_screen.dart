import 'dart:convert';
import '../../shared/widgets/wise/wise_input.dart';
import '../../shared/widgets/wise/wise_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';

const _storage = FlutterSecureStorage();

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _step = 0;
  String? _selectedBloodType;
  final List<String> _selectedAllergies = [];
  final List<String> _selectedConditions = [];
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _dobCtrl    = TextEditingController();

  static const _allergies  = ['Penicillin', 'Aspirin', 'Shellfish', 'Peanuts', 'Latex', 'Pollen'];
  static const _conditions = ['Diabetes', 'Hypertension', 'Asthma', 'Heart Disease', 'Thyroid', 'None'];

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  /// Merge profile fields into the stored user map and refresh the auth provider.
  Future<void> _saveProfile() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    final Map<String, dynamic> user = raw != null
        ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
        : {};

    user['dob']        = _dobCtrl.text.trim();
    user['height']     = _heightCtrl.text.trim();
    user['weight']     = _weightCtrl.text.trim();
    user['bloodType']  = _selectedBloodType ?? '';
    user['allergies']  = _selectedAllergies;
    user['conditions'] = _selectedConditions;

    await _storage.write(key: AppConstants.userKey, value: jsonEncode(user));
    ref.read(authStateProvider.notifier).setUser(user);
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildBasicInfo();
      case 1: return _buildBloodAllergies();
      case 2: return _buildConditions();
      default: return _buildComplete();
    }
  }

  Widget _buildBasicInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Basic Information',
          style: TextStyle(color: kPrimaryText, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 24),
      WiseInput(controller: _dobCtrl, hint: 'Date of Birth (YYYY-MM-DD)',
          label: 'Date of Birth', prefixIcon: Icons.cake_outlined),
      const SizedBox(height: 16),
      WiseInput(controller: _heightCtrl, hint: 'Height (cm)', label: 'Height',
          keyboardType: TextInputType.number, prefixIcon: Icons.height),
      const SizedBox(height: 16),
      WiseInput(controller: _weightCtrl, hint: 'Weight (kg)', label: 'Weight',
          keyboardType: TextInputType.number, prefixIcon: Icons.monitor_weight_outlined),
    ],
  );

  Widget _buildBloodAllergies() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Blood Type & Allergies',
          style: TextStyle(color: kPrimaryText, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 24),
      const Text('Blood Type', style: TextStyle(color: kSecondaryText, fontSize: 14)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: AppConstants.bloodTypes.map((t) => _Chip(
          label: t, selected: _selectedBloodType == t,
          onTap: () => setState(() => _selectedBloodType = t),
        )).toList(),
      ),
      const SizedBox(height: 24),
      const Text('Allergies', style: TextStyle(color: kSecondaryText, fontSize: 14)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _allergies.map((a) => _Chip(
          label: a, selected: _selectedAllergies.contains(a),
          onTap: () => setState(() => _selectedAllergies.contains(a)
              ? _selectedAllergies.remove(a) : _selectedAllergies.add(a)),
        )).toList(),
      ),
    ],
  );

  Widget _buildConditions() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Medical Conditions',
          style: TextStyle(color: kPrimaryText, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Select any existing conditions',
          style: TextStyle(color: kSecondaryText, fontSize: 14)),
      const SizedBox(height: 24),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _conditions.map((c) => _Chip(
          label: c, selected: _selectedConditions.contains(c),
          onTap: () => setState(() => _selectedConditions.contains(c)
              ? _selectedConditions.remove(c) : _selectedConditions.add(c)),
        )).toList(),
      ),
    ],
  );

  Widget _buildComplete() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.check_circle_rounded, color: kSuccessGreen, size: 80),
      const SizedBox(height: 24),
      const Text('Profile Complete!',
          style: TextStyle(color: kPrimaryText, fontSize: 28, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Your medical profile is set up.\nWelcome to MediNova AI!',
          textAlign: TextAlign.center,
          style: TextStyle(color: kSecondaryText, fontSize: 16, height: 1.6)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_step + 1) / 4,
                backgroundColor: kBorder,
                color: kPrimaryText,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text('Step ${_step + 1} of 4',
                  style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              const SizedBox(height: 32),
              Expanded(child: _buildStep()),
              const SizedBox(height: 24),
              WiseButton(
                label: _step < 3 ? 'Continue' : 'Go to Dashboard',
                onPressed: () async {
                  if (_step < 3) {
                    setState(() => _step++);
                  } else {
                    await _saveProfile();
                    if (mounted) context.go(RouteNames.dashboard);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimaryText : kElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? kPrimaryText : kBorder),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? kBlack : kSecondaryText,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }
}
