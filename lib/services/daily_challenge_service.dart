import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailyChallengeServiceProvider = Provider<DailyChallengeService>((ref) {
  return DailyChallengeService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class DailyChallengeService {
  const DailyChallengeService(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  static const _challenges = [
    'Use a reusable water bottle today.',
    'Walk or bike for short trips instead of driving.',
    'Take a shorter shower to save water.',
    'Eat one plant-based meal today.',
    'Pick up 5 pieces of litter in your neighborhood.',
    'Unplug devices you are not using to save energy.',
    'Bring your own bags when shopping.',
    'Read about one environmental topic for 10 minutes.',
    'Compost your food scraps today.',
    'Share an eco-tip with a friend.',
    'Avoid single-use plastics for the entire day.',
    'Plant a seed or water a plant today.',
  ];

  Future<Map<String, dynamic>?> getTodayChallenge() async {
    if (_uid == null) return null;

    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('daily_challenges')
        .doc(dateKey)
        .get();

    if (doc.exists) return doc.data();

    final index = (today.year * 366 + today.month * 31 + today.day) %
        _challenges.length;

    final data = {
      'date': dateKey,
      'challenge': _challenges[index],
      'completed': false,
    };

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('daily_challenges')
        .doc(dateKey)
        .set(data);

    return data;
  }

  Future<void> completeChallenge() async {
    if (_uid == null) return;

    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('daily_challenges')
        .doc(dateKey)
        .update({'completed': true});

    await _firestore.collection('users').doc(_uid).update({
      'xp': FieldValue.increment(5),
    });
  }
}
