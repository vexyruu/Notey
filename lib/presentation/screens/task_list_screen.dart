import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/label.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/label_providers.dart';
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
              child: Text('Error: $e',
                  style: TextStyle(color: kSlateGray))),
          data: (tasks) {
            final labels = ref.watch(labelsProvider);
            final selectedLabel = ref.watch(selectedLabelProvider);

            // Hero heading
            final (italicWord, suffix) = switch (view) {
              TaskView.today => ('Focus', ' Today'),
              TaskView.upcoming => ('Upcoming', ''),
              TaskView.all => ('Tasks', ''),
            };

            // Subtitle
            final subtitle = switch (view) {
              TaskView.today =>
                '${tasks.length} task${tasks.length == 1 ? '' : 's'} due',
              TaskView.upcoming =>
                '${tasks.length} task${tasks.length == 1 ? '' : 's'} scheduled',
              TaskView.all => () {
                  final active = tasks.where((t) => !t.isCompleted).length;
                  final done = tasks.where((t) => t.isCompleted).length;
                  return '$active active · $done done';
                }(),
            };

            // Flat list for upcoming grouped by date
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
                // ── Header ──────────────────────────────────────────
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
                              if (suffix.isNotEmpty)
                                TextSpan(text: suffix),
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

                        // ── Filter tabs ────────────────────────────
                        const FilterTabBar(),

                        // ── Label filter chips (not in upcoming) ───
                        if (view != TaskView.upcoming &&
                            labels.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _LabelFilterRow(
                            labels: labels,
                            selectedLabel: selectedLabel,
                            onSelect: (name) => ref
                                .read(selectedLabelProvider.notifier)
                                .state = name,
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // ── Task list ────────────────────────────────────────
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
                        return TaskListItem(
                          key: ValueKey((item as Task).id),
                          task: item,
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

                const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
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

// ── Label filter row ───────────────────────────────────────────────────────

class _LabelFilterRow extends StatelessWidget {
  final List<Label> labels;
  final String? selectedLabel;
  final ValueChanged<String?> onSelect;

  const _LabelFilterRow({
    required this.labels,
    required this.selectedLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _LabelChip(
            label: 'All',
            color: kElectricIndigo,
            isSelected: selectedLabel == null,
            onTap: () => onSelect(null),
          ),
          ...labels.map((l) {
            final color = Color(l.colorValue);
            return _LabelChip(
              label: l.name,
              color: color,
              isSelected: selectedLabel == l.name,
              onTap: () =>
                  onSelect(selectedLabel == l.name ? null : l.name),
            );
          }),
        ],
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _LabelChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : context.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? color : kSlateGray,
              ),
            ),
          ],
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
