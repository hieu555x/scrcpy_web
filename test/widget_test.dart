import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrcpy_web/widgets/scrcpy_web_widget.dart';

void main() {
  testWidgets('Smoke test: build ScrcpyWebWidget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ScrcpyWebWidget()),
    );

    expect(find.text('Điều khiển Android (WebUSB)'), findsOneWidget);
    expect(find.byType(ScrcpyWebWidget), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
