import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/classroom_model.dart';

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  return ClassroomRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class ClassroomRepository {
  const ClassroomRepository(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _classroomsCol =>
      _firestore.collection('classrooms');

  CollectionReference<Map<String, dynamic>> get _membersCol =>
      _firestore.collection('classroom_members');

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<String> createClassroom({
    required String classroomName,
    required String teacherId,
    required String teacherName,
  }) async {
    final code = _generateCode();
    final docId = _classroomsCol.doc().id;

    final classroom = Classroom(
      classroomId: docId,
      classroomName: classroomName,
      classroomCode: code,
      teacherId: teacherId,
      teacherName: teacherName,
      studentCount: 0,
      createdAt: DateTime.now(),
    );

    await _classroomsCol.doc(docId).set(classroom.toJson());
    return code;
  }

  Future<Classroom?> joinClassroom(String code) async {
    if (_uid == null) return null;

    final snap = await _classroomsCol
        .where('classroomCode', isEqualTo: code)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final classroomDoc = snap.docs.first;
    final classroom = Classroom.fromJson(
      classroomDoc.data()..['classroomId'] = classroomDoc.id,
    );

    final existingMember = await _membersCol
        .where('classroomId', isEqualTo: classroom.classroomId)
        .where('studentId', isEqualTo: _uid)
        .limit(1)
        .get();

    if (existingMember.docs.isNotEmpty) return classroom;

    final userSnap =
        await _firestore.collection('users').doc(_uid).get();
    final studentName = userSnap.data()?['displayName'] ?? 'Student';

    final member = ClassroomMember(
      classroomId: classroom.classroomId,
      studentId: _uid!,
      studentName: studentName,
      joinedAt: DateTime.now(),
    );

    await _membersCol.doc().set(member.toJson());
    await _classroomsCol.doc(classroom.classroomId).update({
      'studentCount': FieldValue.increment(1),
    });

    return classroom;
  }

  Stream<List<Classroom>> watchTeacherClassrooms(String teacherId) {
    return _classroomsCol
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Classroom.fromJson(doc.data()..['classroomId'] = doc.id))
            .toList());
  }

  Stream<List<Classroom>> watchStudentClassrooms(String studentId) {
    return _membersCol
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .asyncMap((snap) async {
      final classrooms = <Classroom>[];
      for (final member in snap.docs) {
        final classroomSnap =
            await _classroomsCol.doc(member.data()['classroomId']).get();
        if (classroomSnap.exists && classroomSnap.data() != null) {
          classrooms.add(Classroom.fromJson(
            classroomSnap.data()!..['classroomId'] = classroomSnap.id,
          ));
        }
      }
      return classrooms;
    });
  }

  Stream<List<ClassroomMember>> watchClassroomMembers(String classroomId) {
    return _membersCol
        .where('classroomId', isEqualTo: classroomId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ClassroomMember.fromJson(doc.data()))
            .toList());
  }

  Future<void> removeStudent(String classroomId, String studentId) async {
    final snap = await _membersCol
        .where('classroomId', isEqualTo: classroomId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    for (final doc in snap.docs) {
      await doc.reference.delete();
    }

    await _classroomsCol.doc(classroomId).update({
      'studentCount': FieldValue.increment(-1),
    });
  }

  Future<void> deleteClassroom(String classroomId) async {
    final members = await _membersCol
        .where('classroomId', isEqualTo: classroomId)
        .get();
    for (final doc in members.docs) {
      await doc.reference.delete();
    }
    await _classroomsCol.doc(classroomId).delete();
  }
}
