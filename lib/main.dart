import 'package:flutter/material.dart';
import 'services/scrcpy_service_stub.dart'
    if (dart.library.js_interop) 'services/scrcpy_web_service.dart';
import 'widgets/scrcpy_web_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Đăng ký platform view + message listener (idempotent, chỉ web).
  bootstrapScrcpyService();
  runApp(const ScrcpyWebApp());
}

class ScrcpyWebApp extends StatelessWidget {
  const ScrcpyWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Web Controller (WebUSB)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0c0c0e),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3b82f6),
          brightness: Brightness.dark,
        ),
      ),
      home: const ScrcpyWebWidget(),
    );
  }
}
