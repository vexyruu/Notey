import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.isCompleted,
    required super.priority,
    super.dueDate,
    super.category,
    required super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
    required super.isSynced,
    required super.isDeleted,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      priority: Priority.values[map['priority'] as int],
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
      category: map['category'] as String?,
      sortOrder: map['sortOrder'] as int,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isSynced: (map['isSynced'] as int) == 1,
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority.index,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'category': category,
      'sortOrder': sortOrder,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  static TaskModel fromTask(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
      priority: task.priority,
      dueDate: task.dueDate,
      category: task.category,
      sortOrder: task.sortOrder,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      isSynced: task.isSynced,
      isDeleted: task.isDeleted,
    );
  }
}
