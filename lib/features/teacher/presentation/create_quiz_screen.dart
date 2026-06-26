import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_repository.dart';
import '../../classroom/data/classroom_repository.dart';
import '../../classroom/domain/classroom_model.dart';
import '../../teacher/data/teacher_repository.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  String? _selectedClassroomId;
  final List<_QuizQuestionEntry> _questions = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _questions.add(_QuizQuestionEntry());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() => _questions.add(_QuizQuestionEntry()));
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassroomId == null) {
      setState(() => _error = 'Please select a classroom');
      return;
    }

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.questionCtrl.text.isEmpty ||
          q.options.any((o) => o.text.isEmpty) ||
          q.correctIndex == null) {
        setState(() => _error = 'Please fill all question fields');
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final questions = _questions
          .map((q) => {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'question': q.questionCtrl.text.trim(),
                'options': q.options.map((o) => o.text.trim()).toList(),
                'correctIndex': q.correctIndex,
                'explanation': q.explanationCtrl.text.trim(),
              })
          .toList();

      await ref.read(teacherRepositoryProvider).createQuiz(
            title: _titleCtrl.text.trim(),
            classroomId: _selectedClassroomId!,
            questions: questions,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz created!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authRepositoryProvider).currentUser;
    final classroomsAsync = user != null
        ? ref.watch(_teacherClassroomsProvider(user.uid))
        : const AsyncValue<List<Classroom>>.data([]);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Quiz')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  hintText: 'e.g. Plastic Pollution Quiz',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Title is required',
              ),
              const SizedBox(height: 16),
              classroomsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (classrooms) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedClassroomId,
                    decoration: const InputDecoration(
                      labelText: 'Assign to Classroom',
                      border: OutlineInputBorder(),
                    ),
                    items: classrooms
                        .map((c) => DropdownMenuItem(
                              value: c.classroomId,
                              child: Text(c.classroomName),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedClassroomId = v),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Questions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...List.generate(_questions.length, (i) {
                return _buildQuestionCard(i);
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _saveQuiz,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = _questions[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Question ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (_questions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeQuestion(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: q.questionCtrl,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            RadioGroup<int>(
              groupValue: q.correctIndex,
              onChanged: (v) => setState(() => q.correctIndex = v),
              child: Column(
                children: List.generate(4, (optIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(value: optIndex),
                        Expanded(
                          child: TextField(
                            controller: q.options[optIndex],
                            decoration: InputDecoration(
                              labelText: 'Option ${optIndex + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: q.explanationCtrl,
              decoration: const InputDecoration(
                labelText: 'Explanation (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestionEntry {
  final questionCtrl = TextEditingController();
  final options = List.generate(4, (_) => TextEditingController());
  final explanationCtrl = TextEditingController();
  int? correctIndex;

  void dispose() {
    questionCtrl.dispose();
    for (final o in options) {
      o.dispose();
    }
    explanationCtrl.dispose();
  }
}

final _teacherClassroomsProvider =
    StreamProvider.family<List<Classroom>, String>((ref, teacherId) {
  return ref
      .watch(classroomRepositoryProvider)
      .watchTeacherClassrooms(teacherId);
});
