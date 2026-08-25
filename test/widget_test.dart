import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrcpy_web/main.dart';
import 'package:scrcpy_web/viewmodels/theme_controller.dart';
import 'package:scrcpy_web/widgets/deck_widgets.dart';
import 'package:scrcpy_web/widgets/scrcpy_web_widget.dart';

void main() {
  testWidgets('Smoke test: build ScrcpyWebWidget', (WidgetTester tester) async {
    final themeController = ThemeController(
      settings: null,
    ); // VM → stub service

    await tester.pumpWidget(
      ScrcpyWebApp(themeController: themeController),
    );
    // Cho hiệu ứng FadeIn chạy xong.
    await tester.pumpAndSettle();

    expect(find.text('Scrcpy Web'), findsOneWidget);
    expect(find.text('Kết nối thiết bị'), findsOneWidget);
    expect(find.byType(ScrcpyWebWidget), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets(
    'SignalDot bật/tắt pulse nhiều lần không tạo ticker trùng (hồi quy)',
    (WidgetTester tester) async {
      // Kịch bản thật: connecting → connected → connecting... SignalDot
      // phải hủy controller cũ và tạo controller mới an toàn.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: SignalDot(color: Colors.red))),
        ),
      );
      await tester.pump();

      for (var i = 0; i < 3; i++) {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(child: SignalDot(color: Colors.red, pulse: true)),
            ),
          ),
        );
        await tester.pump();
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Center(child: SignalDot(color: Colors.red))),
          ),
        );
        await tester.pump();
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SignalDot(color: Colors.red, pulse: true)),
          ),
        ),
      );
      // Pulse lặp vô hạn nên không dùng pumpAndSettle - chỉ cần vài frame
      // để chắc chắn controller mới chạy không văng exception.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
    },
  );
}
