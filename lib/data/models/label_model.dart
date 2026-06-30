import '../../domain/entities/label.dart';

class LabelModel extends Label {
  const LabelModel({
    required super.id,
    required super.name,
    required super.colorValue,
    required super.createdAt,
  });

  factory LabelModel.fromMap(Map<String, dynamic> map) => LabelModel(
        id: map['id'] as String,
        name: map['name'] as String,
        colorValue: map['colorValue'] as int,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  static LabelModel fromLabel(Label label) => LabelModel(
        id: label.id,
        name: label.name,
        colorValue: label.colorValue,
        createdAt: label.createdAt,
      );
}
