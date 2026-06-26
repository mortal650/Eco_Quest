import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modules/data/modules_repository.dart';
import '../../modules/domain/module_model.dart';
import 'quiz_result_screen.dart';

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
  bool _quizFinished = false;
  List<QuizQuestion> _questions = [];

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
        _questions = module.questions;

        if (_quizFinished) {
          return Scaffold(
            body: _buildResult(
              context,
              _questions.length,
              module.id,
              module.title,
            ),
          );
        }

        if (_current >= _questions.length) {
          _quizFinished = true;
          return Scaffold(
            body: _buildResult(
              context,
              _questions.length,
              module.id,
              module.title,
            ),
          );
        }

        final q = _questions[_current];

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title),
                Text(
                  'Question ${_current + 1} / ${_questions.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          body: _buildQuestion(context, q, _questions.length),
        );
      },
    );
  }

  Color _difficultyColor(QuestionDifficulty d) {
    switch (d) {
      case QuestionDifficulty.easy:
        return Colors.green;
      case QuestionDifficulty.medium:
        return Colors.orange;
      case QuestionDifficulty.hard:
        return Colors.red;
    }
  }

  String _difficultyLabel(QuestionDifficulty d) {
    switch (d) {
      case QuestionDifficulty.easy:
        return 'Easy';
      case QuestionDifficulty.medium:
        return 'Medium';
      case QuestionDifficulty.hard:
        return 'Hard';
    }
  }

  Widget _buildQuestion(BuildContext context, QuizQuestion q, int total) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_current + 1) / total,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _difficultyColor(q.difficulty).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _difficultyColor(q.difficulty).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _difficultyLabel(q.difficulty),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _difficultyColor(q.difficulty),
                    ),
                  ),
                ),
              ],
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
                    onTap: _answered
                        ? null
                        : () => setState(() => _selected = i),
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
                            const Icon(Icons.check_circle,
                                color: Colors.green),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selected == q.correctIndex
                                ? Icons.lightbulb
                                : Icons.info_outline,
                            color: _selected == q.correctIndex
                                ? Colors.green
                                : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selected == q.correctIndex
                                ? 'Correct!'
                                : 'Not quite right',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selected == q.correctIndex
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(q.explanation),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildResult(
      BuildContext context, int total, String moduleId, String moduleTitle) {
    final xpEarned = _score * 10;

    return QuizResultScreen(
      moduleId: moduleId,
      moduleTitle: moduleTitle,
      score: _score,
      totalQuestions: total,
      xpEarned: xpEarned,
    );
  }
}
