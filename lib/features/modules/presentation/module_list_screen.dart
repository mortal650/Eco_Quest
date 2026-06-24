import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/modules_repository.dart';

class ModuleListScreen extends ConsumerWidget {
  const ModuleListScreen({super.key});

  static const _iconMap = <String, IconData>{
    'biotech': Icons.biotech,
    'water_drop': Icons.water_drop,
    'bolt': Icons.bolt,
    'agriculture': Icons.agriculture,
    'thermostat': Icons.thermostat,
    'science': Icons.science,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Modules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Seed sample modules',
            onPressed: () async {
              await ref.read(modulesRepositoryProvider).seedModules();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample modules seeded')),
                );
              }
            },
          ),
        ],
      ),
      body: modulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (modules) {
          if (modules.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No modules yet'),
                  const SizedBox(height: 8),
                  const Text('Tap the cloud icon to seed sample content'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              final icon = _iconMap[module.icon] ?? Icons.book;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: Icon(icon),
                  ),
                  title: Text(module.title),
                  subtitle: Text(module.description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/modules/${module.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
