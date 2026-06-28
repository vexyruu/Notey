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
      backgroundColor: context.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 100),
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
                    text: 'Profile',
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
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kElectricIndigo.withValues(alpha: 0.12),
                      border: Border.all(
                          color: kElectricIndigo.withValues(alpha: 0.25),
                          width: 1.5),
                    ),
                    child: const Icon(Icons.person_outline,
                        size: 38, color: kElectricIndigo),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Your Workspace',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.onBg,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personal',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: kSlateGray),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _SectionHeader(label: 'APPEARANCE'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.onBg),
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
            const SizedBox(height: 24),
            _SectionHeader(label: 'ACCOUNT'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsRow(
                  icon: Icons.login_outlined,
                  label: 'Sign in with Google',
                  subtitle: 'Sync tasks across devices',
                  trailing: Icon(Icons.chevron_right,
                      color: kSlateGray, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionHeader(label: 'DATA'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsRow(
                  icon: Icons.backup_outlined,
                  label: 'Export data',
                  subtitle: 'Download all tasks and notes',
                  trailing: Icon(Icons.chevron_right,
                      color: kSlateGray, size: 20),
                ),
                Divider(height: 1, color: context.hairline),
                _SettingsRow(
                  icon: Icons.restore_outlined,
                  label: 'Import data',
                  subtitle: 'Restore from a backup file',
                  trailing: Icon(Icons.chevron_right,
                      color: kSlateGray, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionHeader(label: 'ABOUT'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _SettingsRow(
                  icon: Icons.info_outline,
                  label: 'Version',
                  trailing: Text('1.0.0',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: kSlateGray)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08 * 11,
        color: kSlateGray,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kElectricIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: kElectricIndigo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.onBg),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: kSlateGray),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
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
                  color: isActive ? kElectricIndigo : context.outline,
                ),
                borderRadius: BorderRadius.circular(6),
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
