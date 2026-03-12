import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/ambience.dart';
import '../../../data/models/journal_entry.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/journal_provider.dart';
import '../widgets/mood_selector.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  final Ambience ambience;

  const ReflectionScreen({super.key, required this.ambience});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _journalController = TextEditingController();
  String? _selectedMood;
  bool _isSaving = false;

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _handleClose(context),
        ),
        title: const Text('Reflection'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrompt(),
              const SizedBox(height: 28),
              _buildJournalInput(),
              const SizedBox(height: 28),
              _buildMoodSection(),
              const SizedBox(height: 40),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.self_improvement_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.ambience.title,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '"What is gently present with you right now?"',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalInput() {
    return TextField(
      controller: _journalController,
      maxLines: 8,
      minLines: 5,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        height: 1.6,
      ),
      decoration: const InputDecoration(
        hintText: 'Let your thoughts flow freely…',
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOW DO YOU FEEL?',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        MoodSelector(
          selectedMood: _selectedMood,
          onMoodSelected: (mood) => setState(() => _selectedMood = mood),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSaving ? null : () => _saveReflection(context),
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.background,
              ),
            )
          : const Text('Save Reflection'),
    );
  }

  Future<void> _saveReflection(BuildContext context) async {
    final text = _journalController.text.trim();
    final mood = _selectedMood;

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before saving.'),
          backgroundColor: AppColors.surfaceCard,
        ),
      );
      return;
    }

    if (mood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood.'),
          backgroundColor: AppColors.surfaceCard,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ambienceId: widget.ambience.id,
      ambienceTitle: widget.ambience.title,
      mood: mood,
      text: text,
      createdAt: DateTime.now(),
    );

    await ref.read(journalProvider.notifier).addEntry(entry);
    HapticFeedback.mediumImpact();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/history',
        (route) => route.settings.name == '/',
      );
    }
  }

  void _handleClose(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }
}
