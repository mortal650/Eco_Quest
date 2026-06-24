import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../modules/data/modules_repository.dart';
import '../../modules/domain/module_model.dart';
import '../../profile/data/user_profile_notifier.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz_model.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({required this.moduleId, super.key});
  final String moduleId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final asyncModule = ref.watch(moduleDetailProvider(widget.moduleId));

    return asyncModule.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (module) {
        if (module == null || module.questions.isEmpty) {
          return const Scaffold(
              body: Center(child: Text('No quiz available')));
        }
        final questions = module.questions;
        final q = questions[_current];

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title),
                Text(
                  'Question ${_current + 1} / ${questions.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          body: _submitting
              ? const Center(child: CircularProgressIndicator())
              : _current >= questions.length
                  ? _buildResult(context, questions.length, module.id)
                  : _buildQuestion(context, q, questions.length),
        );
      },
    );
  }

  Widget _buildQuestion(BuildContext context, QuizQuestion q, int total) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_current + 1) / total,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 24),
          Text(
            q.question,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ...List.generate(q.options.length, (i) {
            final isSelected = _selected == i;
            final isCorrect = i == q.correctIndex;
            Color? bg;
            if (_answered) {
              if (isCorrect) bg = colorScheme.primaryContainer;
              if (isSelected && !isCorrect) bg = colorScheme.errorContainer;
            } else if (isSelected) {
              bg = colorScheme.primaryContainer;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap:
                      _answered ? null : () => setState(() => _selected = i),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          child: Text('${i + 1}'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(q.options[i])),
                        if (_answered && isCorrect)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (_answered && isSelected && !isCorrect)
                          const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 16),
            Card(
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(q.explanation),
              ),
            ),
          ],
          const Spacer(),
          if (!_answered)
            FilledButton(
              onPressed: _selected == null
                  ? null
                  : () {
                      setState(() {
                        _answered = true;
                        if (_selected == q.correctIndex) _score++;
                      });
                    },
              child: const Text('Check Answer'),
            )
          else
            FilledButton(
              onPressed: () {
                setState(() {
                  _current++;
                  _selected = null;
                  _answered = false;
                });
              },
              child: Text(
                  _current < total - 1 ? 'Next Question' : 'See Results'),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, int total, String moduleId) {
    final pct = (100 * _score / total).round();
    final xpEarned = _score * 10;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              pct >= 70 ? Icons.emoji_events : Icons.info_outline,
              size: 72,
              color: pct >= 70 ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Quiz Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$_score / $total correct ($pct%)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '+$xpEarned XP',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () async {
                setState(() => _submitting = true);
                final result = QuizResult(
                  moduleId: moduleId,
                  score: _score,
                  totalQuestions: total,
                  ecoPointsEarned: xpEarned,
                  completedAt: DateTime.now(),
                );
                await ref.read(quizRepositoryProvider).saveResult(result);
                await ref
                    .read(userProfileProvider.notifier)
                    .applyQuizResult(result);
                if (context.mounted) context.go('/modules');
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
