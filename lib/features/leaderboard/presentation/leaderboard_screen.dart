import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_repository.dart';
import '../../classroom/data/classroom_repository.dart';
import '../../classroom/domain/classroom_model.dart';
import '../../../services/leaderboard_service.dart';

final _leaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) {
  return ref.read(leaderboardServiceProvider).getGlobalLeaderboard();
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedClassroomId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Classroom'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalLeaderboard(user?.uid),
          _buildClassroomLeaderboard(user?.uid),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboard(String? currentUid) {
    final leaderboardAsync = ref.watch(_leaderboardProvider);

    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final message = e is LeaderboardException ? e.message : 'Error: $e';
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(_leaderboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('No students yet'),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isMe = entry.uid == currentUid;
            return _LeaderboardTile(
              rank: index + 1,
              entry: entry,
              isCurrentUser: isMe,
            );
          },
        );
      },
    );
  }

  Widget _buildClassroomLeaderboard(String? currentUid) {
    if (currentUid == null) {
      return const Center(child: Text('Not logged in'));
    }

    final classroomsAsync = ref.watch(
      studentClassroomsProvider(currentUid),
    );

    return classroomsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (classrooms) {
        if (classrooms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.class_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Join a classroom to see its leaderboard'),
              ],
            ),
          );
        }

        if (_selectedClassroomId == null ||
            !classrooms.any((c) => c.classroomId == _selectedClassroomId)) {
          _selectedClassroomId = classrooms.first.classroomId;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedClassroomId,
                decoration: const InputDecoration(
                  labelText: 'Select Classroom',
                  border: OutlineInputBorder(),
                ),
                items: classrooms
                    .map((c) => DropdownMenuItem(
                          value: c.classroomId,
                          child: Text(c.classroomName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedClassroomId = v),
              ),
            ),
            if (_selectedClassroomId != null)
              Expanded(
                child: _ClassroomLeaderboardView(
                  classroomId: _selectedClassroomId!,
                  currentUid: currentUid,
                ),
              ),
          ],
        );
      },
    );
  }
}

final studentClassroomsProvider =
    StreamProvider.family<List<Classroom>, String>((ref, studentId) {
  return ref
      .watch(classroomRepositoryProvider)
      .watchStudentClassrooms(studentId);
});

class _ClassroomLeaderboardView extends ConsumerWidget {
  const _ClassroomLeaderboardView({
    required this.classroomId,
    required this.currentUid,
  });

  final String classroomId;
  final String currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(
      _classroomLeaderboardProvider(classroomId),
    );

    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final message = e is LeaderboardException ? e.message : 'Error: $e';
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(
                    _classroomLeaderboardProvider(classroomId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(child: Text('No students in this classroom'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _LeaderboardTile(
              rank: index + 1,
              entry: entry,
              isCurrentUser: entry.uid == currentUid,
            );
          },
        );
      },
    );
  }
}

final _classroomLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, classroomId) {
  return ref
      .read(leaderboardServiceProvider)
      .getClassroomLeaderboard(classroomId);
});

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
  });

  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTop3 = rank <= 3;

    return Card(
      color: isCurrentUser ? colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTop3
              ? rank == 1
                  ? Colors.amber
                  : rank == 2
                      ? Colors.grey
                      : Colors.brown
              : colorScheme.surfaceContainerHighest,
          child: Text(
            '$rank',
            style: TextStyle(
              color: isTop3 ? Colors.white : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          entry.displayName,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : null,
          ),
        ),
        subtitle: Text('Level ${entry.level}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.xp} XP',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${entry.averageQuizScore.round()}% avg',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
