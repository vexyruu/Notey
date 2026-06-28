import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../viewmodels/providers.dart';

class FilterTabBar extends ConsumerWidget {
  const FilterTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(taskFilterProvider);
    return Row(
      children: TaskFilter.values.map((filter) {
        final label = switch (filter) {
          TaskFilter.all => 'All',
          TaskFilter.active => 'Active',
          TaskFilter.completed => 'Done',
        };
        final isSelected = current == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 24),
          child: GestureDetector(
            onTap: () =>
                ref.read(taskFilterProvider.notifier).state = filter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? kOnBackground : kSlateGray,
                    letterSpacing: 0,
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
    );
  }
}
