import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/providers.dart';
import '../viewmodels/task_viewmodel.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_tab_bar.dart';
import '../widgets/task_list_item.dart';
import 'task_form_screen.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskViewProvider);
    final tasksAsync = ref.watch(unifiedFilteredProvider);
    final proxyColor = context.surfaceContainer;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: tasksAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: kElectricIndigo)),
          error: (e, _) => Center(
              child: Text('Error: $e', style: TextStyle(color: kSlateGray))),
          data: (tasks) {
            final categories = ref.watch(availableCategoriesProvider);
            final selectedCategory = ref.watch(selectedCategoryProvider);

            final (italicWord, suffix) = switch (view) {
              TaskView.today => ('Focus', ' Today'),
              TaskView.upcoming => ('Upcoming', ''),
              _ => ('Tasks', ''),
            };

            final subtitle = switch (view) {
              TaskView.today =>
                '${tasks.length} task${tasks.length == 1 ? '' : 's'} due',
              TaskView.upcoming =>
                '${tasks.length} task${tasks.length == 1 ? '' : 's'} scheduled',
              TaskView.all =>
                '${tasks.length} task${tasks.length == 1 ? '' : 's'} total',
              TaskView.active =>
                '${tasks.length} active',
              TaskView.done =>
                '${tasks.length} completed',
            };

            // Build flat list for upcoming (date-group headers interleaved)
            final List<dynamic> upcomingFlat = [];
            if (view == TaskView.upcoming && tasks.isNotEmpty) {
              final grouped = <DateTime, List<Task>>{};
              for (final t in tasks) {
                final key = DateTime(
                    t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
                (grouped[key] ??= []).add(t);
              }
              for (final entry in grouped.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key))) {
                upcomingFlat.add(entry.key);
                upcomingFlat.addAll(entry.value);
              }
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.04 * 40,
                              color: context.onBg,
                              height: 1.2,
                            ),
                            children: [
                              const TextSpan(text: 'Your '),
                              TextSpan(
                                text: italicWord,
                                style: GoogleFonts.playfairDisplay(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: context.accentText,
                                  fontSize: 40,
                                  height: 1.2,
                                ),
                              ),
                              if (suffix.isNotEmpty) TextSpan(text: suffix),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: kSlateGray),
                        ),
                        const SizedBox(height: 28),
                        const FilterTabBar(),
                        if (view != TaskView.upcoming &&
                            categories.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _CategoryRow(
                            categories: categories,
                            selectedCategory: selectedCategory,
                            onSelect: (c) => ref
                                .read(selectedCategoryProvider.notifier)
                                .state = c,
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (tasks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(),
                  )
                else if (view == TaskView.upcoming)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = upcomingFlat[i];
                        if (item is DateTime) {
                          return _DateGroupHeader(
                              label: _groupLabel(item));
                        }
                        final task = item as Task;
                        return TaskListItem(
                          key: ValueKey(task.id),
                          task: task,
                          index: i,
                          isDraggable: false,
                        );
                      },
                      childCount: upcomingFlat.length,
                    ),
                  )
                else if (view == TaskView.today)
                  SliverReorderableList(
                    itemCount: tasks.length,
                    onReorderItem: (oldIndex, newIndex) => ref
                        .read(taskViewModelProvider.notifier)
                        .reorderTasks(tasks, oldIndex, newIndex),
                    itemBuilder: (context, index) => TaskListItem(
                      key: ValueKey(tasks[index].id),
                      task: tasks[index],
                      index: index,
                    ),
                    proxyDecorator: (child, index, animation) =>
                        Material(color: proxyColor, child: child),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => TaskListItem(
                        key: ValueKey(tasks[i].id),
                        task: tasks[i],
                        index: i,
                        isDraggable: false,
                      ),
                      childCount: tasks.length,
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          ),
          backgroundColor: kElectricIndigo,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final diff = date.difference(today).inDays;
    if (date == tomorrow) return 'Tomorrow';
    if (diff <= 6) return DateFormat('EEEE').format(date);
    return DateFormat('EEE, MMM d').format(date);
  }
}

class _CategoryRow extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelect;
  const _CategoryRow({
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () => onSelect(null),
          ),
          ...categories.map((c) => _Chip(
                label: c,
                isSelected: selectedCategory == c,
                onTap: () => onSelect(selectedCategory == c ? null : c),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? kElectricIndigo.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? kElectricIndigo : context.outline,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? kElectricIndigo : kSlateGray,
          ),
        ),
      ),
    );
  }
}

class _DateGroupHeader extends StatelessWidget {
  final String label;
  const _DateGroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.08 * 11,
              color: kSlateGray,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: context.hairline, height: 1)),
        ],
      ),
    );
  }
}
