import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_repository.dart';
import '../../profile/data/user_profile_notifier.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _schoolCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _gradeCtrl;
  late TextEditingController _subjectCtrl;
  late TextEditingController _experienceCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).valueOrNull;
    _nameCtrl = TextEditingController(text: profile?.displayName ?? '');
    _schoolCtrl = TextEditingController(text: profile?.schoolName ?? '');
    _cityCtrl = TextEditingController(text: profile?.city ?? '');
    _stateCtrl = TextEditingController(text: profile?.state ?? '');
    _gradeCtrl = TextEditingController(text: profile?.grade ?? '');
    _subjectCtrl = TextEditingController(text: profile?.subject ?? '');
    _experienceCtrl = TextEditingController(text: profile?.experience ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _gradeCtrl.dispose();
    _subjectCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final profile = ref.read(userProfileProvider).valueOrNull;

      await authRepo.updateUserProfile(
        field: 'displayName',
        value: _nameCtrl.text.trim(),
      );

      if (profile?.role == 'student') {
        await authRepo.updateUserProfile(
          field: 'schoolName',
          value: _schoolCtrl.text.trim(),
        );
        await authRepo.updateUserProfile(
          field: 'city',
          value: _cityCtrl.text.trim(),
        );
        await authRepo.updateUserProfile(
          field: 'state',
          value: _stateCtrl.text.trim(),
        );
        await authRepo.updateUserProfile(
          field: 'grade',
          value: _gradeCtrl.text.trim(),
        );
      } else {
        await authRepo.updateUserProfile(
          field: 'institutionName',
          value: _schoolCtrl.text.trim(),
        );
        await authRepo.updateUserProfile(
          field: 'city',
          value: _cityCtrl.text.trim(),
        );
        await authRepo.updateUserProfile(
          field: 'state',
          value: _stateCtrl.text.trim(),
        );
        await authRepo.updateUserProfile(
          field: 'subject',
          value: _subjectCtrl.text.trim(),
        );
        await authRepo.updateUserProfile(
          field: 'experience',
          value: _experienceCtrl.text.trim(),
        );
      }

      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
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
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final isTeacher = profile?.role == 'teacher';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Name is required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolCtrl,
                decoration: InputDecoration(
                  labelText: isTeacher ? 'Institution Name' : 'School/College Name',
                  prefixIcon: Icon(isTeacher ? Icons.account_balance : Icons.school),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        prefixIcon: Icon(Icons.map_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isTeacher) ...[
                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: Icon(Icons.subject),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Experience (years)',
                    prefixIcon: Icon(Icons.work_history),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                TextFormField(
                  controller: _gradeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Grade / Year',
                    prefixIcon: Icon(Icons.grade),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
