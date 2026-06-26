import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/modules_repository.dart';
import '../domain/module_model.dart';
import '../../profile/data/user_profile_notifier.dart';

class ModuleListScreen extends ConsumerStatefulWidget {
  const ModuleListScreen({super.key});

  @override
  ConsumerState<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends ConsumerState<ModuleListScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  static const _categories = [
    'All',
    'Climate Change',
    'Waste Management',
    'Renewable Energy',
    'Biodiversity',
    'Sustainable Living',
  ];

  static const _categoryKeywords = {
    'Climate Change': ['climate', 'greenhouse', 'temperature', 'co2', 'carbon'],
    'Waste Management': ['plastic', 'waste', 'pollution', 'recycling', 'trash'],
    'Renewable Energy': ['energy', 'solar', 'wind', 'power', 'electricity'],
    'Biodiversity': ['biome', 'ecosystem', 'biodiversity', 'species', 'habitat'],
    'Sustainable Living': ['sustainable', 'agriculture', 'food', 'water', 'farm'],
  };

  static const _iconMap = <String, IconData>{
    'biotech': Icons.biotech,
    'water_drop': Icons.water_drop,
    'bolt': Icons.bolt,
    'agriculture': Icons.agriculture,
    'thermostat': Icons.thermostat,
    'science': Icons.science,
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _getCategoryForModule(EcoModule module) {
    final text = '${module.title} ${module.description}'.toLowerCase();
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) return entry.key;
      }
    }
    return 'Sustainable Living';
  }

  List<EcoModule> _filterModules(List<EcoModule> modules) {
    return modules.where((module) {
      final matchesSearch = _searchQuery.isEmpty ||
          module.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          module.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          _getCategoryForModule(module) == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final modulesAsync = ref.watch(modulesStreamProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Modules'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search modules...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: modulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (modules) {
                final filtered = _filterModules(modules);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          modules.isEmpty
                              ? 'No modules yet'
                              : 'No modules match your search',
                        ),
                        if (modules.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Tap the button below to seed content'),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final module = filtered[index];
                    final icon = _iconMap[module.icon] ?? Icons.book;
                    final category = _getCategoryForModule(module);

                    return _ModuleCard(
                      module: module,
                      icon: icon,
                      category: category,
                      profileAsync: profileAsync,
                      onTap: () => context.push('/modules/${module.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: modulesAsync.when(
        loading: () => null,
        error: (_, __) => null,
        data: (modules) {
          if (modules.isNotEmpty) return null;
          return FloatingActionButton.extended(
            onPressed: () async {
              await ref.read(modulesRepositoryProvider).seedModules();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample modules seeded')),
                );
              }
            },
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Seed Sample Modules'),
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.icon,
    required this.category,
    required this.profileAsync,
    required this.onTap,
  });

  final EcoModule module;
  final IconData icon;
  final String category;
  final AsyncValue<dynamic> profileAsync;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lessonCount = module.lessons.length;
    final questionCount = module.questions.length;
    final xpReward = lessonCount * 10 + questionCount * 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(icon, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          module.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ModuleTag(
                    icon: Icons.book_outlined,
                    label: '$lessonCount lessons',
                  ),
                  const SizedBox(width: 12),
                  _ModuleTag(
                    icon: Icons.quiz_outlined,
                    label: '$questionCount questions',
                  ),
                  const SizedBox(width: 12),
                  _ModuleTag(
                    icon: Icons.star_outline,
                    label: '+$xpReward XP',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                  ),
                  const Spacer(),
                  profileAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (profile) {
                      if (profile == null) return const SizedBox.shrink();
                      final completed =
                          profile.completedLessons.containsKey(module.id);
                      if (completed) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleTag extends StatelessWidget {
  const _ModuleTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
