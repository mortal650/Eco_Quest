import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_repository.dart';
import '../data/user_profile_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ecoUser) {
          if (ecoUser == null) {
            return const Center(child: Text('Profile not found'));
          }

          final isTeacher = ecoUser.role == 'teacher';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  child: Text(
                    ecoUser.displayName.isNotEmpty
                        ? ecoUser.displayName[0].toUpperCase()
                        : '?',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  ecoUser.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTeacher
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isTeacher ? 'Teacher' : 'Student',
                    style: TextStyle(
                      color: isTeacher ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  ecoUser.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              if (ecoUser.schoolName.isNotEmpty || ecoUser.institutionName.isNotEmpty)
                _ProfileField(
                  icon: isTeacher ? Icons.account_balance : Icons.school,
                  label: isTeacher ? 'Institution' : 'School/College',
                  value: isTeacher ? ecoUser.institutionName : ecoUser.schoolName,
                ),
              if (ecoUser.city.isNotEmpty)
                _ProfileField(
                  icon: Icons.location_city,
                  label: 'City',
                  value: ecoUser.city,
                ),
              if (ecoUser.state.isNotEmpty)
                _ProfileField(
                  icon: Icons.map_outlined,
                  label: 'State',
                  value: ecoUser.state,
                ),
              if (!isTeacher && ecoUser.grade.isNotEmpty)
                _ProfileField(
                  icon: Icons.grade,
                  label: 'Grade / Year',
                  value: ecoUser.grade,
                ),
              if (isTeacher && ecoUser.subject.isNotEmpty)
                _ProfileField(
                  icon: Icons.subject,
                  label: 'Subject',
                  value: ecoUser.subject,
                ),
              if (isTeacher && ecoUser.experience.isNotEmpty)
                _ProfileField(
                  icon: Icons.work_history,
                  label: 'Experience',
                  value: ecoUser.experience,
                ),
              const SizedBox(height: 16),
              _StatTile(
                  icon: Icons.star_outline,
                  label: 'XP',
                  value: ecoUser.xp.toString()),
              _StatTile(
                  icon: Icons.leaderboard_outlined,
                  label: 'Level',
                  value: ecoUser.level.toString()),
              _StatTile(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Streak',
                  value: '${ecoUser.streak} days'),
              _StatTile(
                  icon: Icons.emoji_events_outlined,
                  label: 'Badges',
                  value: ecoUser.badges.length.toString()),
              const SizedBox(height: 24),
              if (ecoUser.badges.isNotEmpty) ...[
                Text(
                  'Badges Earned',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ecoUser.badges.map((b) {
                    return Chip(
                      avatar: const Icon(Icons.emoji_events, size: 18),
                      label: Text(b.replaceAll('_', ' ')),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                'Quiz History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _QuizHistory(uid: user.uid),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showDeleteAccountDialog(context, ref),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Delete Account',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        title: const Text('Delete Account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will permanently delete your account and all data. '
              'You can then re-register with the same email.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm with password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.dispose();
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text.trim();
              if (password.isEmpty) return;

              final repo = ref.read(authRepositoryProvider);
              final user = repo.currentUser;
              if (user == null) return;

              try {
                // Re-authenticate before deleting
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: password,
                );
                await user.reauthenticateWithCredential(credential);

                // Delete account
                await repo.deleteAccount();

                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) context.go('/login');
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing:
            Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _QuizHistory extends StatelessWidget {
  const _QuizHistory({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_results')
          .orderBy('completedAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No quizzes taken yet'),
            ),
          );
        }
        final results = snap.data!.docs;

        int totalCorrect = 0;
        int totalQuestions = 0;
        int totalXp = 0;
        for (final doc in results) {
          final data = doc.data();
          totalCorrect += (data['score'] ?? 0) as int;
          totalQuestions += (data['totalQuestions'] ?? 0) as int;
          totalXp += (data['ecoPointsEarned'] ?? 0) as int;
        }
        final avgPct = totalQuestions > 0
            ? (100 * totalCorrect / totalQuestions).round()
            : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuizStatItem(
                      label: 'Quizzes',
                      value: '${results.length}',
                      icon: Icons.quiz,
                    ),
                    _QuizStatItem(
                      label: 'Avg Score',
                      value: '$avgPct%',
                      icon: Icons.trending_up,
                    ),
                    _QuizStatItem(
                      label: 'Total XP',
                      value: '+$totalXp',
                      icon: Icons.star,
                    ),
                  ],
                ),
              ),
            ),
            ...results.map((doc) {
              final data = doc.data();
              final score = data['score'] ?? 0;
              final total = data['totalQuestions'] ?? 0;
              final xp = data['ecoPointsEarned'] ?? 0;
              final pct = total > 0 ? (100 * score / total).round() : 0;
              final moduleTitle =
                  (data['moduleTitle'] as String?) ?? 'Module Quiz';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: pct >= 70
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Text('$pct%'),
                  ),
                  title: Text(moduleTitle),
                  subtitle: Text('Score: $score / $total'),
                  trailing: Text('+$xp XP'),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _QuizStatItem extends StatelessWidget {
  const _QuizStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
