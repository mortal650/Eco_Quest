import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/modules_repository.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({required this.moduleId, super.key});
  final String moduleId;

  static const _iconMap = <String, IconData>{
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncModule = ref.watch(moduleDetailProvider(moduleId));

    return asyncModule.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (module) {
        if (module == null) {
          return const Scaffold(body: Center(child: Text('Module not found')));
        }
        final icon = _iconMap[module.icon] ?? Icons.book;
        return Scaffold(
          appBar: AppBar(title: Text(module.title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Icon(icon, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              module.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Lessons (${module.lessons.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...List.generate(module.lessons.length, (i) {
                final lesson = module.lessons[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${i + 1}'),
                    ),
                    title: Text(lesson.title),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push(
                      '/modules/${module.id}/lesson/$i',
                    ),
                  ),
                );
              }),
              if (module.questions.isNotEmpty) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push(
                    '/modules/${module.id}/quiz',
                  ),
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Take Quiz'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
