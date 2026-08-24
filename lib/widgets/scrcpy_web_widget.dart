import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/scrcpy_service.dart';
import '../services/scrcpy_service_stub.dart'
    if (dart.library.js_interop) '../services/scrcpy_web_service.dart';
import '../viewmodels/scrcpy_sessions_view_model.dart';
import '../viewmodels/theme_controller.dart';
import '../models/scrcpy_options.dart';
import '../models/scrcpy_state.dart';

class ScrcpyWebWidget extends StatefulWidget {
  final ThemeController themeController;

  const ScrcpyWebWidget({super.key, required this.themeController});

  @override
  State<ScrcpyWebWidget> createState() => _ScrcpyWebWidgetState();
}

class _ScrcpyWebWidgetState extends State<ScrcpyWebWidget> {
  late final ScrcpySessionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ScrcpySessionsViewModel(scrcpyService);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  String get _currentThemeMode =>
      widget.themeController.isDark ? 'dark' : 'light';

  void _addSession() {
    if (!kIsWeb) return;
    final session = _viewModel.addSession();
    // Đồng bộ theme hiện tại cho iframe mới tạo.
    session.setTheme(_currentThemeMode);
  }

  void _toggleTheme() {
    widget.themeController.toggle();
    // Áp dụng cho toàn bộ phiên đang mở.
    final mode = _currentThemeMode;
    for (final session in List.of(_viewModel.sessions)) {
      session.setTheme(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khiển Android (WebUSB)'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.themeController.isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: widget.themeController.isDark
                ? 'Chuyển sang chế độ sáng'
                : 'Chuyển sang chế độ tối',
            onPressed: kIsWeb ? _toggleTheme : null,
          ),
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Thêm thiết bị',
              onPressed: _addSession,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: !kIsWeb
          ? const _UnsupportedPlatformView()
          : AnimatedBuilder(
              animation: _viewModel,
              builder: (context, _) => _buildBody(context),
            ),
      bottomSheet: !kIsWeb
          ? null
          : const SizedBox.shrink(),
    );
  }

  Widget _buildBody(BuildContext context) {
    final sessions = _viewModel.sessions;
    if (sessions.isEmpty) return _buildEmpty(context);

    final scheme = Theme.of(context).colorScheme;
    // Từ 2 phiên trở lên: các màn hình hiển thị cạnh nhau (chia cột đều).
    final gridMode = sessions.length > 1;

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: sessions.length,
            itemBuilder: (context, index) => _buildDeviceChip(
              context,
              index,
              scheme,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(
                      Theme.of(context).brightness == Brightness.dark ? 140 : 35,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Platform view DUY NHẤT chứa mọi iframe — const nên
                    // không bao giờ bị tạo lại; layout điều khiển bằng CSS.
                    const Positioned.fill(
                      child: HtmlElementView(viewType: kScrcpyHostViewType),
                    ),
                    // Nhãn + đường phân cách khi hiển thị cạnh nhau
                    if (gridMode)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final count = sessions.length;
                              final colWidth = constraints.maxWidth / count;
                              return Stack(
                                children: [
                                  for (var i = 0; i < count; i++)
                                    Positioned(
                                      top: 8,
                                      left: i * colWidth + 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              scheme.primary.withAlpha(220),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Thiết bị ${i + 1}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: scheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  for (var i = 1; i < count; i++)
                                    Positioned(
                                      top: 0,
                                      left: i * colWidth - 0.5,
                                      width: 1,
                                      height: constraints.maxHeight,
                                      child: ColoredBox(
                                        color: scheme.outlineVariant,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Thanh điều khiển: mỗi vùng màn hình một thanh riêng, chia đều
        // theo đúng tỷ lệ các cột phía trên và điều khiển thiết bị của vùng đó.
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.usb, size: 64, color: onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Chưa có thiết bị nào',
            style: TextStyle(color: onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addSession,
            icon: const Icon(Icons.add),
            label: const Text('Kết nối thiết bị'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceChip(
    BuildContext context,
    int index,
    ColorScheme scheme,
  ) {
    final session = _viewModel.sessions[index];
    final selected = index == _viewModel.activeIndex;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ValueListenableBuilder<ScrcpyState>(
        valueListenable: session.state,
        builder: (context, state, _) {
          return InkWell(
            onTap: () => _viewModel.setActive(index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary
                    : scheme.surfaceContainerHighest.withAlpha(90),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DotIndicator(color: _getStateColor(state)),
                  const SizedBox(width: 8),
                  Text(
                    'Thiết bị ${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? scheme.onPrimary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _viewModel.removeSession(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: selected
                          ? scheme.onPrimary.withAlpha(180)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Vùng thanh điều khiển phía dưới: chia đều cho từng thiết bị.
  Widget _buildBottomControls() {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final session in _viewModel.sessions)
            Expanded(child: _sessionControlBar(session, scheme)),
        ],
      ),
    );
  }

  /// Thanh điều khiển của một thiết bị: hiện khi thiết bị đang kết nối,
  /// các nút tác động đúng lên phiên của vùng này.
  Widget _sessionControlBar(ScrcpySession session, ColorScheme scheme) {
    return ValueListenableBuilder<ScrcpyState>(
      valueListenable: session.state,
      builder: (context, state, _) {
        if (state != ScrcpyState.connected) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton(
                Icons.chevron_left,
                'Back',
                () => session.sendKeyEvent('back'),
              ),
              const SizedBox(width: 12),
              _buildNavButton(
                Icons.home,
                'Home',
                () => session.sendKeyEvent('home'),
              ),
              const SizedBox(width: 12),
              _buildNavButton(
                Icons.apps,
                'Apps',
                () => session.sendKeyEvent('apps'),
              ),
              const SizedBox(width: 12),
              _buildNavButton(
                Icons.link_off,
                'Ngắt kết nối',
                () => session.disconnect(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onPressed) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: onSurfaceVariant, size: 20),
          ),
        ),
      ),
    );
  }

  Color _getStateColor(ScrcpyState state) {
    switch (state) {
      case ScrcpyState.connected:
        return Colors.green;
      case ScrcpyState.connecting:
        return Colors.orange;
      case ScrcpyState.error:
        return Colors.red;
      case ScrcpyState.disconnected:
        return Colors.grey;
    }
  }
}

class DotIndicator extends StatelessWidget {
  final Color color;
  const DotIndicator({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 4, spreadRadius: 1)],
      ),
    );
  }
}

class _UnsupportedPlatformView extends StatelessWidget {
  const _UnsupportedPlatformView();

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.usb_off, size: 64, color: onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Tính năng này chỉ khả dụng trên Web',
            style: TextStyle(color: onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Dialog cấu hình tùy chọn scrcpy trước khi kết nối.
class ScrcpyOptionsDialog extends StatefulWidget {
  final ScrcpyOptions currentOptions;
  final bool isDark;

  const ScrcpyOptionsDialog({
    super.key,
    required this.currentOptions,
    required this.isDark,
  });

  @override
  State<ScrcpyOptionsDialog> createState() => _ScrcpyOptionsDialogState();
}

class _ScrcpyOptionsDialogState extends State<ScrcpyOptionsDialog> {
  late ScrcpyOptions _opts;
  final TextEditingController _customWidthCtrl = TextEditingController();
  final TextEditingController _customHeightCtrl = TextEditingController();
  final TextEditingController _bitRateCtrl = TextEditingController();
  final TextEditingController _audioBitRateCtrl = TextEditingController();

  List<String> get _resolutionOptions => ['default', 'original', 'custom'];
  List<String> get _videoCodecOptions => ['h264', 'h265', 'av1'];
  List<String> get _audioCodecOptions => ['opus', 'aac', 'raw'];
  List<String> get _audioSourceOptions => [
        'output',
        'playback',
        'mic-unprocessed',
        'mic-camcorder',
        'mic-voice-recognition',
        'mic-voice-communication',
        'voice-call',
        'voice-call-uplink',
        'voice-call-downlink',
        'voice-performance',
      ];
  List<String> get _angleOptions => ['0', '90', '180', '270'];

  bool get _isCustomResolution => _opts.resolution == 'custom';
  bool get _isCameraMirror => _opts.cameraMirror;
  bool get _isAudio => _opts.audio;

  @override
  void initState() {
    super.initState();
    _opts = widget.currentOptions;
    _customWidthCtrl.text = _opts.customWidth.toString();
    _customHeightCtrl.text = _opts.customHeight.toString();
    _bitRateCtrl.text = _formatBitRate(_opts.videoBitRate);
    _audioBitRateCtrl.text = _formatBitRate(_opts.audioBitRate);
  }

  @override
  void dispose() {
    _customWidthCtrl.dispose();
    _customHeightCtrl.dispose();
    _bitRateCtrl.dispose();
    _audioBitRateCtrl.dispose();
    super.dispose();
  }

  static String _formatBitRate(int bps) {
    if (bps >= 1_000_000) return '${(bps / 1_000_000).toStringAsFixed(1)} Mbps';
    if (bps >= 1_000) return '${bps / 1_000} kbps';
    return '$bps bps';
  }

  static int _parseBitRate(String s) {
    s = s.trim().toLowerCase();
    final regex = RegExp(r'([\d.]+)\s*(Mbps|Kbps|kbps|mbps|kbps|bps)?');
    final m = regex.firstMatch(s);
    if (m == null) return 8_000_000;
    final num = double.tryParse(m.group(1) ?? '') ?? 8.0;
    final unit = (m.group(2) ?? 'Mbps').toLowerCase();
    if (unit.contains('mbps')) return (num * 1_000_000).round();
    if (unit.contains('kbps')) return (num * 1_000).round();
    return num.round();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.tune, color: scheme.primary),
          const SizedBox(width: 8),
          const Text('Tùy chọn Scrcpy'),
        ],
      ),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(scheme, 'Video', [
                _buildSwitch('Bật video', 'Bật hoặc tắt luồng video',
                    _opts.video, (v) => setState(() => _opts = _opts.copyWith(video: v))),
                const SizedBox(height: 12),
                _buildDropdown<String>(
                  title: 'Độ phân giải',
                  value: _opts.resolution,
                  items: _resolutionOptions,
                  onChanged: (v) => setState(
                    () {
                      _opts = _opts.copyWith(
                        resolution: v!,
                        customWidth: v == 'custom' ? _opts.customWidth : 1080,
                        customHeight: v == 'custom' ? _opts.customHeight : 1920,
                      );
                      if (v != 'custom') {
                        _customWidthCtrl.text = '1080';
                        _customHeightCtrl.text = '1920';
                      }
                    },
                  ),
                ),
                if (_isCustomResolution) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customWidthCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: ' Rộng',
                            labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: scheme.outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: scheme.primary, width: 2),
                            ),
                          ),
                          onChanged: (v) => setState(
                            () =>
                                _opts = _opts.copyWith(customWidth: int.tryParse(v) ?? 1080),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _customHeightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: ' Cao',
                            labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: scheme.outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: scheme.primary, width: 2),
                            ),
                          ),
                          onChanged: (v) => setState(
                            () => _opts =
                                _opts.copyWith(customHeight: int.tryParse(v) ?? 1920),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _buildBitRateRow('Video bitrate', _bitRateCtrl,
                    _opts.videoBitRate, (v) => setState(() => _opts = _opts.copyWith(videoBitRate: v))),
                const SizedBox(height: 12),
                _buildDropdown<String>(
                  title: 'Video codec',
                  value: _opts.videoCodec,
                  items: _videoCodecOptions,
                  onChanged: (v) =>
                      setState(() => _opts = _opts.copyWith(videoCodec: v!)),
                ),
                const SizedBox(height: 12),
                _buildSlider<int>(
                  title: 'FPS tối đa',
                  value: _opts.maxFps,
                  min: 0,
                  max: 120,
                  step: 1,
                  format: (v) => v == 0 ? 'Không giới hạn' : '$v fps',
                  onChanged: (v) =>
                      setState(() => _opts = _opts.copyWith(maxFps: v)),
                ),
              ]),
              _buildDividing(scheme),
              _buildSection(scheme, 'Âm thanh', [
                _buildSwitch(
                  'Bật âm thanh',
                  'Phát âm thanh từ điện thoại ra loa máy tính',
                  _isAudio,
                  (v) => setState(() => _opts = _opts.copyWith(audio: v)),
                ),
                if (_isAudio) ...[
                  const SizedBox(height: 12),
                  _buildDropdown<String>(
                    title: 'Audio codec',
                    value: _opts.audioCodec,
                    items: _audioCodecOptions,
                    onChanged:
                        (v) => setState(() => _opts = _opts.copyWith(audioCodec: v!)),
                  ),
                  const SizedBox(height: 12),
                  _buildBitRateRow('Audio bitrate', _audioBitRateCtrl,
                      _opts.audioBitRate, (v) => setState(() => _opts = _opts.copyWith(audioBitRate: v))),
                  const SizedBox(height: 12),
                  _buildDropdown<String>(
                    title: 'Nguồn âm thanh',
                    value: _opts.audioSource,
                    items: _audioSourceOptions,
                    onChanged: (v) =>
                        setState(() => _opts = _opts.copyWith(audioSource: v!)),
                  ),
                ],
              ]),
              _buildDividing(scheme),
              _buildSection(scheme, 'Màn hình', [
                _buildSwitch('Điều khiển (chuột/bàn phím)',
                    'Mở rộng quyền kiểm soát để điều khiển điện thoại từ bàn phím',
                    _opts.control, (v) => setState(() => _opts = _opts.copyWith(control: v))),
                const SizedBox(height: 12),
                _buildSwitch('Đồng bộ clipboard',
                    'Cho phép sao chép/dán giữa máy tính và điện thoại',
                    _opts.clipboardAutosync,
                    (v) =>
                        setState(() => _opts = _opts.copyWith(clipboardAutosync: v))),
                const SizedBox(height: 12),
                _buildSwitch('Giữ màn hình sáng',
                    'Ngăn màn hình điện thoại tắt trong khi kết nối',
                    _opts.stayAwake,
                    (v) => setState(() => _opts = _opts.copyWith(stayAwake: v))),
                const SizedBox(height: 12),
                _buildSwitch('Hiển thị điểm chạm',
                    'Hiển thị các chạm trên màn hình (tiện ghi màn hình)',
                    _opts.showTouches,
                    (v) =>
                        setState(() => _opts = _opts.copyWith(showTouches: v))),
                const SizedBox(height: 12),
                _buildDropdown<String>(
                  title: 'Xoay màn hình',
                  value: _opts.angle.toString(),
                  items: _angleOptions,
                  onChanged: (v) => setState(
                    () => _opts = _opts.copyWith(angle: int.tryParse(v!) ?? 0),
                  ),
                ),
              ]),
              _buildDividing(scheme),
              _buildSection(scheme, 'Camera', [
                _buildSwitch(
                  'Camera mirroring',
                  'Hiển thị camera sau của điện thoại trên màn hình',
                  _isCameraMirror,
                  (v) => setState(
                    () => _opts = _opts.copyWith(cameraMirror: v),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _opts),
          child: const Text('Kết nối'),
        ),
      ],
    );
  }

  Widget _buildSection(
    ColorScheme scheme,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.primary,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildDividing(ColorScheme scheme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Divider(color: scheme.outlineVariant, height: 1),
      );

  Widget _buildSwitch(
    String label,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Switch(value: value, onChanged: onChanged),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                description,
                style: TextStyle(
                    fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String title,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
          items: items.map((T v) => DropdownMenuItem<T>(
                value: v,
                child: Text(v.toString()),
              )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSlider<T extends num>({
    required String title,
    required T value,
    required int min,
    required int max,
    required int step,
    required String Function(T) format,
    required ValueChanged<T> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              format(value),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max == 0 ? 1 : max,
          label: format(value),
          onChanged: (v) => onChanged(v.toInt() as T),
        ),
      ],
    );
  }

  Widget _buildBitRateRow(
    String label,
    TextEditingController controller,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
              ),
              helperText: _formatBitRate(value),
              helperStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => onChanged(_parseBitRate(v)),
          ),
        ),
      ],
    );
  }
}
