import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_repository.dart';
import '../../classroom/data/classroom_repository.dart';
import '../../classroom/domain/classroom_model.dart';
import '../../teacher/data/teacher_repository.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() =>
      _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _xpCtrl = TextEditingController(text: '50');
  String? _selectedType;
  String? _selectedClassroomId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _loading = false;
  String? _error;

  static const _challengeTypes = [
    {'type': 'recycling', 'icon': Icons.recycling, 'label': 'Recycling'},
    {'type': 'tree_plantation', 'icon': Icons.forest, 'label': 'Tree Plantation'},
    {'type': 'water_conservation', 'icon': Icons.water_drop, 'label': 'Water Conservation'},
    {'type': 'energy_saving', 'icon': Icons.bolt, 'label': 'Energy Saving'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _saveChallenge() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      setState(() => _error = 'Please select a challenge type');
      return;
    }
    if (_selectedClassroomId == null) {
      setState(() => _error = 'Please select a classroom');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(teacherRepositoryProvider).createChallenge(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            type: _selectedType!,
            xpReward: int.tryParse(_xpCtrl.text) ?? 50,
            dueDate: _dueDate,
            classroomId: _selectedClassroomId!,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge created!'),
            backgroundColor: Colors.green,
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final classroomsAsync = user != null
        ? ref.watch(_teacherClassroomsProvider(user.uid))
        : const AsyncValue<List<Classroom>>.data([]);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Challenge')),
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
                  labelText: 'Challenge Title',
                  hintText: 'e.g. Recycling Week Challenge',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Title is required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what students need to do...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v != null && v.isNotEmpty ? null : 'Description is required',
              ),
              const SizedBox(height: 16),
              Text(
                'Challenge Type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _challengeTypes.map((ct) {
                  final isSelected = _selectedType == ct['type'];
                  return ChoiceChip(
                    label: Text(ct['label'] as String),
                    avatar: Icon(ct['icon'] as IconData, size: 18),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedType = ct['type'] as String),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _xpCtrl,
                      decoration: const InputDecoration(
                        labelText: 'XP Reward',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'Due: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      ),
                    ),
                  ),
                ],
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
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: TextStyle(color: colorScheme.error)),
                ),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _saveChallenge,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Challenge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _teacherClassroomsProvider =
    StreamProvider.family<List<Classroom>, String>((ref, teacherId) {
  return ref
      .watch(classroomRepositoryProvider)
      .watchTeacherClassrooms(teacherId);
});
