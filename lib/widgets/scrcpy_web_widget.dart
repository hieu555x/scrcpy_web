import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/scrcpy_service_stub.dart'
    if (dart.library.js_interop) '../services/scrcpy_web_service.dart';
import '../viewmodels/scrcpy_sessions_view_model.dart';
import '../viewmodels/theme_controller.dart';
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
          : AnimatedBuilder(
              animation: _viewModel,
              builder: (context, _) => _buildBottomSheet(),
            ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final sessions = _viewModel.sessions;
    if (sessions.isEmpty) return _buildEmpty(context);

    final scheme = Theme.of(context).colorScheme;

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
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              child: IndexedStack(
                index: _viewModel.activeIndex,
                children: [
                  for (final session in sessions)
                    HtmlElementView(viewType: session.viewType),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildBottomSheet() {
    final active = _viewModel.active;
    if (active == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<ScrcpyState>(
      valueListenable: active.state,
      builder: (context, state, _) {
        if (state != ScrcpyState.connected) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: scheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton(
                Icons.chevron_left,
                'Back',
                () => active.sendKeyEvent('back'),
              ),
              const SizedBox(width: 24),
              _buildNavButton(
                Icons.home,
                'Home',
                () => active.sendKeyEvent('home'),
              ),
              const SizedBox(width: 24),
              _buildNavButton(
                Icons.apps,
                'Apps',
                () => active.sendKeyEvent('apps'),
              ),
              const SizedBox(width: 24),
              _buildNavButton(
                Icons.link_off,
                'Ngắt kết nối',
                () => active.disconnect(),
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
