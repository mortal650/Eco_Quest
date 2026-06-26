import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_repository.dart';
import '../../classroom/data/classroom_repository.dart';
import '../../classroom/domain/classroom_model.dart';

class StudentClassroomsScreen extends ConsumerStatefulWidget {
  const StudentClassroomsScreen({super.key});

  @override
  ConsumerState<StudentClassroomsScreen> createState() =>
      _StudentClassroomsScreenState();
}

class _StudentClassroomsScreenState extends ConsumerState<StudentClassroomsScreen> {
  final _joinCodeCtrl = TextEditingController();
  bool _joining = false;

  @override
  void dispose() {
    _joinCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinClassroom() async {
    final code = _joinCodeCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() => _joining = true);

    try {
      final classroom =
          await ref.read(classroomRepositoryProvider).joinClassroom(code);

      if (mounted) {
        if (classroom != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined ${classroom.classroomName}!'),
              backgroundColor: Colors.green,
            ),
          );
          _joinCodeCtrl.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid classroom code'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const SizedBox.shrink();

    final classroomsAsync = ref.watch(studentClassroomsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classrooms'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Classrooms are optional. Join a classroom to access teacher-assigned quizzes and challenges.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Join a Classroom',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _joinCodeCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Enter 6-character code',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 6,
                            onSubmitted: (_) => _joinClassroom(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _joining ? null : _joinClassroom,
                          child: _joining
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Join'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Classrooms',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            classroomsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (classrooms) {
                if (classrooms.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.class_outlined,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(height: 12),
                            const Text('No classrooms joined yet'),
                            const SizedBox(height: 4),
                            Text(
                              'Enter a code above to join your teacher\'s classroom',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: classrooms.map((classroom) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: const Icon(Icons.class_),
                        ),
                        title: Text(classroom.classroomName),
                        subtitle: Text(
                          'By ${classroom.teacherName} | Code: ${classroom.classroomCode}',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final studentClassroomsProvider =
    StreamProvider.family<List<Classroom>, String>((ref, studentId) {
  return ref
      .watch(classroomRepositoryProvider)
      .watchStudentClassrooms(studentId);
});
