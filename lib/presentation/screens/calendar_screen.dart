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

  DateTime _dayKey(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksStreamProvider).value ?? [];

    final eventMap = <DateTime, List<Task>>{};
    for (final t in tasks) {
      if (t.dueDate != null && !t.isDeleted) {
        final key = _dayKey(t.dueDate!);
        (eventMap[key] ??= []).add(t);
      }
    }

    final selectedTasks = eventMap[_dayKey(_selectedDay)] ?? [];

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
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
                            text: 'Calendar',
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
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedDay),
                      style: GoogleFonts.inter(
                          fontSize: 14, color: kSlateGray),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TableCalendar<Task>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day),
                  eventLoader: (day) => eventMap[_dayKey(day)] ?? [],
                  onDaySelected: (selected, focused) => setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  }),
                  onPageChanged: (focused) =>
                      setState(() => _focusedDay = focused),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: GoogleFonts.inter(
                        fontSize: 14, color: context.onBg),
                    weekendTextStyle: GoogleFonts.inter(
                        fontSize: 14, color: context.onBg),
                    selectedDecoration: const BoxDecoration(
                      color: kElectricIndigo,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                    todayDecoration: BoxDecoration(
                      color: kElectricIndigo.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: kElectricIndigo,
                        fontWeight: FontWeight.w600),
                    markerDecoration: const BoxDecoration(
                      color: kElectricIndigo,
                      shape: BoxShape.circle,
                    ),
                    markerSize: 5,
                    markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                    cellMargin: const EdgeInsets.all(4),
                    outsideTextStyle: GoogleFonts.inter(
                        fontSize: 14, color: context.outline),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.onBg,
                    ),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: context.onBg),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: context.onBg),
                    headerPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: Colors.transparent),
                    headerMargin: EdgeInsets.zero,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: kSlateGray),
                    weekendStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: kSlateGray),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: kElectricIndigo,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, MMMM d').format(_selectedDay),
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.onBg,
                      ),
                    ),
                    const Spacer(),
                    if (selectedTasks.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kElectricIndigo.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${selectedTasks.length}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kElectricIndigo,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (selectedTasks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Nothing scheduled',
                    style:
                        GoogleFonts.inter(fontSize: 14, color: kSlateGray),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => TaskListItem(
                    key: ValueKey(selectedTasks[i].id),
                    task: selectedTasks[i],
                    index: i,
                    isDraggable: false,
                  ),
                  childCount: selectedTasks.length,
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          heroTag: null,
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
}
