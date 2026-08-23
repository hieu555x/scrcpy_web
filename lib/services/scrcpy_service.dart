import 'package:flutter/foundation.dart';
import '../models/scrcpy_state.dart';

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
}

/// Quản lý nhiều phiên kết nối cùng lúc.
abstract class ScrcpyService {
  /// Được gọi khi bất kỳ phiên nào báo thay đổi trạng thái.
  void Function(ScrcpySession session, ScrcpyState state)? onStateChanged;

  /// Tạo một phiên mới (iframe + platform view riêng cho thiết bị mới).
  ScrcpySession createSession();

  /// Hủy phiên sau khi đóng tab tương ứng.
  void disposeSession(ScrcpySession session);
}
