import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/modules_repository.dart';
import '../../profile/data/user_profile_notifier.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({
    required this.moduleId,
    required this.lessonIndex,
    super.key,
  });
  final String moduleId;
  final int lessonIndex;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _completed = false;

  Future<void> _markComplete() async {
    if (_completed) return;
    _completed = true;
    await ref.read(userProfileProvider.notifier).completeLesson(
          widget.moduleId,
          widget.lessonIndex,
          10,
        );
  }

  @override
  Widget build(BuildContext context) {
    final asyncModule = ref.watch(moduleDetailProvider(widget.moduleId));

    return asyncModule.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (module) {
        if (module == null || widget.lessonIndex >= module.lessons.length) {
          return const Scaffold(body: Center(child: Text('Lesson not found')));
        }
        final lesson = module.lessons[widget.lessonIndex];
        final hasNext = widget.lessonIndex < module.lessons.length - 1;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title),
                Text(
                  'Lesson ${widget.lessonIndex + 1} of ${module.lessons.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                lesson.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 32),
              if (hasNext)
                FilledButton(
                  onPressed: () async {
                    await _markComplete();
                    if (context.mounted) {
                      context.go('/modules/${widget.moduleId}/lesson/${widget.lessonIndex + 1}');
                    }
                  },
                  child: const Text('Next Lesson'),
                )
              else
                FilledButton.tonal(
                  onPressed: () async {
                    await _markComplete();
                    if (context.mounted) context.go('/modules/${widget.moduleId}');
                  },
                  child: const Text('Back to Module'),
                ),
            ],
          ),
        );
      },
    );
  }
}
