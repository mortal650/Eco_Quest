import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'features/modules/data/modules_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Starting module reseed migration...');
  print('');

  final repo = ModulesRepository(FirebaseFirestore.instance);

  print('Step 1: Overwriting existing module documents...');
  await repo.forceReseedModules();
  print('Done.');
  print('');

  print('Step 2: Verifying Firestore data...');
  final result = await repo.verifyModules();
  result.printReport();

  if (!result.allPassed) {
    print('Migration completed with errors. Please check Firestore.');
    print('Exiting with code 1.');
    throw Exception('Verification failed');
  }

  print('Migration completed successfully.');
  print('All 5 modules verified with correct lesson and question counts.');
}
