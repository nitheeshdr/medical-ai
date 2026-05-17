import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // User-entered values (null = not yet logged today)
  int? _waterGlasses;
  double? _sleepHours;
  String? _heartRate;
  String? _bloodPressure;
  String? _temperature;
  String? _spo2;
  int? _steps;
  int _stepGoal = 10000;

  // Water daily goal
  int _waterGoal = 8;

  // Editing state
  bool _editingSteps = false;
  bool _editingGoal  = false;
  final _hrCtrl   = TextEditingController();
  final _bpCtrl   = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _goalCtrl  = TextEditingController();

  @override
  void dispose() {
    _hrCtrl.dispose(); _bpCtrl.dispose(); _tempCtrl.dispose();
    _spo2Ctrl.dispose(); _stepsCtrl.dispose(); _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildWaterCard(cs, tt),
          const SizedBox(height: 14),
          _buildSleepCard(cs, tt),
          const SizedBox(height: 14),
          _buildVitalsGrid(cs, tt),
          const SizedBox(height: 14),
          _buildStepsCard(cs, tt),
        ],
      ),
    );
  }

  // ── Water tracker ─────────────────────────────────────────────────────────

  Widget _buildWaterCard(ColorScheme cs, TextTheme tt) => Card.outlined(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.water_drop_rounded, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          Text('Water Intake', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const Spacer(),
          Text('${_waterGlasses ?? 0} / $_waterGoal glasses',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        ]),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_waterGoal, (i) => GestureDetector(
            onTap: () => setState(() => _waterGlasses = i + 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 28, height: 40,
              decoration: BoxDecoration(
                color: (_waterGlasses != null && i < _waterGlasses!)
                    ? cs.primary
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.local_drink_rounded,
                color: (_waterGlasses != null && i < _waterGlasses!) ? cs.onPrimary : cs.onSurfaceVariant,
                size: 16,
              ),
            ),
          )),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_waterGlasses ?? 0) / _waterGoal,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(cs.primary),
          ),
        ),
        if (_waterGlasses == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Tap a glass to log today\'s intake',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ),
      ]),
    ),
  );

  // ── Sleep tracker ─────────────────────────────────────────────────────────

  Widget _buildSleepCard(ColorScheme cs, TextTheme tt) => Card.outlined(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.bedtime_rounded, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          Text('Sleep', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const Spacer(),
          if (_sleepHours != null)
            Text('${_sleepHours!.toStringAsFixed(1)}h',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))
          else
            Text('Not logged', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        Slider(
          value: _sleepHours ?? 0,
          min: 0, max: 12, divisions: 24,
          onChanged: (v) => setState(() => _sleepHours = (v * 2).round() / 2),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('0h', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          if (_sleepHours != null)
            Text(
              _sleepHours! >= 7 && _sleepHours! <= 9 ? '✓ Good amount' : _sleepHours! < 7 ? 'Below recommended' : 'Above recommended',
              style: TextStyle(
                color: _sleepHours! >= 7 && _sleepHours! <= 9 ? cs.primary : cs.error,
                fontSize: 12, fontWeight: FontWeight.w500,
              ),
            )
          else
            Text('Drag to log sleep', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          Text('12h', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
        ]),
      ]),
    ),
  );

  // ── Vitals grid ───────────────────────────────────────────────────────────

  Widget _buildVitalsGrid(ColorScheme cs, TextTheme tt) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2,
    children: [
      _vitalCard(
        cs: cs, tt: tt,
        icon: Icons.favorite_rounded,
        label: 'Heart Rate', unit: 'bpm',
        value: _heartRate, ctrl: _hrCtrl,
        color: cs.error,
        hint: 'e.g. 72',
        onSave: (v) => setState(() => _heartRate = v),
      ),
      _vitalCard(
        cs: cs, tt: tt,
        icon: Icons.bloodtype_rounded,
        label: 'Blood Pressure', unit: 'mmHg',
        value: _bloodPressure, ctrl: _bpCtrl,
        color: cs.primary,
        hint: 'e.g. 120/80',
        onSave: (v) => setState(() => _bloodPressure = v),
      ),
      _vitalCard(
        cs: cs, tt: tt,
        icon: Icons.thermostat_rounded,
        label: 'Temperature', unit: '°F',
        value: _temperature, ctrl: _tempCtrl,
        color: cs.tertiary,
        hint: 'e.g. 98.6',
        onSave: (v) => setState(() => _temperature = v),
      ),
      _vitalCard(
        cs: cs, tt: tt,
        icon: Icons.air_rounded,
        label: 'SpO2', unit: '%',
        value: _spo2, ctrl: _spo2Ctrl,
        color: cs.secondary,
        hint: 'e.g. 98',
        onSave: (v) => setState(() => _spo2 = v),
      ),
    ],
  );

  Widget _vitalCard({
    required ColorScheme cs, required TextTheme tt,
    required IconData icon, required String label, required String unit,
    required String? value, required TextEditingController ctrl,
    required Color color, required String hint,
    required void Function(String) onSave,
  }) => GestureDetector(
    onTap: () => _showVitalDialog(label: label, unit: unit, ctrl: ctrl, hint: hint, onSave: onSave),
    child: Card.outlined(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: value != null ? color : cs.onSurfaceVariant, size: 22),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          const SizedBox(height: 2),
          value != null
              ? Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(width: 3),
            Text(unit, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          ])
              : Text('Tap to log', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic)),
        ]),
      ),
    ),
  );

  void _showVitalDialog({
    required String label, required String unit,
    required TextEditingController ctrl, required String hint,
    required void Function(String) onSave,
  }) {
    ctrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log $label'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isNotEmpty) onSave(v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Steps card ────────────────────────────────────────────────────────────

  Widget _buildStepsCard(ColorScheme cs, TextTheme tt) => Card.outlined(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.directions_walk_rounded, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          Text('Steps Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() { _editingGoal = true; _goalCtrl.text = _stepGoal.toString(); }),
            child: Text('Goal: $_stepGoal', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ),
        ]),
        const SizedBox(height: 8),
        if (_steps != null) ...[
          Text('${_steps!.toLocaleString()}', style: TextStyle(color: cs.onSurface, fontSize: 36, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${((_steps! / _stepGoal) * 100).toStringAsFixed(0)}% of daily goal',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_steps! / _stepGoal).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
        ] else
          Column(children: [
            Icon(Icons.directions_walk_outlined, color: cs.onSurfaceVariant, size: 36),
            const SizedBox(height: 6),
            Text('No steps logged today', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: Text(_steps == null ? 'Log Steps' : 'Update Steps'),
            onPressed: () {
              _stepsCtrl.text = _steps?.toString() ?? '';
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log Steps'),
                  content: TextField(
                    controller: _stepsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 7500',
                      suffixText: 'steps',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () {
                        final v = int.tryParse(_stepsCtrl.text.trim());
                        if (v != null) setState(() => _steps = v);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
      ]),
    ),
  );
}

extension on int {
  String toLocaleString() {
    final s = toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return result.toString();
  }
}
