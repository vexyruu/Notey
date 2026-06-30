import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/label.dart';
import 'providers.dart';

// ── Label color palette ────────────────────────────────────────────────────
const kLabelColors = [
  Color(0xFF6366F1), // indigo
  Color(0xFFEF4444), // red
  Color(0xFFF97316), // orange
  Color(0xFFEAB308), // yellow
  Color(0xFF22C55E), // green
  Color(0xFF14B8A6), // teal
  Color(0xFF8B5CF6), // violet
  Color(0xFFEC4899), // pink
];

// ── Providers ──────────────────────────────────────────────────────────────

final labelsStreamProvider = StreamProvider<List<Label>>((ref) {
  return ref.watch(taskLocalDatasourceProvider).watchAllLabels();
});

final labelsProvider = Provider<List<Label>>((ref) {
  return ref.watch(labelsStreamProvider).value ?? [];
});

// ── Notifier for mutations ─────────────────────────────────────────────────

class LabelsNotifier extends AsyncNotifier<List<Label>> {
  @override
  Future<List<Label>> build() {
    // ref.read, not ref.watch — avoids re-triggering this notifier on every
    // stream emission (the UI uses labelsProvider directly for reactive updates)
    return ref.read(labelsStreamProvider.future);
  }

  Future<Label> createLabel(String name, int colorValue) async {
    final label = Label(
      id: const Uuid().v4(),
      name: name,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
    await ref.read(taskLocalDatasourceProvider).insertLabel(label);
    return label;
  }

  Future<void> deleteLabel(String id) async {
    await ref.read(taskLocalDatasourceProvider).deleteLabel(id);
  }
}

final labelsNotifierProvider =
    AsyncNotifierProvider<LabelsNotifier, List<Label>>(LabelsNotifier.new);
