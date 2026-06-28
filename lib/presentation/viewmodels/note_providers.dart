import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/local/note_local_datasource.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import 'providers.dart';

final noteDatasourceProvider = Provider<NoteLocalDatasource>((ref) {
  final taskDs = ref.watch(taskLocalDatasourceProvider);
  final ds = NoteLocalDatasource(taskDs);
  ref.onDispose(ds.dispose);
  return ds;
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(ref.watch(noteDatasourceProvider));
});

final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchAllNotes();
});

final noteByIdProvider = Provider.family<Note?, String>((ref, id) {
  final notes = ref.watch(notesStreamProvider).value ?? [];
  try {
    return notes.firstWhere((n) => n.id == id);
  } catch (_) {
    return null;
  }
});

class NoteViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addNote({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    await ref.read(noteRepositoryProvider).addNote(Note(
          id: const Uuid().v4(),
          title: title,
          content: content,
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<void> updateNote(Note note) async {
    await ref
        .read(noteRepositoryProvider)
        .updateNote(note.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteNote(String id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
  }
}

final noteViewModelProvider =
    AsyncNotifierProvider<NoteViewModel, void>(NoteViewModel.new);

final noteSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesStreamProvider);
  final query = ref.watch(noteSearchQueryProvider).trim().toLowerCase();
  return notesAsync.whenData((notes) {
    if (query.isEmpty) return notes;
    return notes
        .where((n) =>
            n.title.toLowerCase().contains(query) ||
            n.content.toLowerCase().contains(query))
        .toList();
  });
});
