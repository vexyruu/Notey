import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskView { today, upcoming, all }

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

final selectedLabelProvider = StateProvider<String?>((ref) => null);

// Keep old name as alias so existing references compile
final selectedCategoryProvider = selectedLabelProvider;

final unifiedFilteredProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final view = ref.watch(taskViewProvider);
  final selectedLabel = ref.watch(selectedLabelProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return tasksAsync.whenData((tasks) {
    var result = switch (view) {
      TaskView.today => tasks
          .where((t) => !t.isDeleted && !t.isCompleted && t.dueDate != null)
          .where((t) {
            final due = DateTime(
                t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
            return !due.isAfter(today);
          })
          .toList(),
      TaskView.upcoming => tasks
          .where((t) => !t.isDeleted && !t.isCompleted && t.dueDate != null)
          .where((t) {
            final due = DateTime(
                t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
            return due.isAfter(today);
          })
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!)),
      // All: active tasks first, then completed (both non-deleted)
      TaskView.all => [
          ...tasks.where((t) => !t.isDeleted && !t.isCompleted),
          ...tasks.where((t) => !t.isDeleted && t.isCompleted),
        ],
    };

    if (selectedLabel != null && view != TaskView.upcoming) {
      result = result.where((t) => t.category == selectedLabel).toList();
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
