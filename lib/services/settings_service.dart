/// Lưu/c đọc cài đặt nhỏ (hiện tại: chế độ sáng/tối).
abstract class SettingsService {
  String? getString(String key);
  void setString(String key, String value);
}
