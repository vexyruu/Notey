import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
          'Settings',
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _SectionHeader(label: 'APPEARANCE'),
          _SettingsRow(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kOnBackground),
                ),
                const SizedBox(height: 12),
                _ThemeSegmentedControl(
                  current: themeMode,
                  onChanged: (mode) =>
                      ref.read(themeModeProvider.notifier).setTheme(mode),
                ),
              ],
            ),
          ),
          const _Hairline(),
          _SectionHeader(label: 'ACCOUNT'),
          _SettingsRow(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign in with Google',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: kOnBackground),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sync tasks across devices',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: kSlateGray),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: kSlateGray, size: 20),
              ],
            ),
          ),
          const _Hairline(),
          _SectionHeader(label: 'ABOUT'),
          _SettingsRow(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Version',
                    style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kOnBackground),
                  ),
                ),
                Text('1.0.0',
                    style:
                        GoogleFonts.inter(fontSize: 14, color: kSlateGray)),
              ],
            ),
          ),
          const _Hairline(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.08 * 11,
          color: kSlateGray,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final Widget child;
  const _SettingsRow({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: child,
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: kHairline, indent: 24, endIndent: 24);
}

class _ThemeSegmentedControl extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSegmentedControl(
      {required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ThemeMode.system, 'System'),
      (ThemeMode.light, 'Light'),
      (ThemeMode.dark, 'Dark'),
    ];
    return Row(
      children: options.map((entry) {
        final (mode, label) = entry;
        final isActive = current == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? kElectricIndigo.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isActive ? kElectricIndigo : kOutlineVariant,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive ? kElectricIndigo : kSlateGray,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
