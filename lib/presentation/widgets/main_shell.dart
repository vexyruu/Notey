import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../screens/calendar_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/task_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    TaskListScreen(),
    CalendarScreen(),
    NotesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _FloatingNav(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
          ),
        ),
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.format_list_bulleted_rounded, 'Tasks'),
      (Icons.calendar_month_outlined, 'Calendar'),
      (Icons.sticky_note_2_outlined, 'Notes'),
      (Icons.person_outline, 'Profile'),
    ];

    final navBg = context.isDark
        ? const Color(0xFF1F1F27)
        : Colors.white;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.28 : 0.07),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / 4;
            final pillLeft = currentIndex * itemWidth + 2;
            final pillWidth = itemWidth - 4;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  left: pillLeft,
                  top: 0,
                  bottom: 0,
                  width: pillWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kElectricIndigo,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(items.length, (i) {
                    final (icon, label) = items[i];
                    final isActive = i == currentIndex;
                    return SizedBox(
                      width: itemWidth,
                      child: GestureDetector(
                        onTap: () => onTap(i),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(
                                      scale: anim
                                          .drive(Tween(begin: 0.75, end: 1.0)),
                                      child: FadeTransition(
                                          opacity: anim, child: child)),
                              child: Icon(
                                icon,
                                key: ValueKey(isActive),
                                size: 21,
                                color: isActive ? Colors.white : kSlateGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isActive ? Colors.white : kSlateGray,
                              ),
                              child: Text(label),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
