import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../classroom/data/classroom_repository.dart';
import '../../classroom/domain/classroom_model.dart';

class ClassroomDetailScreen extends ConsumerWidget {
  const ClassroomDetailScreen({required this.classroomId, super.key});
  final String classroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync =
        ref.watch(classroomMembersProvider(classroomId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom'),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (members) {
          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('No students joined yet'),
                  const SizedBox(height: 8),
                  const Text('Share the classroom code with your students'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      member.studentName.isNotEmpty
                          ? member.studentName[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(member.studentName),
                  subtitle: Text(
                    'Joined ${_formatDate(member.joinedAt)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove Student'),
                          content: Text(
                            'Remove ${member.studentName} from this classroom?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Remove',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref
                            .read(classroomRepositoryProvider)
                            .removeStudent(classroomId, member.studentId);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

final classroomMembersProvider =
    StreamProvider.family<List<ClassroomMember>, String>((ref, classroomId) {
  return ref
      .watch(classroomRepositoryProvider)
      .watchClassroomMembers(classroomId);
});
