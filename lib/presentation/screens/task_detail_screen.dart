import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/providers.dart';
import '../viewmodels/task_viewmodel.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdProvider(taskId));

    if (task == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(
          child: CircularProgressIndicator(color: kElectricIndigo),
        ),
      );
    }

    return _TaskDetailView(task: task);
  }
}

class _TaskDetailView extends ConsumerWidget {
  final Task task;
  const _TaskDetailView({required this.task});

  Color _priorityColor(Priority p) => switch (p) {
        Priority.high => kPriorityHigh,
        Priority.medium => kPriorityMedium,
        Priority.low => kPriorityLow,
      };

  String _priorityLabel(Priority p) => switch (p) {
        Priority.high => 'High',
        Priority.medium => 'Medium',
        Priority.low => 'Low',
      };

  bool get _isOverdue {
    if (task.dueDate == null || task.isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
        task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    return due.isBefore(today);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(taskViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.onBg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: context.onBg, size: 20),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => TaskFormScreen(task: task)),
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.delete_outline, color: context.errorColor, size: 20),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: context.surfaceContainerHigh,
                  title: Text('Delete task?',
                      style: GoogleFonts.dmSans(color: context.onBg)),
                  content: Text('This cannot be undone.',
                      style: GoogleFonts.inter(
                          color: kSlateGray, fontSize: 14)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text('Cancel',
                          style: GoogleFonts.inter(color: kSlateGray)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('Delete',
                          style:
                              GoogleFonts.inter(color: context.errorColor)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await vm.deleteTask(task.id);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                    text: 'Task',
                    style: GoogleFonts.playfairDisplay(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: context.accentText,
                      fontSize: 40,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: context.hairline),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? kPriorityLow
                        : _isOverdue
                            ? kPriorityHigh
                            : kElectricIndigo,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  task.isCompleted
                      ? 'COMPLETED'
                      : _isOverdue
                          ? 'OVERDUE'
                          : 'IN PROGRESS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1 * 11,
                    color: task.isCompleted
                        ? kPriorityLow
                        : _isOverdue
                            ? kPriorityHigh
                            : kElectricIndigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              task.title,
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.03 * 28,
                color: context.onBg,
                height: 1.25,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: context.onBg.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.flag_rounded,
                    iconColor: _priorityColor(task.priority),
                    label: 'Priority',
                    value: _priorityLabel(task.priority),
                    valueColor: _priorityColor(task.priority),
                  ),
                  if (task.category != null) ...[
                    Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: context.hairline),
                    _InfoRow(
                      icon: Icons.label_outline,
                      iconColor: kElectricIndigo,
                      label: 'Category',
                      value: task.category!,
                    ),
                  ],
                  if (task.dueDate != null) ...[
                    Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: context.hairline),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: _isOverdue && !task.isCompleted
                          ? kPriorityHigh
                          : kElectricIndigo,
                      label: 'Due date',
                      value: DateFormat('EEEE, MMM d yyyy')
                          .format(task.dueDate!),
                      valueColor: _isOverdue && !task.isCompleted
                          ? kPriorityHigh
                          : null,
                    ),
                    if (task.hasTime) ...[
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: context.hairline),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        iconColor: kElectricIndigo,
                        label: 'Time',
                        value: DateFormat('h:mm a').format(task.dueDate!),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (task.description != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.08 * 11,
                        color: kSlateGray,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      task.description!,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: context.onBg,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () => vm.toggleComplete(task),
              icon: Icon(
                task.isCompleted
                    ? Icons.refresh_rounded
                    : Icons.check_rounded,
                size: 18,
              ),
              label: Text(
                task.isCompleted ? 'Mark as Undone' : 'Mark as Done',
                style: GoogleFonts.dmSans(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    task.isCompleted ? context.surfaceContainerHigh : kElectricIndigo,
                foregroundColor:
                    task.isCompleted ? context.onBg : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: kSlateGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? context.onBg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
