import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskView { today, upcoming, all, active, done }

final taskLocalDatasourceProvider = Provider<TaskLocalDatasource>((ref) {
  final datasource = TaskLocalDatasource();
  ref.onDispose(datasource.dispose);
  return datasource;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskLocalDatasourceProvider));
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks();
});

final taskViewProvider = StateProvider<TaskView>((ref) => TaskView.today);

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final availableCategoriesProvider = Provider<List<String>>((ref) {
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  return tasks
      .where((t) => t.category != null && !t.isDeleted)
      .map((t) => t.category!)
      .toSet()
      .toList()
    ..sort();
});

final unifiedFilteredProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final view = ref.watch(taskViewProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return tasksAsync.whenData((tasks) {
    var result = switch (view) {
      TaskView.today => tasks
          .where((t) => !t.isDeleted && !t.isCompleted && t.dueDate != null)
          .where((t) {
            final due =
                DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
            return !due.isAfter(today);
          })
          .toList(),
      TaskView.upcoming => tasks
          .where((t) => !t.isDeleted && !t.isCompleted && t.dueDate != null)
          .where((t) {
            final due =
                DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
            return due.isAfter(today);
          })
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!)),
      TaskView.all => tasks.where((t) => !t.isDeleted).toList(),
      TaskView.active =>
        tasks.where((t) => !t.isDeleted && !t.isCompleted).toList(),
      TaskView.done =>
        tasks.where((t) => !t.isDeleted && t.isCompleted).toList(),
    };

    // Category filter applies to all views except upcoming (chips are hidden there)
    if (selectedCategory != null && view != TaskView.upcoming) {
      result = result.where((t) => t.category == selectedCategory).toList();
    }

    return result;
  });
});

final taskByIdProvider = Provider.family<Task?, String>((ref, id) {
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  try {
    return tasks.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
});
