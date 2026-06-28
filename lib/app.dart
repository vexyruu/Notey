import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/widgets/main_shell.dart';

const kElectricIndigo = Color(0xFF6366F1);
const kPrimary = Color(0xFFC0C1FF);
const kSlateGray = Color(0xFF8E8E93);

const kPriorityHigh = Color(0xFFFF6B6B);
const kPriorityMedium = Color(0xFFFFB86C);
const kPriorityLow = Color(0xFF4EDEA3);

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => Theme.of(this).scaffoldBackgroundColor;
  Color get onBg => Theme.of(this).colorScheme.onSurface;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get surfaceContainer => Theme.of(this).colorScheme.surfaceContainer;
  Color get surfaceContainerHigh => Theme.of(this).colorScheme.surfaceContainerHigh;
  Color get hairline => Theme.of(this).dividerColor;
  Color get outline => Theme.of(this).colorScheme.outlineVariant;
  Color get subtleBorder => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.1);
  Color get accentText => isDark ? kPrimary : kElectricIndigo;
  Color get hintText => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.22);
  Color get errorColor => Theme.of(this).colorScheme.error;
}

class NoteyApp extends ConsumerWidget {
  const NoteyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Notey',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const MainShell(),
    );
  }
}
