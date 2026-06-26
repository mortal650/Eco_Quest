import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_repository.dart';
import '../../classroom/data/classroom_repository.dart';
import '../../classroom/domain/classroom_model.dart';
import '../../profile/data/user_profile_notifier.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const SizedBox.shrink();

    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: profileAsync.when(
              loading: () => const Chip(label: Text('...')),
              error: (_, __) => const Chip(label: Text('0')),
              data: (profile) => Chip(
                avatar: const Icon(Icons.eco, color: Colors.green),
                label: Text('${profile?.xp ?? 0} XP'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileAsync.when(
              loading: () => const Text('Welcome back!'),
              error: (_, __) => const Text('Welcome back!'),
              data: (profile) => Text(
                'Welcome, ${profile?.displayName ?? 'Teacher'}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            Text(
              'Your Classrooms',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildClassroomsList(context, user.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_home_work_outlined,
                    label: 'Create\nClassroom',
                    onTap: () => context.push('/teacher/create-classroom'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.quiz_outlined,
                    label: 'Create\nQuiz',
                    onTap: () => context.push('/teacher/create-quiz'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.emoji_events_outlined,
                    label: 'Create\nChallenge',
                    onTap: () => context.push('/teacher/create-challenge'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassroomsList(BuildContext context, String teacherId) {
    final classroomsAsync =
        ref.watch(teacherClassroomsProvider(teacherId));

    return classroomsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (classrooms) {
        if (classrooms.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.class_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    const Text('No classrooms yet'),
                    const SizedBox(height: 8),
                    const Text('Create your first classroom to get started'),
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
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.class_),
                ),
                title: Text(classroom.classroomName),
                subtitle: Text(
                  'Code: ${classroom.classroomCode} | ${classroom.studentCount} students',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(
                  '/teacher/classroom/${classroom.classroomId}',
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

final teacherClassroomsProvider =
    StreamProvider.family<List<Classroom>, String>((ref, teacherId) {
  return ref
      .watch(classroomRepositoryProvider)
      .watchTeacherClassrooms(teacherId);
});

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
