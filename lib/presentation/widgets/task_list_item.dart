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

  const TaskListItem({
    super.key,
    required this.task,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(taskViewModelProvider.notifier);

    final content = Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kHairline)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(right: 10, top: 2),
              child: Icon(Icons.drag_handle, color: kOutlineVariant, size: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: _SquareCheckbox(
              value: task.isCompleted,
              onChanged: (_) => vm.toggleComplete(task),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(taskId: task.id)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.01 * 18,
                      height: 24 / 18,
                      color: task.isCompleted
                          ? const Color(0xFF908FA0)
                          : kOnBackground,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: const Color(0xFF908FA0),
                    ),
                  ),
                  if (task.category != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.category!.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1 * 11,
                        color: kSlateGray,
                      ),
                    ),
                  ],
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    _DueDateBadge(task: task),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
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
        child: task.isCompleted
            ? Opacity(opacity: 0.5, child: content)
            : content,
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final Task task;
  const _DueDateBadge({required this.task});

  bool get _isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
        task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    return due.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final color = _isOverdue && !task.isCompleted
        ? kError
        : kSlateGray;
    final dateStr = DateFormat('MMM d').format(task.dueDate!);
    final timeStr = task.hasTime
        ? '  ·  ${DateFormat('h:mm a').format(task.dueDate!)}'
        : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 11, color: color),
        const SizedBox(width: 4),
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
  const _SquareCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: value ? kPrimary : Colors.transparent,
          border: Border.all(
            color: value ? kPrimary : kOutlineVariant,
            width: 1,
          ),
        ),
        child: value
            ? const Icon(Icons.check, size: 13, color: Color(0xFF07006C))
            : null,
      ),
    );
  }
}
