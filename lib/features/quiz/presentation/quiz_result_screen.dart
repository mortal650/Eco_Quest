import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../profile/data/user_profile_notifier.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz_model.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  const QuizResultScreen({
    required this.moduleId,
    required this.moduleTitle,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    super.key,
  });

  final String moduleId;
  final String moduleTitle;
  final int score;
  final int totalQuestions;
  final int xpEarned;

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _saved = false;
  String? _badgeEarned;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
    _saveResult();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveResult() async {
    if (_saved) return;
    _saved = true;

    final result = QuizResult(
      moduleId: widget.moduleId,
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      ecoPointsEarned: widget.xpEarned,
      completedAt: DateTime.now(),
      moduleTitle: widget.moduleTitle,
    );

    try {
      await ref.read(quizRepositoryProvider).saveResult(result);
    } catch (_) {}

    try {
      await ref.read(userProfileProvider.notifier).applyQuizResult(result);
    } catch (_) {}

    if (widget.score == widget.totalQuestions) {
      _badgeEarned = 'Perfect Score';
    } else if ((widget.score / widget.totalQuestions) >= 0.8) {
      _badgeEarned = 'Eco Warrior';
    } else if ((widget.score / widget.totalQuestions) >= 0.6) {
      _badgeEarned = 'Nature Learner';
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (100 * widget.score / widget.totalQuestions).round();
    final colorScheme = Theme.of(context).colorScheme;
    final wrong = widget.totalQuestions - widget.score;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && mounted) {
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Dashboard',
            onPressed: () {
              if (!mounted) return;
              context.go('/home');
            },
          ),
          title: const Text('Quiz Result'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    percentage >= 70
                        ? Icons.emoji_events
                        : percentage >= 50
                            ? Icons.thumb_up
                            : Icons.info_outline,
                    size: 80,
                    color: percentage >= 70
                        ? Colors.amber
                        : percentage >= 50
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quiz Complete!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.moduleTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Score',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.score} / ${widget.totalQuestions}',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: widget.score / widget.totalQuestions,
                            minHeight: 12,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$percentage%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: percentage >= 70
                                    ? Colors.green
                                    : colorScheme.error,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ResultStat(
                        label: 'Correct',
                        value: '${widget.score}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ResultStat(
                        label: 'Wrong',
                        value: '$wrong',
                        icon: Icons.cancel,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ResultStat(
                        label: 'XP Earned',
                        value: '+${widget.xpEarned}',
                        icon: Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                if (_badgeEarned != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: colorScheme.primaryContainer,
                    child: ListTile(
                      leading:
                          const Icon(Icons.emoji_events, color: Colors.amber),
                      title: const Text('Badge Earned!'),
                      subtitle: Text(
                        _badgeEarned!,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (!mounted) return;
                      context.go('/modules/${widget.moduleId}');
                    },
                    icon: const Icon(Icons.school),
                    label: const Text('Continue Learning'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (!mounted) return;
                      context.go('/modules/${widget.moduleId}/quiz');
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Retry Quiz'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (!mounted) return;
                      context.go('/home');
                    },
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('Dashboard'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
