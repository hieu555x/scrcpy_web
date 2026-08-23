import 'package:flutter/material.dart';
import 'services/scrcpy_service_stub.dart'
    if (dart.library.js_interop) 'services/scrcpy_web_service.dart';
import 'viewmodels/theme_controller.dart';
import 'widgets/scrcpy_web_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapScrcpyService();
  runApp(ScrcpyWebApp(themeController: ThemeController()));
}

class ScrcpyWebApp extends StatelessWidget {
  final ThemeController themeController;

  const ScrcpyWebApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final lightScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF3b82f6),
          brightness: Brightness.light,
        );
        final darkScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF3b82f6),
          brightness: Brightness.dark,
        );

        return MaterialApp(
          title: 'Android Web Controller (WebUSB)',
          debugShowCheckedModeBanner: false,
          themeMode: themeController.mode,
          theme: _buildTheme(lightScheme, const Color(0xFFf4f4f5)),
          darkTheme: _buildTheme(darkScheme, const Color(0xFF0c0c0e)),
          home: ScrcpyWebWidget(themeController: themeController),
        );
      },
    );
  }

  ThemeData _buildTheme(ColorScheme scheme, Color scaffoldColor) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
