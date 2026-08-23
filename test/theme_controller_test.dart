import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrcpy_web/services/settings_service.dart';
import 'package:scrcpy_web/viewmodels/theme_controller.dart';

/// Bộ nhớ giả để kiểm tra việc lưu/đọc mà không cần web.
class _FakeSettings implements SettingsService {
  final Map<String, String> store = {};

  @override
  String? getString(String key) => store[key];

  @override
  void setString(String key, String value) => store[key] = value;
}

void main() {
  group('ThemeController', () {
    test('mặc định là dark khi chưa có giá trị lưu', () {
      final controller = ThemeController(settings: _FakeSettings());
      addTearDown(controller.dispose);

      expect(controller.mode, ThemeMode.dark);
      expect(controller.isDark, isTrue);
    });

    test('đọc lại chế độ đã lưu (light)', () {
      final settings = _FakeSettings()..store['scrcpy_theme'] = 'light';
      final controller = ThemeController(settings: settings);
      addTearDown(controller.dispose);

      expect(controller.mode, ThemeMode.light);
      expect(controller.isDark, isFalse);
    });

    test('toggle đổi chế độ và lưu vào storage', () {
      final settings = _FakeSettings();
      final controller = ThemeController(settings: settings);
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.toggle();
      expect(controller.mode, ThemeMode.light);
      expect(settings.store['scrcpy_theme'], 'light');

      controller.toggle();
      expect(controller.mode, ThemeMode.dark);
      expect(settings.store['scrcpy_theme'], 'dark');
      expect(notifications, 2);
    });

    test('setMode cùng giá trị không thông báo', () {
      final controller = ThemeController(settings: _FakeSettings());
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.setMode(ThemeMode.dark);
      expect(notifications, 0);
    });
  });
}
