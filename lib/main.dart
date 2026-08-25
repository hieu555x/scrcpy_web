import 'package:flutter/material.dart';
import 'services/scrcpy_service_stub.dart'
    if (dart.library.js_interop) 'services/scrcpy_web_service.dart';
import 'theme/app_theme.dart';
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
        return MaterialApp(
          title: 'Scrcpy Web — Điều khiển Android qua trình duyệt',
          debugShowCheckedModeBanner: false,
          themeMode: themeController.mode,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          home: ScrcpyWebWidget(themeController: themeController),
        );
      },
    );
  }
}
