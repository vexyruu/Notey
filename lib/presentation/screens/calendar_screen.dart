import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/providers.dart';
import '../widgets/task_list_item.dart';
import 'task_form_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final tasks = tasksAsync.value ?? [];

    final eventMap = <DateTime, List<Task>>{};
    for (final t in tasks) {
      if (t.dueDate != null && !t.isDeleted) {
        final key = _dayKey(t.dueDate!);
        (eventMap[key] ??= []).add(t);
      }
    }

    List<Task> selectedTasks() {
      return eventMap[_dayKey(_selectedDay)] ?? [];
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kOnBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Calendar',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: kOnBackground,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: kHairline),
        ),
      ),
      body: Column(
        children: [
          TableCalendar<Task>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => eventMap[_dayKey(day)] ?? [],
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            }),
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: GoogleFonts.inter(
                  fontSize: 14, color: kOnBackground),
              weekendTextStyle: GoogleFonts.inter(
                  fontSize: 14, color: kOnBackground),
              selectedDecoration: const BoxDecoration(
                color: kElectricIndigo,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
              todayDecoration: BoxDecoration(
                color: kElectricIndigo.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              todayTextStyle: GoogleFonts.inter(
                  fontSize: 14, color: kPrimary, fontWeight: FontWeight.w600),
              markerDecoration: const BoxDecoration(
                color: kPrimary,
                shape: BoxShape.circle,
              ),
              markerSize: 5,
              markerMargin: const EdgeInsets.symmetric(horizontal: 1),
              cellMargin: const EdgeInsets.all(4),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kOnBackground,
              ),
              leftChevronIcon:
                  const Icon(Icons.chevron_left, color: kOnBackground),
              rightChevronIcon:
                  const Icon(Icons.chevron_right, color: kOnBackground),
              headerPadding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(color: kBackground),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kSlateGray),
              weekendStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kSlateGray),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => _DayCell(day: day),
              outsideBuilder: (context, day, focusedDay) =>
                  _DayCell(day: day, muted: true),
            ),
          ),
          const Divider(height: 1, color: kHairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(_selectedDay),
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kOnBackground,
                  ),
                ),
                const Spacer(),
                if (selectedTasks().isNotEmpty)
                  Text(
                    '${selectedTasks().length} task${selectedTasks().length == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: kSlateGray),
                  ),
              ],
            ),
          ),
          Expanded(
            child: selectedTasks().isEmpty
                ? Center(
                    child: Text(
                      'No tasks for this day',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: kSlateGray),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: selectedTasks().length,
                    itemBuilder: (context, i) => TaskListItem(
                      key: ValueKey(selectedTasks()[i].id),
                      task: selectedTasks()[i],
                      index: i,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(initialDate: _selectedDay),
            ),
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

  DateTime _dayKey(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool muted;
  const _DayCell({required this.day, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${day.day}',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: muted ? kOutlineVariant : kOnBackground,
        ),
      ),
    );
  }
}
