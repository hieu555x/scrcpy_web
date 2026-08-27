import 'dart:js_interop';
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import '../models/scrcpy_options.dart';
import '../models/scrcpy_state.dart';
import 'scrcpy_service.dart';

/// Một phiên kết nối trên web: một iframe scrcpy_frame.html riêng,
/// được gắn vào container HTML dùng chung (xem [ScrcpyWebService]).
class ScrcpyWebSession implements ScrcpySession {
  @override
  final String id;

  @override
  final String viewType;

  final web.HTMLIFrameElement iframe;

  @override
  final ValueNotifier<ScrcpyState> state =
      ValueNotifier<ScrcpyState>(ScrcpyState.disconnected);

  ScrcpyOptions options;

  ScrcpyWebSession({
    required this.id,
    required this.viewType,
    required this.iframe,
    this.options = ScrcpyOptions.defaults,
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

  @override
  void setMuted(bool muted) {
    _postToFrame({'type': 'setMuted', 'muted': muted});
  }

  void _postToFrame(Map<String, Object> message) {
    final web.Window? frameWindow = iframe.contentWindow;
    if (frameWindow == null) return;
    // TargetOrigin cụ thể thay vì '*'.
    frameWindow.postMessage(message.jsify()!, web.window.location.origin.toJS);
  }
}

/// Web implementation: TẤT CẢ các iframe được gắn vào MỘT thẻ <div> container
/// duy nhất đăng ký làm platform view. Layout được điều khiển thuần bằng CSS
/// (`layout-tabs`: một iframe toàn màn hình · `layout-grid`: chia cột cạnh
/// nhau) — iframe không bao giờ bị Flutter tháo/gắn lại nên kết nối
/// USB/scrcpy luôn được giữ nguyên khi chuyển đổi bố cục.
class ScrcpyWebService implements ScrcpyService {
  static final ScrcpyWebService instance = ScrcpyWebService._();

  factory ScrcpyWebService() => instance;

  ScrcpyWebService._();

  final Map<String, ScrcpyWebSession> _sessions = {};
  int _nextId = 0;
  bool _listening = false;
  bool _registered = false;

  late final web.HTMLDivElement _host = _createHost();

  web.HTMLDivElement _createHost() {
    final host = web.document.createElement('div') as web.HTMLDivElement
      ..className = 'scrcpy-frame-host layout-tabs';
    _injectStyles();
    return host;
  }

  void _injectStyles() {
    final style = web.document.createElement('style') as web.HTMLStyleElement;
    style.textContent = '''
.scrcpy-frame-host { position: relative; width: 100%; height: 100%; }
.scrcpy-frame-host .scrcpy-frame { display: block; width: 100%; height: 100%; border: none; background: #000; }
.scrcpy-frame-host.layout-tabs .scrcpy-frame { display: none; }
.scrcpy-frame-host.layout-tabs .scrcpy-frame.active { display: block; }
.scrcpy-frame-host.layout-grid { display: flex; flex-direction: row; }
.scrcpy-frame-host.layout-grid .scrcpy-frame { flex: 1 1 0%; min-width: 0; border-right: 1px solid rgba(128, 128, 128, 0.35); }
.scrcpy-frame-host.layout-grid .scrcpy-frame:last-child { border-right: none; }
''';
    web.document.head?.append(style);
  }

  void _ensureRegistered() {
    if (_registered) return;
    _registered = true;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      kScrcpyHostViewType,
      (int viewId) => _host,
    );
  }

  @override
  void Function(ScrcpySession session, ScrcpyState state)? onStateChanged;

  @override
  void Function(ScrcpySession session, bool muted)? onMuteStateChanged;

  @override
  ScrcpySession createSession({ScrcpyOptions? options}) {
    _ensureRegistered();
    final id = 'device-${_nextId++}';
    final viewType = 'scrcpy-view-$id';

    final iframe = web.HTMLIFrameElement()
      ..src = 'scrcpy_frame.html?sessionId=$id'
      ..className = 'scrcpy-frame'
      ..setAttribute('allow', 'usb; clipboard-write; clipboard-read');

    _host.append(iframe);

    final session = ScrcpyWebSession(
      id: id,
      viewType: viewType,
      iframe: iframe,
      options: options ?? ScrcpyOptions.defaults,
    );
    _sessions[id] = session;
    _ensureListening();
    markActive(session);
    return session;
  }

  @override
  void disposeSession(ScrcpySession session) {
    _sessions.remove(session.id);
    (session as ScrcpyWebSession).iframe.remove();
  }

  @override
  void applyLayout({required bool sideBySide}) {
    _host.className =
        'scrcpy-frame-host ${sideBySide ? 'layout-grid' : 'layout-tabs'}';
  }

  @override
  void markActive(ScrcpySession session) {
    for (final s in _sessions.values) {
      s.iframe.classList.toggle('active', identical(s, session));
    }
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
    final type = data['type'] as String?;

    if (type == 'mutedState') {
      final muted = data['muted'] as bool? ?? false;
      onMuteStateChanged?.call(owner, muted);
      return;
    }

    if (type != 'scrcpyState') return;

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
