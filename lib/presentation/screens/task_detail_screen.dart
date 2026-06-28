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
      return const Scaffold(
        backgroundColor: kSurface,
        body: Center(
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
        Priority.high => const Color(0xFFFFB4AB),   // error token
        Priority.medium => const Color(0xFFFFB86C),
        Priority.low => const Color(0xFF4EDEA3),     // secondary
      };

  String _priorityLabel(Priority p) => switch (p) {
        Priority.high => 'High',
        Priority.medium => 'Medium',
        Priority.low => 'Low',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(taskViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kOnBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notey',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02 * 20,
            color: kOnBackground,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0x1AFFFFFF)),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: kOnBackground),
            color: kSurfaceContainerHigh,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        color: Color(0xFFFFB4AB), size: 18),
                    const SizedBox(width: 10),
                    Text('Delete',
                        style: GoogleFonts.inter(
                            color: const Color(0xFFFFB4AB))),
                  ],
                ),
              ),
            ],
            onSelected: (v) async {
              if (v == 'delete') {
                await vm.deleteTask(task.id);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? const Color(0xFF4EDEA3)
                        : kElectricIndigo,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  task.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1 * 12,
                    color: task.isCompleted
                        ? const Color(0xFF4EDEA3)
                        : kElectricIndigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              task.title,
              style: GoogleFonts.dmSans(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.03 * 26,
                color: kOnBackground,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoCell(
                    label: 'PRIORITY',
                    child: Row(
                      children: [
                        Icon(Icons.flag_rounded,
                            size: 14,
                            color: _priorityColor(task.priority)),
                        const SizedBox(width: 6),
                        Text(
                          _priorityLabel(task.priority),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _priorityColor(task.priority),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (task.category != null)
                  Expanded(
                    child: _InfoCell(
                      label: 'CATEGORY',
                      child: Text(
                        task.category!,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: kOnBackground,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (task.dueDate != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _InfoCell(
                      label: 'DUE DATE',
                      child: Text(
                        DateFormat('MMM d, yyyy').format(task.dueDate!),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: kOnBackground,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: task.hasTime
                        ? _InfoCell(
                            label: 'TIME',
                            child: Text(
                              DateFormat('h:mm a').format(task.dueDate!),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: kOnBackground,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ],
            if (task.description != null) ...[
              const SizedBox(height: 28),
              Divider(color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(height: 20),
              Text(
                task.description!,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFFC7C4D7),
                  height: 1.65,
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: kSurface,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  await vm.deleteTask(task.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFFFFB4AB), size: 17),
                label: Text(
                  'Delete Task',
                  style: GoogleFonts.inter(
                      color: const Color(0xFFFFB4AB), fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => vm.toggleComplete(task),
                style: TextButton.styleFrom(
                  foregroundColor: kOnBackground,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  task.isCompleted ? 'Mark Undone' : 'Mark as Done',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => TaskFormScreen(task: task)),
                ),
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: Text('Edit Task',
                    style: GoogleFonts.inter(fontSize: 13)),
                style: FilledButton.styleFrom(
                  backgroundColor: kElectricIndigo,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoCell({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1 * 11,
            color: kSlateGray,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
