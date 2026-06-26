import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../profile/data/user_profile_notifier.dart';
import '../../../services/daily_challenge_service.dart';
import '../../modules/data/modules_repository.dart';
import '../../modules/domain/module_model.dart';

const _iconMap = <String, IconData>{
  'biotech': Icons.biotech,
  'water_drop': Icons.water_drop,
  'bolt': Icons.bolt,
  'agriculture': Icons.agriculture,
  'thermostat': Icons.thermostat,
  'science': Icons.science,
  'recycling': Icons.recycling,
  'eco': Icons.eco,
  'spa': Icons.spa,
};

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
    try {
      if (mounted) {
        await ref.read(userProfileProvider.notifier).incrementStreak();
      }
    } catch (_) {
      // Silently handle - streak update is non-critical
    }
  }

  Future<void> _loadChallenge() async {
    try {
      final challenge =
          await ref.read(dailyChallengeServiceProvider).getTodayChallenge();
      if (mounted) setState(() { _challenge = challenge; _challengeLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _challengeLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final modulesAsync = ref.watch(modulesStreamProvider);

    return authAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      ),
      error: (e, __) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Something went wrong: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(authStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Please sign in'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          );
        }

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
                    'Welcome back, ${profile?.displayName ?? 'Explorer'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDailyChallenge(context),
                const SizedBox(height: 16),
                _buildContinueLearning(context, profileAsync, modulesAsync),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                Text(
                  'Interactive Simulations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn by doing with hands-on activities',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                _buildSimulationsPreview(context),
                const SizedBox(height: 24),
                Text(
                  'Featured Topic',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _buildFeaturedTopic(context, modulesAsync),
                const SizedBox(height: 24),
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _buildProgressStats(context, profileAsync),
                const SizedBox(height: 24),
                _buildBadgesPreview(context, profileAsync),
                const SizedBox(height: 24),
                _buildLeaderboardPreview(context),
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
      },
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

  Widget _buildContinueLearning(
    BuildContext context,
    AsyncValue<EcoUser?> profileAsync,
    AsyncValue<List<EcoModule>> modulesAsync,
  ) {
    return profileAsync.when(
      loading: () => const Card(
        child: ListTile(
          leading: CircularProgressIndicator(strokeWidth: 2),
          title: Text('Loading your progress...'),
        ),
      ),
      error: (_, __) => const Card(
        child: ListTile(
          leading: Icon(Icons.error_outline),
          title: Text('Could not load progress'),
        ),
      ),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final completedModules = profile.completedLessons.keys.toList();

        return modulesAsync.when(
          loading: () => const Card(
            child: ListTile(
              leading: CircularProgressIndicator(strokeWidth: 2),
              title: Text('Loading modules...'),
            ),
          ),
          error: (_, __) => const Card(
            child: ListTile(
              leading: Icon(Icons.error_outline),
              title: Text('Could not load modules'),
            ),
          ),
          data: (modules) {
            EcoModule? nextModule;
            for (final module in modules) {
              if (!completedModules.contains(module.id)) {
                nextModule = module;
                break;
              }
            }

            if (nextModule == null && modules.isNotEmpty) {
              nextModule = modules.last;
            }

            if (nextModule == null) return const SizedBox.shrink();

            final completed = completedModules.contains(nextModule.id);

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: completed
                      ? Colors.green.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    completed ? Icons.check : Icons.play_arrow,
                    color: completed ? Colors.green : null,
                  ),
                ),
                title: Text(completed ? 'Review: ${nextModule.title}' : 'Continue: ${nextModule.title}'),
                subtitle: Text(nextModule.description),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/modules/${nextModule!.id}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.menu_book,
            label: 'Browse\nModules',
            onTap: () => context.push('/modules'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionCard(
            icon: Icons.quiz,
            label: 'Take a\nQuiz',
            onTap: () => context.push('/modules'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionCard(
            icon: Icons.leaderboard,
            label: 'Leader\nboard',
            onTap: () => context.push('/leaderboard'),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedTopic(
      BuildContext context, AsyncValue<List<EcoModule>> modulesAsync) {
    return modulesAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text('Error: $e')),
        ),
      ),
      data: (modules) {
        if (modules.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No modules available')),
            ),
          );
        }
        final featured = modules.first;
        final icon = _iconMap[featured.icon] ?? Icons.book;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/modules/${featured.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(icon, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          featured.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          featured.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressStats(
      BuildContext context, AsyncValue<EcoUser?> profileAsync) {
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
      error: (_, __) => const Row(
        children: [
          Expanded(child: _StatCard(icon: Icons.star, label: 'XP', value: '--')),
          SizedBox(width: 8),
          Expanded(child: _StatCard(icon: Icons.leaderboard, label: 'Level', value: '--')),
          SizedBox(width: 8),
          Expanded(child: _StatCard(icon: Icons.local_fire_department, label: 'Streak', value: '--')),
        ],
      ),
      data: (profile) {
        if (profile == null) return const Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.star, label: 'XP', value: '0')),
            SizedBox(width: 8),
            Expanded(child: _StatCard(icon: Icons.leaderboard, label: 'Level', value: '1')),
            SizedBox(width: 8),
            Expanded(child: _StatCard(icon: Icons.local_fire_department, label: 'Streak', value: '0')),
          ],
        );
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

  Widget _buildBadgesPreview(
      BuildContext context, AsyncValue<EcoUser?> profileAsync) {
    return profileAsync.when(
      loading: () => const Card(
        child: ListTile(
          leading: CircularProgressIndicator(strokeWidth: 2),
          title: Text('Loading badges...'),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        final badges = profile.badges;
        if (badges.isEmpty) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.emoji_events_outlined),
              ),
              title: const Text('Earn Your First Badge'),
              subtitle: const Text('Complete lessons and quizzes to earn badges'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/achievements'),
            ),
          );
        }

        final displayBadges = badges.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Badges Earned',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/achievements'),
                  child: const Text('View All'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.from(displayBadges.map((b) {
                return Chip(
                  avatar: const Icon(Icons.emoji_events, size: 18),
                  label: Text(b.replaceAll('_', ' ')),
                );
              })),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaderboardPreview(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.leaderboard),
        ),
        title: const Text('Leaderboard'),
        subtitle: const Text('See how you rank against other students'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push('/leaderboard'),
      ),
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

  Widget _buildSimulationsPreview(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _SimulationQuickCard(
            icon: Icons.delete_outline,
            title: 'Waste\nSorting',
            color: Colors.green,
            onTap: () => context.push('/simulations/waste'),
          ),
          const SizedBox(width: 8),
          _SimulationQuickCard(
            icon: Icons.cloud_outlined,
            title: 'Carbon\nFootprint',
            color: Colors.blue,
            onTap: () => context.push('/simulations/carbon'),
          ),
          const SizedBox(width: 8),
          _SimulationQuickCard(
            icon: Icons.bolt,
            title: 'Energy\nPlanner',
            color: Colors.amber,
            onTap: () => context.push('/simulations/energy'),
          ),
          const SizedBox(width: 8),
          _SimulationQuickCard(
            icon: Icons.water_drop_outlined,
            title: 'Water\nSaver',
            color: Colors.cyan,
            onTap: () => context.push('/simulations/water'),
          ),
          const SizedBox(width: 8),
          _SimulationQuickCard(
            icon: Icons.pets_outlined,
            title: 'Biodiversity\nProtector',
            color: Colors.teal,
            onTap: () => context.push('/simulations/biodiversity'),
          ),
          const SizedBox(width: 8),
          _SimulationQuickCard(
            icon: Icons.biotech,
            title: 'Gut\nMicrobiome',
            color: Colors.green,
            onTap: () => context.push('/simulations/gut-microbiome'),
          ),
          const SizedBox(width: 8),
          _SimulationQuickCard(
            icon: Icons.shield,
            title: 'Microplastics\nShield',
            color: Colors.orange,
            onTap: () => context.push('/simulations/microplastics'),
          ),
          const SizedBox(width: 8),
          _SimulationQuickCard(
            icon: Icons.spa,
            title: 'Fermented\nMillets',
            color: Colors.brown,
            onTap: () => context.push('/simulations/gut-health'),
          ),
          const SizedBox(width: 8),
          _SimulationQuickCard(
            icon: Icons.grid_view,
            title: 'All\nSimulations',
            color: Colors.purple,
            onTap: () => context.push('/simulations'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
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

class _SimulationQuickCard extends StatelessWidget {
  const _SimulationQuickCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
