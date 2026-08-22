import 'package:flutter/foundation.dart';
import '../models/scrcpy_state.dart';
import 'scrcpy_service.dart';

/// Phiên rỗng cho nền tảng không phải web.
class _StubSession implements ScrcpySession {
  static int _counter = 0;

  @override
  String get id => 'stub-${_counter++}';

  @override
  ValueListenable<ScrcpyState> get state =>
      ValueNotifier<ScrcpyState>(ScrcpyState.disconnected);

  @override
  void sendKeyEvent(String key) {}

  @override
  void disconnect() {}
}

/// Implementation rỗng cho các nền tảng không phải web.
class ScrcpyServiceStub implements ScrcpyService {
  @override
  void Function(ScrcpySession session, ScrcpyState state)? onStateChanged;

  @override
  ScrcpySession createSession() => _StubSession();

  @override
  void disposeSession(ScrcpySession session) {}
}

ScrcpyService get scrcpyService => ScrcpyServiceStub();

/// No-op trên nền tảng không phải web.
void bootstrapScrcpyService() {}
