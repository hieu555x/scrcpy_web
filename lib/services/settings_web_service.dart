import 'package:web/web.dart' as web;
import 'settings_service.dart';

/// Web implementation: lưu bằng localStorage (ghi nhớ theo máy/trình duyệt).
class SettingsWebService implements SettingsService {
  @override
  String? getString(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  @override
  void setString(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
    } catch (_) {}
  }
}

SettingsService get settingsService => SettingsWebService();

void bootstrapSettings() {}
