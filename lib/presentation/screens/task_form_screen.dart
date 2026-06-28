import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/task_viewmodel.dart';

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
  late final TextEditingController _categoryCtrl;
  late Priority _priority;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _hasTime = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _categoryCtrl = TextEditingController(text: t?.category ?? '');
    _priority = t?.priority ?? Priority.low;
    if (t?.dueDate != null) {
      _dueDate = t!.dueDate;
      _hasTime = t.hasTime;
      if (t.hasTime) {
        _dueTime = TimeOfDay(hour: t.dueDate!.hour, minute: t.dueDate!.minute);
      }
    } else if (widget.initialDate != null) {
      _dueDate = widget.initialDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context)
            .copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kElectricIndigo,
                )),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueDate = _hasTime && _dueTime != null
            ? DateTime(picked.year, picked.month, picked.day, _dueTime!.hour,
                _dueTime!.minute)
            : picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context)
            .copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kElectricIndigo,
                )),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
        _hasTime = true;
        final base = _dueDate ?? DateTime.now();
        _dueDate =
            DateTime(base.year, base.month, base.day, picked.hour, picked.minute);
      });
    }
  }

  void _clearTime() {
    setState(() {
      _dueTime = null;
      _hasTime = false;
      if (_dueDate != null) {
        _dueDate = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(taskViewModelProvider.notifier);
    final title = _titleCtrl.text.trim();
    final description =
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    final category =
        _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim();

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
    final labelStyle = TextStyle(
      color: kSlateGray,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1 * 12,
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
          'Notey',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02 * 20,
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
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
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
                children: _isEdit
                    ? [
                        TextSpan(
                          text: 'Edit',
                          style: GoogleFonts.playfairDisplay(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: kElectricIndigo,
                            fontSize: 40,
                            height: 1.2,
                          ),
                        ),
                        const TextSpan(text: ' Task'),
                      ]
                    : [
                        const TextSpan(text: 'Create '),
                        TextSpan(
                          text: 'New',
                          style: GoogleFonts.playfairDisplay(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: kElectricIndigo,
                            fontSize: 40,
                            height: 1.2,
                          ),
                        ),
                        const TextSpan(text: ' Task'),
                      ],
              ),
            ),
            const SizedBox(height: 48),
            TextFormField(
              controller: _titleCtrl,
              style: GoogleFonts.dmSans(
                color: context.onBg,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: GoogleFonts.dmSans(
                  color: context.hintText,
                  fontSize: 24,
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
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _descCtrl,
              style: GoogleFonts.inter(color: context.onBg, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Add details or notes...',
                hintStyle: GoogleFonts.inter(
                  color: context.hintText,
                  fontSize: 16,
                ),
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
            const SizedBox(height: 40),
            Text('PRIORITY', style: labelStyle),
            const SizedBox(height: 10),
            Row(
              children: Priority.values.map((p) {
                final label = switch (p) {
                  Priority.low => 'Low',
                  Priority.medium => 'Medium',
                  Priority.high => 'High',
                };
                final isSelected = _priority == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? context.onBg : kSlateGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
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
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DUE DATE', style: labelStyle),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                color: kSlateGray, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _dueDateLabel(),
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
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
                                    color: kSlateGray, size: 16),
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
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Row(
                          children: [
                            Icon(Icons.schedule_outlined,
                                color: kSlateGray, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _timeLabel(),
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
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
                                    color: kSlateGray, size: 16),
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
            const SizedBox(height: 40),
            Text('CATEGORY', style: labelStyle),
            const SizedBox(height: 10),
            TextFormField(
              controller: _categoryCtrl,
              style: GoogleFonts.inter(color: context.onBg, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Work, Personal, Health...',
                hintStyle: GoogleFonts.inter(
                  color: context.hintText,
                  fontSize: 16,
                ),
                border: subtleBorder,
                enabledBorder: subtleBorder,
                focusedBorder: focusedBorder,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              textCapitalization: TextCapitalization.words,
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
