import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/task.dart';
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
            opacity: task.isCompleted ? 0.5 : 1.0,
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
                      context: context,
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
                            decorationColor: context.onBg.withValues(alpha: 0.4),
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

class _MetaRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final segments = <Widget>[];

    segments.add(Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _priorityColor(task.priority),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
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
      segments.add(_dot(context));
      segments.add(Text(
        task.category!.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.08 * 11,
          color: kSlateGray,
        ),
      ));
    }

    if (task.dueDate != null) {
      segments.add(_dot(context));
      segments.add(_DateChip(task: task));
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 3,
      children: segments,
    );
  }

  Widget _dot(BuildContext context) => Text(
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

class _SquareCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final BuildContext context;

  const _SquareCheckbox({
    required this.value,
    required this.onChanged,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final fillColor = context.accentText;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: value ? fillColor : Colors.transparent,
          border: Border.all(
            color: value ? fillColor : context.outline,
            width: 1,
          ),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 13,
                color: context.isDark
                    ? const Color(0xFF07006C)
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}
