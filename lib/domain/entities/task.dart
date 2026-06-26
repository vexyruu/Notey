enum Priority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final Priority priority;
  final DateTime? dueDate;
  final String? category;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    this.dueDate,
    this.category,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    DateTime? dueDate,
    String? category,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    bool clearDescription = false,
    bool clearDueDate = false,
    bool clearCategory = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      category: clearCategory ? null : (category ?? this.category),
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) => other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Task(id: $id, title: $title, completed: $isCompleted)';
}
