import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

import 'journal_entry_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _entries = [
    _Entry('Feeling better today', 'Had a good night\'s sleep and energy levels are high. Took all medications on time.', '😊', 'May 15', ['Good Sleep', 'Energetic']),
    _Entry('Mild headache', 'Woke up with a headache. Drank extra water and rested. It subsided by afternoon.', '😐', 'May 14', ['Headache', 'Rested']),
    _Entry('Great workout', 'Completed 45-min cardio session. Heart rate stayed in target zone. Feeling accomplished!', '💪', 'May 13', ['Exercise', 'Motivated']),
    _Entry('Stressful day', 'Work was overwhelming. Noticed elevated BP reading in the evening. Need to manage stress better.', '😟', 'May 12', ['Stress', 'High BP']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Health Journal'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showNewEntry(context),
        backgroundColor: kPrimaryText,
        foregroundColor: kBlack,
        child: const Icon(Icons.edit_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mood summary
          WiseCard(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('This Week', style: TextStyle(color: kSecondaryText, fontSize: 13)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _MoodDot('Mon', '😊'), _MoodDot('Tue', '😐'), _MoodDot('Wed', '💪'),
                _MoodDot('Thu', '😟'), _MoodDot('Fri', '😊'), _MoodDot('Sat', '😴'),
                _MoodDot('Sun', ''),
              ]),
            ]),
          ),
          const Text('Recent Entries', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ..._entries.map((e) => _EntryCard(entry: e)),
        ],
      ),
    );
  }

  void _showNewEntry(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const JournalEntryScreen()),
  ).then((_) => setState(() {}));
}

Widget _MoodDot(String day, String emoji) => Column(children: [
  Text(emoji.isEmpty ? '○' : emoji, style: const TextStyle(fontSize: 20)),
  const SizedBox(height: 4),
  Text(day, style: const TextStyle(color: kTertiaryText, fontSize: 10)),
]);

class _EntryCard extends StatelessWidget {
  final _Entry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) => WiseCard(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(entry.mood, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(child: Text(entry.title, style: const TextStyle(color: kPrimaryText, fontSize: 15, fontWeight: FontWeight.w600))),
        Text(entry.date, style: const TextStyle(color: kTertiaryText, fontSize: 12)),
      ]),
      const SizedBox(height: 8),
      Text(entry.body, style: const TextStyle(color: kSecondaryText, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 10),
      Wrap(spacing: 6, children: entry.tags.map((t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: kElevated, borderRadius: BorderRadius.circular(12)),
        child: Text(t, style: const TextStyle(color: kSecondaryText, fontSize: 11)),
      )).toList()),
    ]),
  );
}

class _Entry {
  final String title, body, mood, date;
  final List<String> tags;
  const _Entry(this.title, this.body, this.mood, this.date, this.tags);
}

