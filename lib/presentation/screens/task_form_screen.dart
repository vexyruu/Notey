import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/label.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/label_providers.dart';
import '../viewmodels/task_viewmodel.dart';
import '../widgets/app_dialog.dart';
import '../widgets/hsv_color_picker.dart';

const _kPresetColors = [
  Color(0xFF6366F1),
  Color(0xFF10B981),
  Color(0xFFF97316),
  Color(0xFFEF4444),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
];

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;
  final DateTime? initialDate;

  const TaskFormScreen({super.key, this.task, this.initialDate});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late Priority _priority;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _hasTime = false;
  String? _selectedLabel;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? Priority.low;
    _selectedLabel = t?.category;
    if (t?.dueDate != null) {
      _dueDate = t!.dueDate;
      _hasTime = t.hasTime;
      if (t.hasTime) {
        _dueTime =
            TimeOfDay(hour: t.dueDate!.hour, minute: t.dueDate!.minute);
      }
    } else if (widget.initialDate != null) {
      _dueDate = widget.initialDate;
    } else if (!_isEdit) {
      final now = DateTime.now();
      _dueDate = DateTime(now.year, now.month, now.day);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: kElectricIndigo)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueDate = _hasTime && _dueTime != null
            ? DateTime(picked.year, picked.month, picked.day,
                _dueTime!.hour, _dueTime!.minute)
            : picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: kElectricIndigo)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
        _hasTime = true;
        final base = _dueDate ?? DateTime.now();
        _dueDate = DateTime(
            base.year, base.month, base.day, picked.hour, picked.minute);
      });
    }
  }

  void _clearTime() {
    setState(() {
      _dueTime = null;
      _hasTime = false;
      if (_dueDate != null) {
        _dueDate =
            DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(taskViewModelProvider.notifier);
    final title = _titleCtrl.text.trim();
    final description =
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    final category = _selectedLabel;

    if (_isEdit) {
      await vm.updateTask(widget.task!.copyWith(
        title: title,
        description: description,
        clearDescription: description == null,
        priority: _priority,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        hasTime: _hasTime,
        category: category,
        clearCategory: category == null,
      ));
    } else {
      await vm.addTask(
        title: title,
        description: description,
        priority: _priority,
        dueDate: _dueDate,
        hasTime: _hasTime,
        category: category,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  String _dueDateLabel() {
    if (_dueDate == null) return 'Set date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
    if (due == today) return 'Today';
    if (due == today.add(const Duration(days: 1))) return 'Tomorrow';
    return DateFormat.MMMd().format(_dueDate!);
  }

  String _timeLabel() {
    if (_dueTime == null) return 'Set time';
    final h = _dueTime!.hour;
    final m = _dueTime!.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final subtleBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: context.subtleBorder),
    );
    const focusedBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: kElectricIndigo),
    );
    final labelStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1 * 11,
      color: kSlateGray,
    );

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.onBg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEdit ? 'Edit Task' : 'New Task',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.onBg,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.hairline),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              style: GoogleFonts.dmSans(
                color: context.onBg,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: GoogleFonts.dmSans(
                  color: context.hintText,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
                border: subtleBorder,
                enabledBorder: subtleBorder,
                focusedBorder: focusedBorder,
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.errorColor),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.errorColor),
                ),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 28),

            // Description
            TextFormField(
              controller: _descCtrl,
              style: GoogleFonts.inter(color: context.onBg, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Add details or notes...',
                hintStyle:
                    GoogleFonts.inter(color: context.hintText, fontSize: 15),
                border: subtleBorder,
                enabledBorder: subtleBorder,
                focusedBorder: focusedBorder,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              minLines: 2,
            ),
            const SizedBox(height: 36),

            // Priority
            Text('PRIORITY', style: labelStyle),
            const SizedBox(height: 12),
            Row(
              children: Priority.values.map((p) {
                final (label, color) = switch (p) {
                  Priority.low => ('Low', kPriorityLow),
                  Priority.medium => ('Medium', kPriorityMedium),
                  Priority.high => ('High', kPriorityHigh),
                };
                final isSelected = _priority == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.12)
                            : Colors.transparent,
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
                          Icon(Icons.flag_rounded, size: 12, color: color),
                          const SizedBox(width: 5),
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? color : kSlateGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // Due date + time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DUE DATE', style: labelStyle),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                color: kSlateGray, size: 17),
                            const SizedBox(width: 8),
                            Text(
                              _dueDateLabel(),
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _dueDate != null
                                    ? context.onBg
                                    : kSlateGray,
                              ),
                            ),
                            if (_dueDate != null) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _dueDate = null;
                                  _dueTime = null;
                                  _hasTime = false;
                                }),
                                child: Icon(Icons.close,
                                    color: kSlateGray, size: 15),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_dueDate != null) ...[
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TIME', style: labelStyle),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Row(
                          children: [
                            Icon(Icons.schedule_outlined,
                                color: kSlateGray, size: 17),
                            const SizedBox(width: 8),
                            Text(
                              _timeLabel(),
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    _hasTime ? context.onBg : kSlateGray,
                              ),
                            ),
                            if (_hasTime) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _clearTime,
                                child: Icon(Icons.close,
                                    color: kSlateGray, size: 15),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 36),

            // Label picker
            Text('LABEL', style: labelStyle),
            const SizedBox(height: 12),
            _LabelPicker(
              selectedLabel: _selectedLabel,
              onChanged: (name) => setState(() => _selectedLabel = name),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit,
        backgroundColor: kElectricIndigo,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.check, size: 28),
      ),
    );
  }
}

// ── Label picker widget ─────────────────────────────────────────────────────

class _LabelPicker extends ConsumerStatefulWidget {
  final String? selectedLabel;
  final ValueChanged<String?> onChanged;

  const _LabelPicker({
    required this.selectedLabel,
    required this.onChanged,
  });

  @override
  ConsumerState<_LabelPicker> createState() => _LabelPickerState();
}

class _LabelPickerState extends ConsumerState<_LabelPicker> {
  // Tracks which label is visually "held" during a long-press gesture
  String? _heldLabelId;

  Future<void> _showCreateDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateLabelDialog(),
    );
    if (result != null) widget.onChanged(result);
  }

  Future<void> _confirmDelete(Label label) async {
    setState(() => _heldLabelId = null);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteLabelDialog(labelName: label.name),
    );
    if (confirmed == true) {
      if (widget.selectedLabel == label.name) widget.onChanged(null);
      ref.read(labelsNotifierProvider.notifier).deleteLabel(label.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(labelsProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: [
        ...labels.map((label) {
          final color = Color(label.colorValue);
          final isSelected = widget.selectedLabel == label.name;
          final isHeld = _heldLabelId == label.id;
          return GestureDetector(
            onTap: () {
              setState(() => _heldLabelId = null);
              widget.onChanged(isSelected ? null : label.name);
            },
            onLongPressStart: (_) =>
                setState(() => _heldLabelId = label.id),
            onLongPress: () => _confirmDelete(label),
            onLongPressEnd: (_) =>
                setState(() => _heldLabelId = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isHeld
                    ? context.errorColor.withValues(alpha: 0.10)
                    : isSelected
                        ? color.withValues(alpha: 0.12)
                        : Colors.transparent,
                border: Border.all(
                  color: isHeld
                      ? context.errorColor.withValues(alpha: 0.45)
                      : isSelected
                          ? color.withValues(alpha: 0.5)
                          : context.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: isHeld ? context.errorColor : color,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    label.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isHeld
                          ? context.errorColor
                          : isSelected
                              ? color
                              : kSlateGray,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // "New label" button
        GestureDetector(
          onTap: _showCreateDialog,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.outline.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 15, color: kSlateGray),
                const SizedBox(width: 5),
                Text(
                  'New label',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: kSlateGray),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Create-label dialog ─────────────────────────────────────────────────────

class _CreateLabelDialog extends ConsumerStatefulWidget {
  const _CreateLabelDialog();

  @override
  ConsumerState<_CreateLabelDialog> createState() =>
      _CreateLabelDialogState();
}

class _CreateLabelDialogState extends ConsumerState<_CreateLabelDialog> {
  final _nameCtrl = TextEditingController();
  Color _selectedColor = const Color(0xFF6366F1);

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    ref.read(labelsNotifierProvider.notifier).createLabel(
          name,
          _selectedColor.toARGB32(),
        );
    Navigator.of(context).pop(name);
  }

  String get _hexPreview {
    final c = _selectedColor;
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final capStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1 * 11,
      color: kSlateGray,
    );

    return AppDialog(
      title: 'New Label',
      contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name label + field ──
          Text('NAME', style: capStyle),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _submit(),
            style: GoogleFonts.inter(color: context.onBg, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'e.g. Design Sprint',
              hintStyle: GoogleFonts.inter(
                  color: context.hintText, fontSize: 15),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.subtleBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kElectricIndigo),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ── Appearance label + hex preview ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('APPEARANCE', style: capStyle),
              Row(
                children: [
                  Text(
                    _hexPreview,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: kSlateGray,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _selectedColor.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── HSV picker (no bottom preview — we show hex in header) ──
          HsvColorPicker(
            initialColor: _selectedColor,
            onChanged: (c) => setState(() => _selectedColor = c),
            showPreview: false,
          ),
          const SizedBox(height: 14),

          // ── Preset swatches ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _kPresetColors.map((c) {
              final isActive = _selectedColor.toARGB32() == c.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(6),
                    border: isActive
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                                color: c.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1)
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
      actions: [
        AppDialogCancelButton(),
        const SizedBox(width: 8),
        AppDialogConfirmButton(label: 'Create Label', onPressed: _submit),
      ],
    );
  }
}

// ── Delete-label confirmation dialog ───────────────────────────────────────

class _DeleteLabelDialog extends StatelessWidget {
  final String labelName;
  const _DeleteLabelDialog({required this.labelName});

  @override
  Widget build(BuildContext context) {
    return AppDeleteDialog(
      entityType: 'Label?',
      description:
          'Remove "$labelName"? Tasks with this label will keep the name.',
    );
  }
}
