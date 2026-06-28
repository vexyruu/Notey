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
      (TaskView.active, 'Active'),
      (TaskView.done, 'Done'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((entry) {
          final (view, label) = entry;
          final isSelected = current == view;
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () {
                ref.read(taskViewProvider.notifier).state = view;
                // Clear category selection when switching to upcoming
                if (view == TaskView.upcoming) {
                  ref.read(selectedCategoryProvider.notifier).state = null;
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? context.onBg : kSlateGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 4 : 0,
                    height: isSelected ? 4 : 0,
                    decoration: const BoxDecoration(
                      color: kElectricIndigo,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
