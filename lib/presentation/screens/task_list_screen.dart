import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../viewmodels/providers.dart';
import '../viewmodels/task_viewmodel.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_tab_bar.dart';
import '../widgets/task_list_item.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final activeCount = ref.watch(tasksStreamProvider).value
            ?.where((t) => !t.isCompleted && !t.isDeleted)
            .length ??
        0;
    final categories = ref.watch(availableCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Row(
                children: [
                  Text(
                    'Notey',
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.03 * 28,
                      color: kOnBackground,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.cloud_done_outlined,
                      color: kSlateGray, size: 20),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: const Icon(Icons.settings_outlined,
                        color: kOnBackground, size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: kElectricIndigo),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: kSlateGray)),
                ),
                data: (tasks) => CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                children: [
                                  const TextSpan(text: 'Your '),
                                  TextSpan(
                                    text: 'Focus',
                                    style: GoogleFonts.playfairDisplay(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimary,
                                      fontSize: 40,
                                      height: 1.2,
                                    ),
                                  ),
                                  const TextSpan(text: ' Today'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$activeCount task${activeCount == 1 ? '' : 's'} remaining',
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: kSlateGray),
                            ),
                            const SizedBox(height: 32),
                            const FilterTabBar(),
                            if (categories.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _CategoryChip(
                                      label: 'All',
                                      isSelected: selectedCategory == null,
                                      onTap: () => ref
                                          .read(selectedCategoryProvider.notifier)
                                          .state = null,
                                    ),
                                    ...categories.map((c) => _CategoryChip(
                                          label: c,
                                          isSelected: selectedCategory == c,
                                          onTap: () => ref
                                              .read(selectedCategoryProvider
                                                  .notifier)
                                              .state = selectedCategory == c
                                              ? null
                                              : c,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (tasks.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyStateWidget(),
                      )
                    else
                      SliverReorderableList(
                        itemCount: tasks.length,
                        onReorderItem: (oldIndex, newIndex) => ref
                            .read(taskViewModelProvider.notifier)
                            .reorderTasks(tasks, oldIndex, newIndex),
                        itemBuilder: (context, index) => TaskListItem(
                          key: ValueKey(tasks[index].id),
                          task: tasks[index],
                          index: index,
                        ),
                        proxyDecorator: (child, index, animation) =>
                            Material(
                          color: kSurfaceContainer,
                          child: child,
                        ),
                      ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          ),
          backgroundColor: kElectricIndigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        onAddTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        onCalendarTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        ),
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? kElectricIndigo.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? kElectricIndigo : kOutlineVariant,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? kElectricIndigo : kSlateGray,
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final VoidCallback onAddTap;
  final VoidCallback onCalendarTap;
  final VoidCallback onProfileTap;

  const _BottomNavBar({
    required this.onAddTap,
    required this.onCalendarTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBackground,
        border: Border(top: BorderSide(color: kHairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _NavItem(icon: Icons.grid_view_rounded, isActive: true),
              _NavItem(icon: Icons.add_circle_outline, isActive: false, onTap: onAddTap),
              _NavItem(icon: Icons.calendar_month_outlined, isActive: false, onTap: onCalendarTap),
              _NavItem(icon: Icons.person_outline, isActive: false, onTap: onProfileTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({required this.icon, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Icon(icon,
            color: isActive ? kElectricIndigo : kSlateGray, size: 26),
      ),
    );
  }
}
