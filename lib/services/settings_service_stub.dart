import 'settings_service.dart';

/// Stub cho nền tảng không phải web — không lưu gì.
class SettingsServiceStub implements SettingsService {
  @override
  String? getString(String key) => null;

  @override
  void setString(String key, String value) {}
}

SettingsService get settingsService => SettingsServiceStub();

void bootstrapSettings() {}
