import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/screens/task_list_screen.dart';

const kBackground = Color(0xFF0A0A0A);
const kSurface = Color(0xFF13131B);
const kSurfaceContainer = Color(0xFF1F1F27);
const kSurfaceContainerHigh = Color(0xFF292932);
const kOnBackground = Color(0xFFE4E1ED);
const kPrimary = Color(0xFFC0C1FF);
const kElectricIndigo = Color(0xFF6366F1);
const kSlateGray = Color(0xFF8E8E93);
const kOutlineVariant = Color(0xFF464554);
const kHairline = Color(0xFF262626);
const kError = Color(0xFFFFB4AB);

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
      home: const TaskListScreen(),
    );
  }
}
