import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final snap = await firestore.collection('modules').orderBy('order').get();

  print('');
  print('========================================');
  print('  FIRESTORE MODULES COLLECTION AUDIT');
  print('  Project: ecoquest-1eeae');
  print('  Collection: modules');
  print('  Documents: ${snap.docs.length}');
  print('========================================');
  print('');
  print('  doc_id                  | lessons | questions');
  print('  ------------------------|---------|----------');

  for (final doc in snap.docs) {
    final data = doc.data();
    final lessons = (data['lessons'] as List<dynamic>?) ?? [];
    final questions = (data['questions'] as List<dynamic>?) ?? [];
    final id = doc.id.padRight(24);
    print('  $id | ${lessons.length.toString().padLeft(7)} | ${questions.length.toString().padLeft(8)}');
  }

  print('');
  print('========================================');
  print('');
}
