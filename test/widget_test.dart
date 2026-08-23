import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrcpy_web/main.dart';
import 'package:scrcpy_web/viewmodels/theme_controller.dart';
import 'package:scrcpy_web/widgets/scrcpy_web_widget.dart';

void main() {
  testWidgets('Smoke test: build ScrcpyWebWidget', (WidgetTester tester) async {
    final themeController = ThemeController(
      settings: null,
    ); // VM → stub service

    await tester.pumpWidget(
      ScrcpyWebApp(themeController: themeController),
    );

    expect(find.text('Điều khiển Android (WebUSB)'), findsOneWidget);
    expect(find.byType(ScrcpyWebWidget), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
