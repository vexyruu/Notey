import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/providers.dart';

class EmptyStateWidget extends ConsumerWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);

    final (icon, message) = switch (filter) {
      TaskFilter.all => (
          Icons.check_circle_outline,
          'No tasks yet.\nTap + to add one.'
        ),
      TaskFilter.active => (Icons.inbox_outlined, 'No active tasks.'),
      TaskFilter.completed => (
          Icons.emoji_events_outlined,
          'No completed tasks yet.'
        ),
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF34343D)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF464554),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
