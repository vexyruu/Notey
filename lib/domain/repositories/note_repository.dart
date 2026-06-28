import '../entities/note.dart';

abstract class NoteRepository {
  Stream<List<Note>> watchAllNotes();
  Future<List<Note>> getAllNotes();
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}
