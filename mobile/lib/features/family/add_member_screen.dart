import '../../shared/widgets/wise/wise_input.dart';
import '../../shared/widgets/wise/wise_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';



class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _relation;
  static const _relations = ['Spouse', 'Parent', 'Child', 'Sibling', 'Other'];

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Add Family Member'), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          WiseInput(controller: _nameCtrl, hint: 'Full name', label: 'Name',
              prefixIcon: Icons.person_outline),
          const SizedBox(height: 16),
          WiseInput(controller: _emailCtrl, hint: 'Email address', label: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined),
          const SizedBox(height: 20),
          const Text('Relation', style: TextStyle(color: kSecondaryText, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: _relations.map((r) => GestureDetector(
            onTap: () => setState(() => _relation = r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _relation == r ? kPrimaryText : kElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _relation == r ? kPrimaryText : kBorder),
              ),
              child: Text(r, style: TextStyle(color: _relation == r ? kBlack : kSecondaryText, fontWeight: FontWeight.w500)),
            ),
          )).toList()),
          const SizedBox(height: 32),
          WiseButton(label: 'Send Invitation', onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent!'), backgroundColor: kSuccessGreen));
            context.pop();
          }),
        ],
      ),
    );
  }
}
