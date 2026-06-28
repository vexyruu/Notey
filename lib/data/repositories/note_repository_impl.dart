import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/note_local_datasource.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDatasource _local;
  NoteRepositoryImpl(this._local);

  @override
  Stream<List<Note>> watchAllNotes() => _local.watchAll();

  @override
  Future<List<Note>> getAllNotes() => _local.getAll();

  @override
  Future<void> addNote(Note note) => _local.insert(note);

  @override
  Future<void> updateNote(Note note) => _local.update(note);

  @override
  Future<void> deleteNote(String id) => _local.softDelete(id);
}
