import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_button.dart';
import '../../shared/widgets/wise/wise_input.dart';

const _storage = FlutterSecureStorage();

// ─── Profile setup — 6 contextual steps ──────────────────────────────────────
// Step 0: Basic vitals (DOB, height, weight, gender)
// Step 1: Blood type & emergency contact
// Step 2: Known allergies
// Step 3: Existing medical conditions
// Step 4: Current medications
// Step 5: Health goals (used by AI to personalise insights)
// Step 6: Complete ✅
// ─────────────────────────────────────────────────────────────────────────────

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _step = 0;
  static const _totalSteps = 6;

  // Step 0 — Basic vitals
  final _dobCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _gender = '';

  // Step 1 — Blood type & emergency contact
  String? _bloodType;
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  String _emergencyRelation = '';

  // Step 2 — Allergies
  final _selectedAllergies = <String>{};
  final _otherAllergyCtrl = TextEditingController();

  // Step 3 — Medical conditions
  final _selectedConditions = <String>{};

  // Step 4 — Current medications
  final List<String> _medications = [];
  final _medCtrl = TextEditingController();

  // Step 5 — Health goals
  final _selectedGoals = <String>{};
  String _primaryGoal = '';

  static const _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  static const _relations = ['Spouse', 'Parent', 'Child', 'Sibling', 'Friend', 'Other'];
  static const _allergies = [
    'Penicillin', 'Aspirin', 'Ibuprofen', 'Sulfa drugs', 'Codeine',
    'Shellfish', 'Peanuts', 'Tree nuts', 'Milk / Dairy', 'Eggs',
    'Wheat / Gluten', 'Soy', 'Latex', 'Pollen', 'Dust mites', 'Pet dander',
  ];
  static const _conditions = [
    'Type 1 Diabetes', 'Type 2 Diabetes', 'Hypertension', 'Heart Disease',
    'Asthma', 'COPD', 'Arthritis', 'Thyroid (Hypo)', 'Thyroid (Hyper)',
    'Depression', 'Anxiety', 'PCOS', 'Kidney Disease', 'Cancer (history)',
    'Stroke (history)', 'None of the above',
  ];
  static const _goals = [
    'Improve overall fitness', 'Manage a chronic condition', 'Lose weight',
    'Build muscle', 'Better sleep quality', 'Reduce stress',
    'Monitor medications', 'Manage family health', 'Prevent disease',
    'Track vitals daily',
  ];

  @override
  void dispose() {
    _dobCtrl.dispose(); _heightCtrl.dispose(); _weightCtrl.dispose();
    _emergencyNameCtrl.dispose(); _emergencyPhoneCtrl.dispose();
    _otherAllergyCtrl.dispose(); _medCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    final Map<String, dynamic> user = raw != null
        ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
        : {};

    final allAllergies = [
      ..._selectedAllergies,
      if (_otherAllergyCtrl.text.trim().isNotEmpty)
        _otherAllergyCtrl.text.trim(),
    ];

    user['dob'] = _dobCtrl.text.trim();
    user['height'] = _heightCtrl.text.trim();
    user['weight'] = _weightCtrl.text.trim();
    user['gender'] = _gender;
    user['bloodType'] = _bloodType ?? '';
    user['emergencyContact'] = {
      'name': _emergencyNameCtrl.text.trim(),
      'phone': _emergencyPhoneCtrl.text.trim(),
      'relation': _emergencyRelation,
    };
    user['allergies'] = allAllergies;
    user['conditions'] = _selectedConditions.toList();
    user['medications'] = _medications;
    user['healthGoals'] = _selectedGoals.toList();
    user['primaryGoal'] = _primaryGoal;
    user['profileComplete'] = true;

    // Also send to backend if possible
    try {
      // Backend update happens through settings screen; here we just store locally
    } catch (_) {}

    await _storage.write(key: AppConstants.userKey, value: jsonEncode(user));
    ref.read(authStateProvider.notifier).setUser(user);
  }

  bool _canProceed() {
    switch (_step) {
      case 0: return _dobCtrl.text.trim().isNotEmpty && _gender.isNotEmpty;
      case 1: return _bloodType != null;
      case 2: return true; // allergies optional
      case 3: return _selectedConditions.isNotEmpty;
      case 4: return true; // medications optional
      case 5: return _selectedGoals.isNotEmpty && _primaryGoal.isNotEmpty;
      default: return true;
    }
  }

  void _next() {
    if (!_canProceed()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_step > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => setState(() => _step--),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (_step > 0) const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _step < _totalSteps ? (_step + 1) / (_totalSteps + 1) : 1.0,
                            minHeight: 6,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _step < _totalSteps ? '${_step + 1} / $_totalSteps' : 'Done',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: _buildStep(cs, tt),
              ),
            ),

            // Bottom action
            if (_step < _totalSteps)
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
                child: WiseButton(
                  label: _step == _totalSteps - 1 ? 'Review & Finish' : 'Continue',
                  onPressed: _next,
                ),
              ),

            if (_step == _totalSteps)
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
                child: WiseButton(
                  label: 'Go to Dashboard',
                  onPressed: () async {
                    await _saveProfile();
                    if (mounted) context.go(RouteNames.dashboard);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(ColorScheme cs, TextTheme tt) {
    switch (_step) {
      case 0: return _buildBasicVitals(cs, tt);
      case 1: return _buildBloodAndEmergency(cs, tt);
      case 2: return _buildAllergies(cs, tt);
      case 3: return _buildConditions(cs, tt);
      case 4: return _buildMedications(cs, tt);
      case 5: return _buildGoals(cs, tt);
      default: return _buildComplete(cs, tt);
    }
  }

  // ── Step 0: Basic vitals ──────────────────────────────────────────────────

  Widget _buildBasicVitals(ColorScheme cs, TextTheme tt) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepHeader(tt, 'Your Basic Profile', 'This helps MediNova AI personalise your health insights and track changes over time.'),
      const SizedBox(height: 28),
      WiseInput(
        controller: _dobCtrl,
        hint: 'YYYY-MM-DD',
        label: 'Date of Birth *',
        prefixIcon: Icons.cake_outlined,
        keyboardType: TextInputType.datetime,
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: WiseInput(
          controller: _heightCtrl,
          hint: 'e.g. 170',
          label: 'Height (cm)',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.height,
        )),
        const SizedBox(width: 12),
        Expanded(child: WiseInput(
          controller: _weightCtrl,
          hint: 'e.g. 65',
          label: 'Weight (kg)',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.monitor_weight_outlined,
        )),
      ]),
      const SizedBox(height: 20),
      Text('Gender *', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: _genders.map((g) => _Chip(
        label: g,
        selected: _gender == g,
        onTap: () => setState(() => _gender = g),
        cs: cs,
      )).toList()),
    ],
  );

  // ── Step 1: Blood type & emergency contact ────────────────────────────────

  Widget _buildBloodAndEmergency(ColorScheme cs, TextTheme tt) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepHeader(tt, 'Blood Type & Emergency Contact', 'Critical information used in emergencies and for blood-type specific recommendations.'),
      const SizedBox(height: 28),
      Text('Blood Type *', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: AppConstants.bloodTypes.map((t) => _Chip(
          label: t,
          selected: _bloodType == t,
          onTap: () => setState(() => _bloodType = t),
          cs: cs,
        )).toList(),
      ),
      const SizedBox(height: 28),
      Text('Emergency Contact', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text('Used for SOS alerts — they will be contacted in emergencies.', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 12),
      WiseInput(controller: _emergencyNameCtrl, hint: 'Full name', label: 'Contact Name', prefixIcon: Icons.person_outline),
      const SizedBox(height: 12),
      WiseInput(controller: _emergencyPhoneCtrl, hint: '+1 555 000 0000', label: 'Phone Number', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
      const SizedBox(height: 16),
      Text('Relationship', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: _relations.map((r) => _Chip(
        label: r,
        selected: _emergencyRelation == r,
        onTap: () => setState(() => _emergencyRelation = r),
        cs: cs,
      )).toList()),
    ],
  );

  // ── Step 2: Allergies ─────────────────────────────────────────────────────

  Widget _buildAllergies(ColorScheme cs, TextTheme tt) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepHeader(tt, 'Known Allergies', 'Select all that apply. The AI will warn you when scanned prescriptions or recommendations contain these substances.'),
      const SizedBox(height: 28),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _allergies.map((a) => _Chip(
          label: a,
          selected: _selectedAllergies.contains(a),
          onTap: () => setState(() => _selectedAllergies.contains(a) ? _selectedAllergies.remove(a) : _selectedAllergies.add(a)),
          cs: cs,
        )).toList(),
      ),
      const SizedBox(height: 20),
      WiseInput(
        controller: _otherAllergyCtrl,
        hint: 'e.g. Contrast dye',
        label: 'Other allergy (optional)',
        prefixIcon: Icons.add_circle_outline,
      ),
      if (_selectedAllergies.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _InfoBanner(
            cs: cs,
            text: 'No allergies selected. You can skip this step — you can update it later in Settings.',
          ),
        ),
    ],
  );

  // ── Step 3: Medical conditions ────────────────────────────────────────────

  Widget _buildConditions(ColorScheme cs, TextTheme tt) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepHeader(tt, 'Medical Conditions', 'Select all current or past diagnoses. This helps the AI provide safe, relevant guidance.'),
      const SizedBox(height: 28),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _conditions.map((c) => _Chip(
          label: c,
          selected: _selectedConditions.contains(c),
          onTap: () => setState(() {
            if (c == 'None of the above') {
              _selectedConditions.clear();
              _selectedConditions.add(c);
            } else {
              _selectedConditions.remove('None of the above');
              _selectedConditions.contains(c) ? _selectedConditions.remove(c) : _selectedConditions.add(c);
            }
          }),
          cs: cs,
        )).toList(),
      ),
    ],
  );

  // ── Step 4: Current medications ───────────────────────────────────────────

  Widget _buildMedications(ColorScheme cs, TextTheme tt) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepHeader(tt, 'Current Medications', 'List medicines you take regularly. The AI will check interactions when scanning new prescriptions.'),
      const SizedBox(height: 28),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: WiseInput(
              controller: _medCtrl,
              hint: 'e.g. Metformin 500mg',
              label: 'Add medication',
              prefixIcon: Icons.medication_outlined,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () {
              final med = _medCtrl.text.trim();
              if (med.isNotEmpty) {
                setState(() { _medications.add(med); _medCtrl.clear(); });
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add',
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (_medications.isEmpty)
        _InfoBanner(cs: cs, text: 'No medications added. You can skip this step or add them later in your profile.')
      else
        ..._medications.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outlineVariant),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(Icons.medication_liquid_outlined, color: cs.primary),
            title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: IconButton(
              icon: Icon(Icons.close, color: cs.error, size: 18),
              onPressed: () => setState(() => _medications.removeAt(e.key)),
            ),
          ),
        )),
    ],
  );

  // ── Step 5: Health goals ──────────────────────────────────────────────────

  Widget _buildGoals(ColorScheme cs, TextTheme tt) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepHeader(tt, 'Your Health Goals', 'Select all that apply. Then pick your #1 priority — the AI focuses on this first.'),
      const SizedBox(height: 28),
      Text('Select your goals *', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _goals.map((g) => _Chip(
          label: g,
          selected: _selectedGoals.contains(g),
          onTap: () => setState(() => _selectedGoals.contains(g) ? _selectedGoals.remove(g) : _selectedGoals.add(g)),
          cs: cs,
        )).toList(),
      ),
      if (_selectedGoals.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text('Primary focus *', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Which one matters most right now?', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _selectedGoals.map((g) => _Chip(
            label: g,
            selected: _primaryGoal == g,
            onTap: () => setState(() => _primaryGoal = g),
            cs: cs,
            accent: true,
          )).toList(),
        ),
      ],
    ],
  );

  // ── Step 6: Complete ──────────────────────────────────────────────────────

  Widget _buildComplete(ColorScheme cs, TextTheme tt) => Column(
    children: [
      const SizedBox(height: 40),
      CircleAvatar(
        radius: 44,
        backgroundColor: cs.primaryContainer,
        child: Icon(Icons.check_circle_rounded, color: cs.primary, size: 56),
      ),
      const SizedBox(height: 32),
      Text('Profile Complete!', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(
        'MediNova AI has everything it needs to personalise your experience. Your data is encrypted and stored securely.',
        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.6),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      // Summary
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Profile Summary', style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _summaryRow(tt, 'Blood Type', _bloodType ?? '—'),
            _summaryRow(tt, 'Allergies', _selectedAllergies.isEmpty ? 'None' : _selectedAllergies.join(', ')),
            _summaryRow(tt, 'Conditions', _selectedConditions.isEmpty ? 'None' : _selectedConditions.join(', ')),
            _summaryRow(tt, 'Medications', _medications.isEmpty ? 'None' : _medications.join(', ')),
            _summaryRow(tt, 'Primary Goal', _primaryGoal.isEmpty ? '—' : _primaryGoal),
          ],
        ),
      ),
    ],
  );

  Widget _stepHeader(TextTheme tt, String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(subtitle, style: tt.bodyMedium?.copyWith(height: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ],
  );

  Widget _summaryRow(TextTheme tt, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        Expanded(child: Text(value, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  final bool accent;

  const _Chip({required this.label, required this.selected, required this.onTap, required this.cs, this.accent = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? (accent ? cs.primary : cs.primaryContainer) : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? (accent ? cs.primary : cs.primary.withValues(alpha: 0.5)) : cs.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? (accent ? cs.onPrimary : cs.onPrimaryContainer) : cs.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
      ),
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final ColorScheme cs;
  const _InfoBanner({required this.text, required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: cs.tertiaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: cs.onTertiaryContainer, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: cs.onTertiaryContainer, fontSize: 13, height: 1.4))),
      ],
    ),
  );
}
