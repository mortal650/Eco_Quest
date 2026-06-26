import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

const _officialModuleIds = {
  'climate_change',
  'waste_management',
  'renewable_energy',
  'biodiversity',
  'sustainable_living',
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final col = firestore.collection('modules');

  print('');
  print('========================================');
  print('  ORPHANED MODULE CLEANUP');
  print('  Project: ecoquest-1eeae');
  print('========================================');
  print('');

  // Fetch all documents
  final snap = await col.orderBy('order').get();
  print('  Total documents in collection: ${snap.docs.length}');
  print('  Official modules expected:     ${_officialModuleIds.length}');
  print('');

  // Identify orphaned documents
  final orphaned = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  final official = <String>[];

  for (final doc in snap.docs) {
    if (_officialModuleIds.contains(doc.id)) {
      official.add(doc.id);
    } else {
      orphaned.add(doc);
    }
  }

  print('  Official modules found: ${official.length}');
  for (final id in official) {
    print('    - $id');
  }
  print('');
  print('  Orphaned modules to delete: ${orphaned.length}');

  if (orphaned.isEmpty) {
    print('');
    print('  No orphaned modules found. Collection is clean.');
    print('');
    return;
  }

  // Show orphaned details
  print('');
  print('  Orphaned documents:');
  for (final doc in orphaned) {
    final data = doc.data();
    final lessons = (data['lessons'] as List<dynamic>?) ?? [];
    final questions = (data['questions'] as List<dynamic>?) ?? [];
    print('    ${doc.id} (lessons: ${lessons.length}, questions: ${questions.length})');
  }

  // Delete in batches of 500 (Firestore limit)
  print('');
  print('  Deleting orphaned modules...');

  final batches = <WriteBatch>[];
  var currentBatch = firestore.batch();
  var opCount = 0;

  for (final doc in orphaned) {
    currentBatch.delete(doc.reference);
    opCount++;
    if (opCount == 500) {
      batches.add(currentBatch);
      currentBatch = firestore.batch();
      opCount = 0;
    }
  }
  if (opCount > 0) {
    batches.add(currentBatch);
  }

  for (var i = 0; i < batches.length; i++) {
    await batches[i].commit();
    print('    Batch ${i + 1}/${batches.length} committed (${(i + 1) * 500 < orphaned.length ? 500 : orphaned.length % 500} docs)');
  }

  print('');
  print('  Done. Deleted ${orphaned.length} orphaned module(s).');

  // Verify
  final verifySnap = await col.get();
  print('');
  print('  Verification: ${verifySnap.docs.length} documents remain');
  for (final doc in verifySnap.docs) {
    print('    - ${doc.id}');
  }
  print('');
}
