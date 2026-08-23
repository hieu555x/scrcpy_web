import 'dart:js_interop';
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import '../models/scrcpy_state.dart';
import 'scrcpy_service.dart';

/// Một phiên kết nối trên web: một iframe scrcpy_frame.html riêng.
class ScrcpyWebSession implements ScrcpySession {
  @override
  final String id;

  @override
  final String viewType;

  final web.HTMLIFrameElement iframe;

  @override
  final ValueNotifier<ScrcpyState> state =
      ValueNotifier<ScrcpyState>(ScrcpyState.disconnected);

  ScrcpyWebSession({
    required this.id,
    required this.viewType,
    required this.iframe,
  });

  @override
  void sendKeyEvent(String key) {
    _postToFrame({'type': 'keyEvent', 'key': key});
  }

  @override
  void disconnect() {
    _postToFrame({'type': 'disconnect'});
  }

  @override
  void setTheme(String mode) {
    _postToFrame({'type': 'theme', 'mode': mode});
  }

  void _postToFrame(Map<String, Object> message) {
    final web.Window? frameWindow = iframe.contentWindow;
    if (frameWindow == null) return;
    // TargetOrigin cụ thể thay vì '*'.
    frameWindow.postMessage(message.jsify()!, web.window.location.origin.toJS);
  }
}

/// Web implementation: mỗi phiên có iframe riêng, cho phép nhiều thiết bị
/// kết nối đồng thời. Message từ iframe được định tuyến theo nguồn.
class ScrcpyWebService implements ScrcpyService {
  static final ScrcpyWebService instance = ScrcpyWebService._();

  factory ScrcpyWebService() => instance;

  ScrcpyWebService._();

  final Map<String, ScrcpyWebSession> _sessions = {};
  int _nextId = 0;
  bool _listening = false;

  @override
  void Function(ScrcpySession session, ScrcpyState state)? onStateChanged;

  @override
  ScrcpySession createSession() {
    final id = 'device-${_nextId++}';
    final viewType = 'scrcpy-view-$id';

    final iframe = web.HTMLIFrameElement()
      ..src = 'scrcpy_frame.html'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('allow', 'usb');

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) => iframe);

    final session = ScrcpyWebSession(
      id: id,
      viewType: viewType,
      iframe: iframe,
    );
    _sessions[id] = session;
    _ensureListening();
    return session;
  }

  @override
  void disposeSession(ScrcpySession session) {
    _sessions.remove(session.id);
  }

  void _ensureListening() {
    if (_listening) return;
    _listening = true;

    web.window.addEventListener(
      'message',
      ((web.MessageEvent event) {
        _handleMessage(event);
      }).toJS,
    );
  }

  void _handleMessage(web.MessageEvent event) {
    // Chỉ chấp nhận message cùng origin.
    if (event.origin != web.window.location.origin) return;

    // Định tuyến: tìm phiên nào có contentWindow trùng nguồn message.
    final web.Window? source = event.source as web.Window?;
    ScrcpyWebSession? owner;
    for (final session in _sessions.values) {
      final window = session.iframe.contentWindow;
      if (window != null && source != null && source.equals(window).toDart) {
        owner = session;
        break;
      }
    }
    if (owner == null) return;

    final Object? data = event.data.dartify();
    if (data is! Map<Object?, Object?>) return;
    if (data['type'] != 'scrcpyState') return;

    final state = switch (data['state']) {
      'connecting' => ScrcpyState.connecting,
      'connected' => ScrcpyState.connected,
      'error' => ScrcpyState.error,
      'disconnected' => ScrcpyState.disconnected,
      _ => null,
    };
    if (state == null) return;

    owner.state.value = state;
    onStateChanged?.call(owner, state);
  }
}

ScrcpyService get scrcpyService => ScrcpyWebService.instance;

void bootstrapScrcpyService() {}
