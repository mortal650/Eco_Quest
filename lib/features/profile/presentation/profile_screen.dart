import 'package:cloud_firestore/cloud_firestore.dart';
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
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ecoUser) {
          if (ecoUser == null) {
            return const Center(child: Text('Profile not found'));
          }

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
                child: Text(
                  ecoUser.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 24),
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
            ],
          );
        },
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
        return Column(
          children: results.map((doc) {
            final data = doc.data();
            final score = data['score'] ?? 0;
            final total = data['totalQuestions'] ?? 0;
            final xp = data['ecoPointsEarned'] ?? 0;
            final pct = total > 0 ? (100 * score / total).round() : 0;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: pct >= 70
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  child: Text('$pct%'),
                ),
                title: Text('Score: $score / $total'),
                trailing: Text('+$xp XP'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
