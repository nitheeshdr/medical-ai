import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/route_names.dart';


class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  static const _members = [
    _Member('Sarah Johnson', 'Spouse', 38, 85),
    _Member('Emma Johnson', 'Daughter', 12, 92),
    _Member('Robert Johnson', 'Father', 68, 71),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Family Healthcare'), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(RouteNames.addFamilyMember),
        backgroundColor: kPrimaryText, foregroundColor: kBlack,
        icon: const Icon(Icons.person_add_rounded), label: const Text('Add Member'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Family Members', style: TextStyle(color: kPrimaryText, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ..._members.map((m) => _MemberCard(member: m)),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final _Member member;
  const _MemberCard({required this.member});

  Color get _scoreColor => member.score >= 80 ? kSuccessGreen : member.score >= 60 ? kWarningOrange : kErrorRed;

  @override
  Widget build(BuildContext context) {
    return WiseCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        CircleAvatar(backgroundColor: kBorder, radius: 24,
            child: Text(member.name[0], style: const TextStyle(color: kPrimaryText, fontSize: 20, fontWeight: FontWeight.w700))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(member.name, style: const TextStyle(color: kPrimaryText, fontSize: 15, fontWeight: FontWeight.w600)),
          Text('${member.relation} • ${member.age} years old', style: const TextStyle(color: kSecondaryText, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${member.score}', style: TextStyle(color: _scoreColor, fontSize: 22, fontWeight: FontWeight.w700)),
          const Text('Health Score', style: TextStyle(color: kSecondaryText, fontSize: 10)),
        ]),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right_rounded, color: kSecondaryText),
      ]),
    );
  }
}

class _Member {
  final String name, relation;
  final int age, score;
  const _Member(this.name, this.relation, this.age, this.score);
}
