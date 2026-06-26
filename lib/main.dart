import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'features/modules/data/modules_repository.dart';

void main() async {
  print('[MAIN] 1. entry reached');

  WidgetsFlutterBinding.ensureInitialized();
  print('[MAIN] 2. binding initialized');

  FlutterError.onError = (details) {
    print('[FLUTTER_ERROR] ${details.exceptionAsString()}');
    print('[FLUTTER_ERROR] ${details.stack}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    print('[ERROR_WIDGET] ${details.exceptionAsString()}');
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                kDebugMode ? details.exceptionAsString() : 'Please restart the app',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runZonedGuarded(() async {
    print('[MAIN] 3. inside runZonedGuarded');

    try {
      await Hive.initFlutter();
      print('[MAIN] 4. Hive initialized');
    } catch (e) {
      print('[MAIN] 4. Hive FAILED: $e');
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('[MAIN] 5. Firebase initialized');
    } catch (e) {
      print('[MAIN] 5. Firebase FAILED: $e');
    }

    final container = ProviderContainer();
    print('[MAIN] 6. ProviderContainer created');

    try {
      await container.read(autoSeedProvider.future).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[MAIN] 7. autoSeed timed out (non-blocking)');
          return false;
        },
      );
      print('[MAIN] 7. autoSeed completed');
    } catch (e) {
      print('[MAIN] 7. autoSeed FAILED (non-blocking): $e');
    }

    print('[MAIN] 8. calling runApp');
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const EcoQuestApp(),
      ),
    );
    print('[MAIN] 9. runApp returned — app is alive');
  }, (error, stack) {
    print('[ZONED_FATAL] $error');
    print('[ZONED_FATAL] $stack');
  });
}
