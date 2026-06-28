import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/note.dart';
import '../../models/note_model.dart';
import 'task_local_datasource.dart';

class NoteLocalDatasource {
  final TaskLocalDatasource _taskDs;
  final _controller = StreamController<List<Note>>.broadcast();

  NoteLocalDatasource(this._taskDs);

  Future<Database> get _db => _taskDs.database;

  Future<void> _notify() async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'updatedAt DESC',
    );
    _controller.add(maps.map(NoteModel.fromMap).toList());
  }

  Stream<List<Note>> watchAll() {
    _notify();
    return _controller.stream;
  }

  Future<List<Note>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.notesTable,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'updatedAt DESC',
    );
    return maps.map(NoteModel.fromMap).toList();
  }

  Future<void> insert(Note note) async {
    final db = await _db;
    await db.insert(
      AppConstants.notesTable,
      NoteModel.fromNote(note).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notify();
  }

  Future<void> update(Note note) async {
    final db = await _db;
    await db.update(
      AppConstants.notesTable,
      NoteModel.fromNote(note).toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    await _notify();
  }

  Future<void> softDelete(String id) async {
    final db = await _db;
    await db.update(
      AppConstants.notesTable,
      {
        'isDeleted': 1,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _notify();
  }

  void dispose() => _controller.close();
}
