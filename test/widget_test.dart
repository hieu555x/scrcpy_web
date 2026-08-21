import 'package:flutter_test/flutter_test.dart';
import 'package:scrcpy_web/main.dart';
import 'package:scrcpy_web/widgets/scrcpy_web_widget.dart';

void main() {
  testWidgets('Smoke test: build MyApp and render ScrcpyWebWidget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title in the AppBar is correct.
    expect(find.text('Điều khiển Android trực tiếp (Không cài đặt)'), findsOneWidget);

    // Verify that ScrcpyWebWidget is present.
    expect(find.byType(ScrcpyWebWidget), findsOneWidget);
  });
}
