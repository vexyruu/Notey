import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    super.isDeleted = false,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  static NoteModel fromNote(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isDeleted: note.isDeleted,
    );
  }
}
