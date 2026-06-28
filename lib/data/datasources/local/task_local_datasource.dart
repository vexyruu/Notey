import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/task.dart';
import '../../models/task_model.dart';

class TaskLocalDatasource {
  static Database? _db;
  final _controller = StreamController<List<Task>>.broadcast();

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tasksTable} (
        id           TEXT PRIMARY KEY,
        title        TEXT NOT NULL,
        description  TEXT,
        isCompleted  INTEGER NOT NULL DEFAULT 0,
        priority     INTEGER NOT NULL DEFAULT 0,
        dueDate      INTEGER,
        category     TEXT,
        sortOrder    INTEGER NOT NULL DEFAULT 0,
        createdAt    INTEGER NOT NULL,
        updatedAt    INTEGER NOT NULL,
        hasTime      INTEGER NOT NULL DEFAULT 0,
        isSynced     INTEGER NOT NULL DEFAULT 0,
        isDeleted    INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_tasks_completed ON ${AppConstants.tasksTable}(isCompleted)');
    await db.execute(
        'CREATE INDEX idx_tasks_synced ON ${AppConstants.tasksTable}(isSynced)');
    await db.execute(
        'CREATE INDEX idx_tasks_due ON ${AppConstants.tasksTable}(dueDate)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${AppConstants.tasksTable} ADD COLUMN hasTime INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _notifyListeners() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tasksTable,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'sortOrder ASC, createdAt DESC',
    );
    _controller.add(maps.map(TaskModel.fromMap).toList());
  }

  Stream<List<Task>> watchAll() {
    _notifyListeners();
    return _controller.stream;
  }

  Future<List<Task>> getAll() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tasksTable,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'sortOrder ASC, createdAt DESC',
    );
    return maps.map(TaskModel.fromMap).toList();
  }

  Future<List<Task>> getDirtyTasks() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tasksTable,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map(TaskModel.fromMap).toList();
  }

  Future<Task?> getById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tasksTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first);
  }

  Future<void> insert(Task task) async {
    final db = await database;
    await db.insert(
      AppConstants.tasksTable,
      TaskModel.fromTask(task).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notifyListeners();
  }

  Future<void> update(Task task) async {
    final db = await database;
    await db.update(
      AppConstants.tasksTable,
      TaskModel.fromTask(task).toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    await _notifyListeners();
  }

  Future<void> softDelete(String id) async {
    final db = await database;
    await db.update(
      AppConstants.tasksTable,
      {
        'isDeleted': 1,
        'isSynced': 0,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _notifyListeners();
  }

  Future<void> hardDelete(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    await _notifyListeners();
  }

  void dispose() {
    _controller.close();
  }
}
