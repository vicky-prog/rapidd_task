import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/task_model.dart';
import '../repository/task_repository.dart';
import 'package:uuid/uuid.dart';

final tasksProvider = StreamProvider.family<List<TaskModel>, String>((
  ref,
  userId,
) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasks(userId);
});

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, AsyncValue<void>>((ref) {
      return TaskViewModel(ref.read(taskRepositoryProvider));
    });

class TaskViewModel extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _repo;

  TaskViewModel(this._repo) : super(const AsyncValue.data(null));

  List<TaskModel> allTasks = [];

  Future<void> createTask(String title, String userId) async {
    state = const AsyncValue.loading();
    try {
      final id = const Uuid().v4();
      final task = TaskModel(
        id: id,
        title: title,
        completed: false,
        sharedWith: [userId],
        ownerId: userId,
        createdAt: DateTime.now(),
      );
      await _repo.createTask(task);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    await _repo.updateTask(task.copyWith(completed: !task.completed));
  }

  Future<void> shareTask(String taskId, String userId) async {
    await _repo.shareTask(taskId, userId);
  }

  Future<void> fetchNextPage(String userId) async {
    final nextTasks = await _repo.fetchNextPage(userId);
    if (nextTasks.isNotEmpty) {
      allTasks.addAll(nextTasks);
      state = const AsyncValue.data(null);
    }
  }
}
