import 'package:flutter/foundation.dart';
import '../models/scrcpy_options.dart';
import '../models/scrcpy_state.dart';
import 'scrcpy_service.dart';

/// Phiên rỗng cho nền tảng không phải web.
class _StubSession implements ScrcpySession {
  static int _counter = 0;

  final ValueNotifier<ScrcpyState> _state =
      ValueNotifier<ScrcpyState>(ScrcpyState.disconnected);

  @override
  final String id = 'stub-${_counter++}';

  @override
  String get viewType => 'stub-view-$id';

  @override
  ValueListenable<ScrcpyState> get state => _state;

  @override
  void sendKeyEvent(String key) {}

  @override
  void disconnect() {}

  @override
  void setTheme(String mode) {}
}

/// Implementation rỗng cho các nền tảng không phải web.
class ScrcpyServiceStub implements ScrcpyService {
  @override
  void Function(ScrcpySession session, ScrcpyState state)? onStateChanged;

  @override
  ScrcpySession createSession({ScrcpyOptions? options}) => _StubSession();

  @override
  void disposeSession(ScrcpySession session) {}
}

ScrcpyService get scrcpyService => ScrcpyServiceStub();

/// No-op trên nền tảng không phải web.
void bootstrapScrcpyService() {}
