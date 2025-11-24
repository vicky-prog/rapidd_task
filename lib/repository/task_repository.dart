import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(FirebaseFirestore.instance);
});

class TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepository(this._firestore);

  CollectionReference get _tasks => _firestore.collection('tasks');
  DocumentSnapshot? _lastDoc;
  static const int pageSize = 20;
  Future<void> createTask(TaskModel task) async {
    await _tasks.doc(task.id).set({...task.toMap(), 'ownerId': task.ownerId});
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasks.doc(task.id).update(task.toMap());
  }

  Future<void> shareTask(String taskId, String userId) async {
    await _tasks.doc(taskId).update({
      'sharedWith': FieldValue.arrayUnion([userId]),
    });
  }

  Future<TaskModel?> getTaskById(String id) async {
    final doc = await _tasks.doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    return TaskModel.fromMap(data, doc.id);
  }

  Stream<List<TaskModel>> watchTasks(String userId) {
    return _tasks
        .where(
          Filter.or(
            Filter('ownerId', isEqualTo: userId),
            Filter('sharedWith', arrayContains: userId),
          ),
        )
        .orderBy('createdAt', descending: true)
        .limit(pageSize)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map(
                (d) =>
                    TaskModel.fromMap(d.data() as Map<String, dynamic>, d.id),
              )
              .toList();
          if (snap.docs.isNotEmpty) {
            _lastDoc = snap.docs.last;
          }
          return list;
        });
  }

  Future<List<TaskModel>> fetchNextPage(String userId) async {
    if (_lastDoc == null) return [];

    final snap = await _tasks
        .where(
          Filter.or(
            Filter('ownerId', isEqualTo: userId),
            Filter('sharedWith', arrayContains: userId),
          ),
        )
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_lastDoc!)
        .limit(pageSize)
        .get();

    final list = snap.docs
        .map((d) => TaskModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
    return list;
  }
}
