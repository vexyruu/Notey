import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../domain/entities/note.dart';
import '../viewmodels/note_providers.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  bool _isDirty = false;

  bool get _isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _titleCtrl.addListener(_markDirty);
    _contentCtrl.addListener(_markDirty);
  }

  int get _wordCount {
    final text = _contentCtrl.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  void _markDirty() => setState(() => _isDirty = true);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_isDirty) return;
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty && content.isEmpty) {
      if (_isEdit) {
        await ref.read(noteViewModelProvider.notifier).deleteNote(widget.note!.id);
      }
      return;
    }
    final vm = ref.read(noteViewModelProvider.notifier);
    if (_isEdit) {
      await vm.updateNote(widget.note!.copyWith(title: title, content: content));
    } else {
      await vm.addNote(title: title, content: content);
    }
  }

  Future<void> _saveAndPop() async {
    await _save();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteAndPop() async {
    if (_isEdit) {
      await ref.read(noteViewModelProvider.notifier).deleteNote(widget.note!.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndPop();
      },
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.onBg),
            onPressed: _saveAndPop,
          ),
          actions: [
            if (_isEdit)
              IconButton(
                icon: Icon(Icons.delete_outline, color: context.errorColor),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: context.surfaceContainerHigh,
                      title: Text('Delete note?',
                          style: GoogleFonts.dmSans(color: context.onBg)),
                      content: Text('This cannot be undone.',
                          style:
                              GoogleFonts.inter(color: kSlateGray, fontSize: 14)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text('Cancel',
                              style: GoogleFonts.inter(color: kSlateGray)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text('Delete',
                              style: GoogleFonts.inter(
                                  color: context.errorColor)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) _deleteAndPop();
                },
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: context.hairline),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Text(
                  'Edited ${DateFormat('MMM d, h:mm a').format(note.updatedAt)}',
                  style: GoogleFonts.inter(fontSize: 11, color: kSlateGray),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: TextField(
                controller: _titleCtrl,
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02 * 26,
                  color: context.onBg,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.02 * 26,
                    color: context.hintText,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                autofocus: !_isEdit,
              ),
            ),
            Divider(
              height: 24,
              indent: 24,
              endIndent: 24,
              color: context.hairline,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: TextField(
                  controller: _contentCtrl,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: context.onBg,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: context.hintText,
                      height: 1.6,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
                style: GoogleFonts.inter(fontSize: 11, color: kSlateGray),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
