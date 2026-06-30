import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../viewmodels/providers.dart';

class FilterTabBar extends ConsumerWidget {
  const FilterTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(taskViewProvider);

    const tabs = [
      (TaskView.today, 'Today'),
      (TaskView.upcoming, 'Upcoming'),
      (TaskView.all, 'All'),
    ];

    return Row(
      children: tabs.map((entry) {
        final (view, label) = entry;
        final isSelected = current == view;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              ref.read(taskViewProvider.notifier).state = view;
              if (view == TaskView.upcoming) {
                ref.read(selectedCategoryProvider.notifier).state = null;
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? kElectricIndigo.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? kElectricIndigo.withValues(alpha: 0.35)
                      : context.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? kElectricIndigo : kSlateGray,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
