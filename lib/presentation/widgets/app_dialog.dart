import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';

// ── Delete confirmation dialog ──────────────────────────────────────────────
// Split-button bar style matching the Notey design reference.
// Title uses DM Sans for the verb + Playfair italic for the entity name.

class AppDeleteDialog extends StatelessWidget {
  /// e.g. "Label?" or "Note?" — rendered in Playfair italic after "Delete"
  final String entityType;
  final String description;
  final String deleteLabel;

  const AppDeleteDialog({
    super.key,
    required this.entityType,
    required this.description,
    this.deleteLabel = 'Delete',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.hairline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Delete ',
                          style: GoogleFonts.dmSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.03 * 26,
                            color: context.onBg,
                            height: 1.2,
                          ),
                        ),
                        TextSpan(
                          text: entityType,
                          style: GoogleFonts.playfairDisplay(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: kPrimary,
                            fontSize: 26,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: kSlateGray,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // ── Split button bar ──
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.hairline)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          foregroundColor: kSlateGray,
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.dmSans(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    VerticalDivider(
                        width: 1, color: context.hairline, thickness: 1),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          foregroundColor: context.errorColor,
                        ),
                        child: Text(
                          deleteLabel,
                          style: GoogleFonts.dmSans(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic dialog shell (used by _CreateLabelDialog) ──────────────────────

class AppDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final List<Widget> actions;
  final EdgeInsets contentPadding;

  const AppDialog({
    super.key,
    required this.title,
    required this.actions,
    this.content,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 14, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'New ',
                          style: GoogleFonts.dmSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.03 * 26,
                            color: context.onBg,
                          ),
                        ),
                        TextSpan(
                          text: title.replaceFirst('New ', ''),
                          style: GoogleFonts.playfairDisplay(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: kPrimary,
                            fontSize: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                      height: 1,
                      width: 40,
                      color: kElectricIndigo),
                ],
              ),
            ),
            if (content != null)
              Flexible(
                child: SingleChildScrollView(
                  padding: contentPadding,
                  child: content,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action button helpers ───────────────────────────────────────────────────

class AppDialogCancelButton extends StatelessWidget {
  final String label;
  const AppDialogCancelButton({super.key, this.label = 'Cancel'});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(label,
          style: GoogleFonts.inter(
              color: kSlateGray, fontSize: 15)),
    );
  }
}

class AppDialogDestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const AppDialogDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label,
          style: GoogleFonts.inter(
              color: context.errorColor, fontWeight: FontWeight.w600)),
    );
  }
}

class AppDialogConfirmButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const AppDialogConfirmButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: kElectricIndigo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        elevation: 0,
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}
