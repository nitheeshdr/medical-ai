import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class JournalEntryScreen extends StatefulWidget {
  final String? entryId;
  const JournalEntryScreen({super.key, this.entryId});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _selectedMood = '😊';

  static const _moods = ['😊', '😐', '😟', '💪', '😴', '🤒'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(widget.entryId == null ? 'New Entry' : 'Edit Entry'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save', style: TextStyle(color: kPrimaryText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('How are you feeling?', style: TextStyle(color: kSecondaryText, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _moods.map((m) => GestureDetector(
              onTap: () => setState(() => _selectedMood = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedMood == m ? kElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedMood == m ? kPrimaryText : Colors.transparent),
                ),
                child: Text(m, style: const TextStyle(fontSize: 28)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: kPrimaryText, fontSize: 18, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Entry title...',
              hintStyle: TextStyle(color: kTertiaryText),
              border: InputBorder.none,
            ),
          ),
          const Divider(color: kBorder),
          const SizedBox(height: 8),
          TextField(
            controller: _bodyCtrl,
            style: const TextStyle(color: kSecondaryText, fontSize: 14, height: 1.6),
            maxLines: 14,
            decoration: const InputDecoration(
              hintText: 'Write about your health today...',
              hintStyle: TextStyle(color: kTertiaryText),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Tags', style: TextStyle(color: kSecondaryText, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['Good Sleep', 'Headache', 'Exercise', 'Stress', 'Medication', 'Rested'].map((tag) =>
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text(tag, style: const TextStyle(color: kSecondaryText, fontSize: 12)),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}
