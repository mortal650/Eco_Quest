import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/data/user_profile_notifier.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  static const _allBadges = [
    {
      'id': 'first_100_xp',
      'name': 'First Steps',
      'description': 'Earn 100 XP',
      'icon': Icons.star,
      'color': Colors.amber,
      'target': 100,
      'type': 'xp',
    },
    {
      'id': 'eco_warrior',
      'name': 'Eco Warrior',
      'description': 'Earn 500 XP',
      'icon': Icons.shield,
      'color': Colors.green,
      'target': 500,
      'type': 'xp',
    },
    {
      'id': 'green_champion',
      'name': 'Green Champion',
      'description': 'Earn 1000 XP',
      'icon': Icons.emoji_events,
      'color': Colors.teal,
      'target': 1000,
      'type': 'xp',
    },
    {
      'id': 'earth_guardian',
      'name': 'Earth Guardian',
      'description': 'Earn 2000 XP',
      'icon': Icons.public,
      'color': Colors.blue,
      'target': 2000,
      'type': 'xp',
    },
    {
      'id': 'level_3_reached',
      'name': 'Level Up!',
      'description': 'Reach Level 3',
      'icon': Icons.trending_up,
      'color': Colors.purple,
      'target': 3,
      'type': 'level',
    },
    {
      'id': 'level_5_reached',
      'name': 'Halfway There',
      'description': 'Reach Level 5',
      'icon': Icons.workspace_premium,
      'color': Colors.indigo,
      'target': 5,
      'type': 'level',
    },
    {
      'id': 'max_level',
      'name': 'Max Level',
      'description': 'Reach Level 10',
      'icon': Icons.military_tech,
      'color': Colors.deepOrange,
      'target': 10,
      'type': 'level',
    },
    {
      'id': 'streak_3',
      'name': 'On Fire',
      'description': '3-day streak',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
      'target': 3,
      'type': 'streak',
    },
    {
      'id': 'streak_7',
      'name': 'Week Warrior',
      'description': '7-day streak',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
      'target': 7,
      'type': 'streak',
    },
    {
      'id': 'streak_30',
      'name': 'Monthly Master',
      'description': '30-day streak',
      'icon': Icons.local_fire_department,
      'color': Colors.pink,
      'target': 30,
      'type': 'streak',
    },
    {
      'id': 'first_quiz',
      'name': 'Quiz Beginner',
      'description': 'Complete your first quiz',
      'icon': Icons.quiz,
      'color': Colors.cyan,
      'target': 1,
      'type': 'quizzes',
    },
    {
      'id': 'all_modules_completed',
      'name': 'Module Master',
      'description': 'Complete 6 modules',
      'icon': Icons.menu_book,
      'color': Colors.brown,
      'target': 6,
      'type': 'modules',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressOverview(context, profile),
                const SizedBox(height: 24),
                Text(
                  'Badges',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.badges.length} / ${_allBadges.length} earned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                ..._allBadges.map((badge) {
                  final isEarned = profile.badges.contains(badge['id']);
                  return _BadgeCard(
                    badge: badge,
                    isEarned: isEarned,
                    profile: profile,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context, dynamic profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ProgressItem(
                  icon: Icons.star,
                  label: 'XP',
                  value: '${profile.xp}',
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                _ProgressItem(
                  icon: Icons.leaderboard,
                  label: 'Level',
                  value: '${profile.level}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _ProgressItem(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${profile.streak}d',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
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
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.isEarned,
    required this.profile,
  });

  final Map<String, dynamic> badge;
  final bool isEarned;
  final dynamic profile;

  @override
  Widget build(BuildContext context) {
    final color = badge['color'] as Color;
    final icon = badge['icon'] as IconData;
    final target = badge['target'] as int;
    final type = badge['type'] as String;

    double progress = 0;
    switch (type) {
      case 'xp':
        progress = (profile.xp / target).clamp(0.0, 1.0);
        break;
      case 'level':
        progress = (profile.level / target).clamp(0.0, 1.0);
        break;
      case 'streak':
        progress = (profile.streak / target).clamp(0.0, 1.0);
        break;
      case 'quizzes':
        progress = isEarned ? 1.0 : 0.0;
        break;
      case 'modules':
        final completed = (profile.completedLessons as Map?)?.length ?? 0;
        progress = (completed / target).clamp(0.0, 1.0);
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEarned
              ? color.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            icon,
            color: isEarned ? color : Colors.grey,
          ),
        ),
        title: Text(
          badge['name'] as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isEarned ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge['description'] as String,
              style: TextStyle(
                color: isEarned ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                color: isEarned ? color : color.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        trailing: isEarned
            ? Icon(Icons.check_circle, color: color)
            : Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
      ),
    );
  }
}
