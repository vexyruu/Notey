import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/label_providers.dart';
import '../viewmodels/task_viewmodel.dart';
import '../screens/task_detail_screen.dart';

class TaskListItem extends ConsumerWidget {
  final Task task;
  final int index;
  final bool isDraggable;

  const TaskListItem({
    super.key,
    required this.task,
    required this.index,
    this.isDraggable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(taskViewModelProvider.notifier);

    final card = Material(
      color: Colors.transparent,
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => vm.deleteTask(task.id),
              backgroundColor: const Color(0xFF93000A),
              foregroundColor: const Color(0xFFFFDAD6),
              icon: Icons.delete_outline,
              label: 'Delete',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => TaskDetailScreen(taskId: task.id)),
          ),
          child: Opacity(
            opacity: task.isCompleted ? 0.45 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: context.hairline)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: _SquareCheckbox(
                      value: task.isCompleted,
                      onChanged: (_) => vm.toggleComplete(task),
                      outerContext: context,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.01 * 17,
                            height: 1.35,
                            color: context.onBg,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor:
                                context.onBg.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        _MetaRow(task: task),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!isDraggable) return card;
    return ReorderableDelayedDragStartListener(
      index: index,
      child: card,
    );
  }
}

class _MetaRow extends ConsumerWidget {
  final Task task;
  const _MetaRow({required this.task});

  Color _priorityColor(Priority p) => switch (p) {
        Priority.high => kPriorityHigh,
        Priority.medium => kPriorityMedium,
        Priority.low => kPriorityLow,
      };

  String _priorityLabel(Priority p) => switch (p) {
        Priority.high => 'High',
        Priority.medium => 'Med',
        Priority.low => 'Low',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(labelsProvider);
    final segments = <Widget>[];

    // Priority: flag icon + text
    segments.add(Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag_rounded,
            size: 11, color: _priorityColor(task.priority)),
        const SizedBox(width: 3),
        Text(
          _priorityLabel(task.priority),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _priorityColor(task.priority),
          ),
        ),
      ],
    ));

    if (task.category != null) {
      final match =
          labels.where((l) => l.name == task.category).firstOrNull;
      final labelColor =
          match != null ? Color(match.colorValue) : kSlateGray;

      segments.add(_dot());
      // Label: pill badge with tinted background
      segments.add(Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: labelColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration:
                  BoxDecoration(color: labelColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 3),
            Text(
              task.category!,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ));
    }

    if (task.dueDate != null) {
      segments.add(_dot());
      segments.add(_DateChip(task: task));
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 3,
      children: segments,
    );
  }

  Widget _dot() => Text(
        '·',
        style: TextStyle(color: kSlateGray, fontSize: 11),
      );
}

class _DateChip extends StatelessWidget {
  final Task task;
  const _DateChip({required this.task});

  bool get _isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
        task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    return due.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _isOverdue && !task.isCompleted ? context.errorColor : kSlateGray;
    final dateStr = DateFormat('MMM d').format(task.dueDate!);
    final timeStr = task.hasTime
        ? ' · ${DateFormat('h:mm a').format(task.dueDate!)}'
        : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          '$dateStr$timeStr',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// StatefulWidget so we can show an optimistic checked state immediately on
// tap, before the async database write + stream roundtrip completes.
class _SquareCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final BuildContext outerContext;

  const _SquareCheckbox({
    required this.value,
    required this.onChanged,
    required this.outerContext,
  });

  @override
  State<_SquareCheckbox> createState() => _SquareCheckboxState();
}

class _SquareCheckboxState extends State<_SquareCheckbox> {
  bool? _optimistic; // null = no pending update; show widget.value

  @override
  void didUpdateWidget(_SquareCheckbox old) {
    super.didUpdateWidget(old);
    // Stream confirmed the new value — clear the optimistic override.
    if (old.value != widget.value) {
      _optimistic = null;
    }
  }

  void _handleTap() {
    final next = !(_optimistic ?? widget.value);
    setState(() => _optimistic = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext _) {
    final displayValue = _optimistic ?? widget.value;
    final fillColor = widget.outerContext.accentText;
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: displayValue ? fillColor : Colors.transparent,
          border: Border.all(
            color: displayValue ? fillColor : widget.outerContext.outline,
            width: 1,
          ),
        ),
        child: displayValue
            ? Icon(
                Icons.check,
                size: 13,
                color: widget.outerContext.isDark
                    ? const Color(0xFF07006C)
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}
