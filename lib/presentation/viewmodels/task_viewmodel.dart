import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import 'providers.dart';

class TaskViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addTask({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    DateTime? dueDate,
    bool hasTime = false,
    String? category,
  }) async {
    final repo = ref.read(taskRepositoryProvider);
    final tasks = await repo.getAllTasks();
    final maxOrder = tasks.isEmpty
        ? 0
        : tasks.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b);
    final now = DateTime.now();
    await repo.addTask(Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      isCompleted: false,
      priority: priority,
      dueDate: dueDate,
      hasTime: hasTime,
      category: category,
      sortOrder: maxOrder + 1,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    ));
  }

  Future<void> updateTask(Task task) async {
    await ref.read(taskRepositoryProvider).updateTask(task.copyWith(
          updatedAt: DateTime.now(),
          isSynced: false,
        ));
  }

  Future<void> toggleComplete(Task task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> deleteTask(String id) async {
    await ref.read(taskRepositoryProvider).deleteTask(id);
  }

  Future<void> reorderTasks(List<Task> tasks, int oldIndex, int newIndex) async {
    final reordered = List<Task>.from(tasks);
    reordered.insert(newIndex, reordered.removeAt(oldIndex));
    final repo = ref.read(taskRepositoryProvider);
    final now = DateTime.now();
    for (var i = 0; i < reordered.length; i++) {
      await repo.updateTask(reordered[i].copyWith(
        sortOrder: i,
        updatedAt: now,
        isSynced: false,
      ));
    }
  }
}

final taskViewModelProvider =
    AsyncNotifierProvider<TaskViewModel, void>(TaskViewModel.new);
