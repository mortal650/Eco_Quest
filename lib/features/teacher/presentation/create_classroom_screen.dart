import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_repository.dart';
import '../../classroom/data/classroom_repository.dart';

class CreateClassroomScreen extends ConsumerStatefulWidget {
  const CreateClassroomScreen({super.key});

  @override
  ConsumerState<CreateClassroomScreen> createState() =>
      _CreateClassroomScreenState();
}

class _CreateClassroomScreenState extends ConsumerState<CreateClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _createdCode;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createClassroom() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('Not logged in');

      final code = await ref.read(classroomRepositoryProvider).createClassroom(
            classroomName: _nameCtrl.text.trim(),
            teacherId: user.uid,
            teacherName: user.displayName ?? 'Teacher',
          );

      setState(() => _createdCode = code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Classroom')),
      body: _createdCode != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 72,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Classroom Created!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Share this code with your students:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _createdCode!,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_home_work_outlined,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Classroom Name',
                          hintText: 'e.g. Environmental Science A',
                          prefixIcon: Icon(Icons.class_),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v != null && v.isNotEmpty
                            ? null
                            : 'Classroom name is required',
                      ),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _error!,
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _loading ? null : _createClassroom,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Create Classroom'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
