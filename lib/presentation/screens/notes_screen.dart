import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/note.dart';
import '../viewmodels/note_providers.dart';
import 'note_editor_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(filteredNotesProvider);

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
                            text: 'Notes',
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
                    const SizedBox(height: 20),
                    _SearchBar(controller: _searchCtrl),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            notesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: kElectricIndigo)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                    child: Text('Error: $e',
                        style: TextStyle(color: kSlateGray))),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  final isSearching =
                      ref.watch(noteSearchQueryProvider).isNotEmpty;
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSearching
                                ? Icons.search_off_rounded
                                : Icons.sticky_note_2_outlined,
                            size: 48,
                            color: kSlateGray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isSearching
                                ? 'No notes match your search.'
                                : 'No notes yet.\nTap + to write one.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: kSlateGray,
                                height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 148,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _NoteCard(note: notes[i]),
                      childCount: notes.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
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

class _SearchBar extends ConsumerWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      onChanged: (v) =>
          ref.read(noteSearchQueryProvider.notifier).state = v,
      style: GoogleFonts.inter(fontSize: 14, color: context.onBg),
      decoration: InputDecoration(
        hintText: 'Search notes…',
        hintStyle:
            GoogleFonts.inter(fontSize: 14, color: context.hintText),
        prefixIcon:
            Icon(Icons.search_rounded, size: 20, color: kSlateGray),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () {
                    controller.clear();
                    ref.read(noteSearchQueryProvider.notifier).state = '';
                  },
                  child: Icon(Icons.close_rounded,
                      size: 18, color: kSlateGray),
                ),
        ),
        filled: true,
        fillColor: context.surfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: kElectricIndigo.withValues(alpha: 0.4)),
        ),
        isDense: true,
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  const _NoteCard({required this.note});

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = note.title.isNotEmpty;
    final hasContent = note.content.isNotEmpty;
    final displayTitle = hasTitle
        ? note.title
        : (hasContent ? note.content.split('\n').first : 'Empty note');

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.subtleBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayTitle,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.onBg,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: hasContent && hasTitle
                  ? Text(
                      note.content,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: kSlateGray,
                        height: 1.55,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    )
                  : const SizedBox(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 10, color: context.outline),
                const SizedBox(width: 4),
                Text(
                  _relativeDate(note.updatedAt),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: context.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
