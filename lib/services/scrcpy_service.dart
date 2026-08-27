import 'package:flutter/foundation.dart';
import '../models/scrcpy_options.dart';
import '../models/scrcpy_state.dart';

/// ViewType của platform view duy nhất chứa tất cả iframe (chỉ dùng trên web).
const String kScrcpyHostViewType = 'scrcpy-frame-host';

/// Một phiên kết nối tới một thiết bị — mỗi phiên có iframe riêng biệt,
/// nhờ đó có thể kết nối nhiều điện thoại cùng lúc.
abstract class ScrcpySession {
  String get id;

  /// Tên platform view của phiên (chỉ có ý nghĩa trên web).
  String get viewType;

  /// Trạng thái kết nối của phiên này (báo từ iframe).
  ValueListenable<ScrcpyState> get state;

  /// Gửi phím điều hướng đến phiên (back | home | apps).
  void sendKeyEvent(String key);

  /// Yêu cầu phiên ngắt kết nối thiết bị.
  void disconnect();

  /// Áp dụng chế độ sáng/tối cho iframe ('dark' | 'light').
  void setTheme(String mode);

  /// Bật/tắt tiếng cho thiết bị này.
  void setMuted(bool muted);
}

/// Quản lý nhiều phiên kết nối cùng lúc.
abstract class ScrcpyService {
  /// Được gọi khi bất kỳ phiên nào báo thay đổi trạng thái.
  void Function(ScrcpySession session, ScrcpyState state)? onStateChanged;

  /// Được gọi khi trạng thái mute của phiên thay đổi (từ iframe sync).
  void Function(ScrcpySession session, bool muted)? onMuteStateChanged;

  /// Tạo một phiên mới (iframe + platform view riêng cho thiết bị mới).
  /// [options] là cấu hình scrcpy do người dùng chọn.
  ScrcpySession createSession({ScrcpyOptions? options});

  /// Hủy phiên: ngắt kết nối và gỡ iframe khỏi container.
  void disposeSession(ScrcpySession session);

  /// Chuyển layout hiển thị: một phiên toàn màn hình hoặc tất cả cạnh nhau.
  void applyLayout({required bool sideBySide});

  /// Đánh dấu phiên đang hoạt động (layout tab sẽ hiển thị phiên này).
  void markActive(ScrcpySession session);
}
