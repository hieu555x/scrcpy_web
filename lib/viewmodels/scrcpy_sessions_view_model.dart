import 'package:flutter/foundation.dart';
import '../models/scrcpy_options.dart';
import '../models/scrcpy_state.dart';
import '../services/scrcpy_service.dart';

/// Quản lý danh sách phiên kết nối (mỗi thiết bị một phiên) và phiên đang hiển thị.
class ScrcpySessionsViewModel extends ChangeNotifier {
  final ScrcpyService service;

  final List<ScrcpySession> sessions = [];

  /// Các options mặc định của phiên đang được chỉnh sửa (bản sao mutable).
  ScrcpyOptions _currentOptions = ScrcpyOptions.defaults;

  ScrcpyOptions get currentOptions => _currentOptions;

  void setGlobalOptions(ScrcpyOptions options) {
    _currentOptions = options;
    notifyListeners();
  }

  int _activeIndex = 0;

  ScrcpySessionsViewModel(this.service) {
    service.onStateChanged = _onStateChanged;
  }

  int get activeIndex => _activeIndex;

  ScrcpySession? get active =>
      sessions.isEmpty ? null : sessions[_activeIndex];

  void _onStateChanged(ScrcpySession session, ScrcpyState state) {
    // Giao diện lắng nghe từng session.state riêng nên chỉ cần vẽ lại
    // các phần phụ thuộc (chips, bottom sheet).
    notifyListeners();
  }

  /// Thêm một phiên mới với [options] hiện tại và chuyển tới nó.
  ScrcpySession addSession({ScrcpyOptions? options}) {
    final resolvedOptions = options ?? _currentOptions;
    final session = service.createSession(options: resolvedOptions);
    sessions.add(session);
    _activeIndex = sessions.length - 1;
    notifyListeners();
    return session;
  }

  void setActive(int index) {
    if (index < 0 || index >= sessions.length || index == _activeIndex) return;
    _activeIndex = index;
    notifyListeners();
  }

  /// Đóng phiên: ngắt kết nối thiết bị trước khi gỡ tab.
  Future<void> removeSession(int index) async {
    if (index < 0 || index >= sessions.length) return;
    final session = sessions[index];
    session.disconnect();

    // Chờ iframe dọn dẹp xong rồi mới gỡ khỏi danh sách.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final currentIndex = sessions.indexOf(session);
    if (currentIndex == -1) return; // đã bị gỡ bởi lần gọi khác

    sessions.removeAt(currentIndex);
    service.disposeSession(session);

    if (_activeIndex >= sessions.length) {
      _activeIndex = sessions.length - 1;
    }
    if (_activeIndex < 0) _activeIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    service.onStateChanged = null;
    for (final session in List.of(sessions)) {
      session.disconnect();
      service.disposeSession(session);
    }
    sessions.clear();
    super.dispose();
  }
}
