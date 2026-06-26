import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource _local;

  TaskRepositoryImpl(this._local);

  @override
  Stream<List<Task>> watchAllTasks() => _local.watchAll();

  @override
  Future<List<Task>> getAllTasks() => _local.getAll();

  @override
  Future<Task?> getTaskById(String id) => _local.getById(id);

  @override
  Future<void> addTask(Task task) => _local.insert(task);

  @override
  Future<void> updateTask(Task task) => _local.update(task);

  @override
  Future<void> deleteTask(String id) => _local.softDelete(id);

  @override
  Future<void> hardDeleteTask(String id) => _local.hardDelete(id);
}
