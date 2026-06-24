import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_repository.dart';
import '../../profile/data/user_profile_notifier.dart';
import '../../../services/daily_challenge_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? _challenge;
  bool _challengeLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
    _initStreak();
  }

  Future<void> _initStreak() async {
    await ref.read(userProfileProvider.notifier).incrementStreak();
  }

  Future<void> _loadChallenge() async {
    final challenge =
        await ref.read(dailyChallengeServiceProvider).getTodayChallenge();
    if (mounted) setState(() { _challenge = challenge; _challengeLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const SizedBox.shrink();

    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoQuest'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: profileAsync.when(
              loading: () => const Chip(label: Text('...')),
              error: (_, __) => const Chip(label: Text('0')),
              data: (profile) => Chip(
                avatar: const Icon(Icons.eco, color: Colors.green),
                label: Text('${profile?.xp ?? 0}'),
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
                'Welcome back, ${profile?.displayName ?? 'Explorer'}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            _buildDailyChallenge(context),
            const SizedBox(height: 24),
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildProgressStats(context, profileAsync),
            const SizedBox(height: 24),
            Text(
              'AI Eco Mentor',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildAIMentorCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallenge(BuildContext context) {
    if (_challengeLoading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(strokeWidth: 2),
          title: Text('Loading challenge...'),
        ),
      );
    }
    final completed = _challenge?['completed'] ?? false;
    return Card(
      color: completed
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        title: const Text('Daily Challenge'),
        subtitle: Text(_challenge?['challenge'] ?? 'Check back tomorrow!'),
        trailing: Icon(
          completed ? Icons.check_circle : Icons.check_circle_outline,
          color: completed ? Colors.green : null,
        ),
        onTap: completed
            ? null
            : () async {
                await ref.read(dailyChallengeServiceProvider).completeChallenge();
                await _loadChallenge();
              },
      ),
    );
  }

  Widget _buildProgressStats(BuildContext context, AsyncValue<dynamic> profileAsync) {
    return profileAsync.when(
      loading: () => const Row(
        children: [
          Expanded(child: _StatCard(icon: Icons.star, label: 'XP', value: '...')),
          SizedBox(width: 8),
          Expanded(child: _StatCard(icon: Icons.leaderboard, label: 'Level', value: '...')),
          SizedBox(width: 8),
          Expanded(child: _StatCard(icon: Icons.local_fire_department, label: 'Streak', value: '...')),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return Row(
          children: [
            _StatCard(icon: Icons.star, label: 'XP', value: '${profile.xp}'),
            const SizedBox(width: 8),
            _StatCard(icon: Icons.leaderboard, label: 'Level', value: '${profile.level}'),
            const SizedBox(width: 8),
            _StatCard(
                icon: Icons.local_fire_department, label: 'Streak', value: '${profile.streak}'),
          ],
        );
      },
    );
  }

  Widget _buildAIMentorCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.smart_toy)),
        title: const Text('Ask your Eco Mentor'),
        subtitle: const Text('Get advice on sustainable living'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push('/mentor'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
