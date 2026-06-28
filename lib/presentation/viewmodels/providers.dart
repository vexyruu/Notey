import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskFilter { all, active, completed }

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

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

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

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final filter = ref.watch(taskFilterProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  return tasksAsync.whenData((tasks) {
    var result = switch (filter) {
      TaskFilter.all => tasks,
      TaskFilter.active => tasks.where((t) => !t.isCompleted).toList(),
      TaskFilter.completed => tasks.where((t) => t.isCompleted).toList(),
    };
    if (selectedCategory != null) {
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
