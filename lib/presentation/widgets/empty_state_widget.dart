import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../viewmodels/providers.dart';

class EmptyStateWidget extends ConsumerWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskViewProvider);

    final (icon, message) = switch (view) {
      TaskView.today => (
          Icons.wb_sunny_outlined,
          'All done for today!\nAdd a task to stay on track.'
        ),
      TaskView.upcoming => (
          Icons.event_available_outlined,
          'Nothing coming up.\nSchedule a future task.'
        ),
      TaskView.all => (
          Icons.check_circle_outline,
          'No tasks yet.\nTap + to add one.'
        ),
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: kSlateGray),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: kSlateGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
