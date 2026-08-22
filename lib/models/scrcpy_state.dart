/// Trạng thái kết nối Scrcpy
enum ScrcpyState {
  /// Chưa kết nối
  disconnected,

  /// Đang kết nối
  connecting,

  /// Đã kết nối thành công
  connected,

  /// Có lỗi xảy ra
  error,
}
