import '../entities/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> hardDeleteTask(String id);
  Stream<List<Task>> watchAllTasks();
}
