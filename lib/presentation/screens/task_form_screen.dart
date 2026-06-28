import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/task_viewmodel.dart';

const _kEnabledBorder = UnderlineInputBorder(
  borderSide: BorderSide(color: Color(0x1AFFFFFF)),
);
const _kFocusedBorder = UnderlineInputBorder(
  borderSide: BorderSide(color: kElectricIndigo),
);
const _kLabelStyle = TextStyle(
  color: kSlateGray,
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.1 * 12,
);

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
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kElectricIndigo,
            surface: kSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        if (_hasTime && _dueTime != null) {
          _dueDate = DateTime(
              picked.year, picked.month, picked.day,
              _dueTime!.hour, _dueTime!.minute);
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kElectricIndigo,
            surface: kSurface,
            onSurface: kOnBackground,
          ),
        ),
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
        _dueDate = DateTime(
            _dueDate!.year, _dueDate!.month, _dueDate!.day);
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
    final min = m.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kOnBackground),
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
                  color: kOnBackground,
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
                color: kOnBackground,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: GoogleFonts.dmSans(
                  color: const Color(0xFF34343D),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                border: _kEnabledBorder,
                enabledBorder: _kEnabledBorder,
                focusedBorder: _kFocusedBorder,
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kError),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kError),
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
              style: GoogleFonts.inter(color: kOnBackground, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Add details or notes...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF34343D),
                  fontSize: 16,
                ),
                border: _kEnabledBorder,
                enabledBorder: _kEnabledBorder,
                focusedBorder: _kFocusedBorder,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              minLines: 2,
            ),
            const SizedBox(height: 40),
            const Text('PRIORITY', style: _kLabelStyle),
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
                            color:
                                isSelected ? kOnBackground : kSlateGray,
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
                      const Text('DUE DATE', style: _kLabelStyle),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: kSlateGray, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _dueDateLabel(),
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: _dueDate != null
                                    ? kOnBackground
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
                                child: const Icon(Icons.close,
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
                      const Text('TIME', style: _kLabelStyle),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_outlined,
                                color: kSlateGray, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _timeLabel(),
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color:
                                    _hasTime ? kOnBackground : kSlateGray,
                              ),
                            ),
                            if (_hasTime) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _clearTime,
                                child: const Icon(Icons.close,
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
            const Text('CATEGORY', style: _kLabelStyle),
            const SizedBox(height: 10),
            TextFormField(
              controller: _categoryCtrl,
              style: GoogleFonts.inter(color: kOnBackground, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Work, Personal, Health...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF34343D),
                  fontSize: 16,
                ),
                border: _kEnabledBorder,
                enabledBorder: _kEnabledBorder,
                focusedBorder: _kFocusedBorder,
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
