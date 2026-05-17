import '../../shared/widgets/wise/wise_button.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';



class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  bool _annual = true;
  int _selected = 1;

  static const _plans = [
    _Plan('Free', 0, 0, ['AI Chatbot (10/day)', 'Prescription Scanner', 'Basic Health Tracking', '1 Family Member'], false),
    _Plan('Pro', 9.99, 99.99, ['Unlimited AI Chatbot', 'Advanced Scanner', 'Full Health Tracking', '5 Family Members', 'Telemedicine (2/mo)', 'Priority Support'], true),
    _Plan('Family', 19.99, 199.99, ['Everything in Pro', 'Unlimited Family Members', 'Unlimited Telemedicine', 'Wearable Sync', 'Emergency SOS', 'Dedicated Support'], false),
    _Plan('Enterprise', 49.99, 499.99, ['Everything in Family', 'Custom AI Models', 'EHR Integration', 'HIPAA Compliance', 'Admin Dashboard', 'SLA Guarantee'], false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Choose Plan'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Upgrade your healthcare', style: TextStyle(color: kPrimaryText, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('AI-powered health management for you and your family', style: TextStyle(color: kSecondaryText, fontSize: 14)),
          const SizedBox(height: 24),
          // Billing toggle
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: kElevated, borderRadius: BorderRadius.circular(30)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _ToggleChip('Monthly', !_annual, () => setState(() => _annual = false)),
                _ToggleChip('Annual  -20%', _annual, () => setState(() => _annual = true)),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          ..._plans.asMap().entries.map((e) => _PlanCard(
            plan: e.value,
            annual: _annual,
            selected: _selected == e.key,
            onSelect: () => setState(() => _selected = e.key),
          )),
          const SizedBox(height: 24),
          WiseButton(
            label: _selected == 0 ? 'Continue with Free' : 'Start 7-Day Free Trial',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Redirecting to payment...'), backgroundColor: kSuccessGreen),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Cancel anytime. No hidden fees.', style: TextStyle(color: kTertiaryText, fontSize: 12))),
        ],
      ),
    );
  }
}

Widget _ToggleChip(String label, bool active, VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color: active ? kPrimaryText : Colors.transparent,
      borderRadius: BorderRadius.circular(26),
    ),
    child: Text(label, style: TextStyle(color: active ? kBlack : kSecondaryText, fontSize: 13, fontWeight: FontWeight.w600)),
  ),
);

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool annual, selected;
  final VoidCallback onSelect;
  const _PlanCard({required this.plan, required this.annual, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final price = annual ? plan.annualPrice / 12 : plan.monthlyPrice;
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? kElevated : kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? kPrimaryText : kBorder, width: selected ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(plan.name, style: TextStyle(color: kPrimaryText, fontSize: 16,
                fontWeight: plan.popular ? FontWeight.w800 : FontWeight.w600)),
            if (plan.popular) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: kPrimaryText, borderRadius: BorderRadius.circular(12)),
                child: const Text('POPULAR', style: TextStyle(color: kPrimaryText, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ],
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(plan.monthlyPrice == 0 ? 'Free' : '\$${price.toStringAsFixed(2)}/mo',
                  style: const TextStyle(color: kPrimaryText, fontSize: 18, fontWeight: FontWeight.w700)),
              if (annual && plan.annualPrice > 0)
                Text('\$${plan.annualPrice}/yr', style: const TextStyle(color: kSecondaryText, fontSize: 11)),
            ]),
          ]),
          const SizedBox(height: 14),
          ...plan.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: kSuccessGreen, size: 16),
              const SizedBox(width: 8),
              Text(f, style: const TextStyle(color: kSecondaryText, fontSize: 13)),
            ]),
          )),
          if (selected) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.radio_button_checked, color: kPrimaryText, size: 18),
              const SizedBox(width: 6),
              const Text('Selected', style: TextStyle(color: kPrimaryText, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _Plan {
  final String name;
  final double monthlyPrice, annualPrice;
  final List<String> features;
  final bool popular;
  const _Plan(this.name, this.monthlyPrice, this.annualPrice, this.features, this.popular);
}
