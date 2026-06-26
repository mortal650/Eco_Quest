import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../classroom/data/classroom_repository.dart';

class JoinClassroomScreen extends ConsumerStatefulWidget {
  const JoinClassroomScreen({super.key});

  @override
  ConsumerState<JoinClassroomScreen> createState() =>
      _JoinClassroomScreenState();
}

class _JoinClassroomScreenState extends ConsumerState<JoinClassroomScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() => _loading = true);

    try {
      final classroom =
          await ref.read(classroomRepositoryProvider).joinClassroom(code);

      if (mounted) {
        if (classroom != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined ${classroom.classroomName}!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid classroom code'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Classroom')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group_add_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter Classroom Code',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Ask your teacher for the 6-character code',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeCtrl,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: 8,
                    ),
                decoration: const InputDecoration(
                  hintText: 'XXXXXX',
                  border: OutlineInputBorder(),
                ),
                maxLength: 6,
                onSubmitted: (_) => _join(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _join,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Join Classroom'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
