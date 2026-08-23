import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/settings_service_stub.dart'
    if (dart.library.js_interop) '../services/settings_web_service.dart';

/// Điều khiển chế độ sáng/tối và ghi nhớ lựa chọn qua SettingsService.
class ThemeController extends ChangeNotifier {
  static const String _storageKey = 'scrcpy_theme';

  final SettingsService _settings;

  ThemeMode _mode;

  ThemeController({SettingsService? settings})
      : _settings = settings ?? settingsService,
        _mode = _parse((settings ?? settingsService)
            .getString(_storageKey));

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    _settings.setString(
      _storageKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    notifyListeners();
  }

  void toggle() {
    setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  static ThemeMode _parse(String? value) =>
      value == 'light' ? ThemeMode.light : ThemeMode.dark;
}
