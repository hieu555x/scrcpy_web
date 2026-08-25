import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/scrcpy_state.dart';
import '../services/scrcpy_service.dart';
import '../services/scrcpy_service_stub.dart'
    if (dart.library.js_interop) '../services/scrcpy_web_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/scrcpy_sessions_view_model.dart';
import '../viewmodels/theme_controller.dart';
import 'deck_widgets.dart';
import 'empty_state_hero.dart';

/// Shell "Ban dieu khien": thanh thuong hieu mong, dai tab thiet bi,
/// san khau mirror chiem toi da khong gian, dock dieu khien duoi day.
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

  bool get _isDark => widget.themeController.isDark;

  String get _currentThemeMode => _isDark ? 'dark' : 'light';

  void _addSession() {
    if (!kIsWeb) return;
    final session = _viewModel.addSession();
    // Dong bo theme hien tai cho iframe moi tao.
    session.setTheme(_currentThemeMode);
  }

  void _toggleTheme() {
    widget.themeController.toggle();
    // Ap dung cho toan bo phien dang mo.
    final mode = _currentThemeMode;
    for (final session in List.of(_viewModel.sessions)) {
      session.setTheme(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => SafeArea(
          child: Column(
            children: [
              FadeIn(child: _buildTopBar(context)),
              if (!kIsWeb)
                const Expanded(child: UnsupportedPlatformView())
              else ...[
                if (_viewModel.sessions.isNotEmpty)
                  FadeIn(
                    delay: const Duration(milliseconds: 60),
                    child: _buildTabStrip(context),
                  ),
                Expanded(
                  child: FadeIn(
                    delay: const Duration(milliseconds: 120),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _viewModel.sessions.isEmpty
                          ? EmptyStateHero(onConnect: _addSession)
                          : _buildStage(context),
                    ),
                  ),
                ),
                if (_viewModel.sessions.isNotEmpty)
                  FadeIn(
                    delay: const Duration(milliseconds: 180),
                    child: _buildControlDock(context),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Thanh trên ─────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          BrandMark(isDark: _isDark),
          const Spacer(),
          IconButton(
            onPressed: kIsWeb ? _toggleTheme : null,
            tooltip: _isDark
                ? 'Chuyển sang giao diện sáng'
                : 'Chuyển sang giao diện tối',
            icon: Icon(
              _isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          ConnectButton(onPressed: kIsWeb ? _addSession : null),
        ],
      ),
    );
  }

  // ── Dải tab thiết bị ────────────────────────────────────────

  Widget _buildTabStrip(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        itemCount: _viewModel.sessions.length,
        itemBuilder: (context, index) => _DeviceTab(
          index: index,
          viewModel: _viewModel,
          isDark: _isDark,
          onClose: () => _viewModel.removeSession(index),
        ),
      ),
    );
  }

  // ── Sân khấu mirror ────────────────────────────────────────

  Widget _buildStage(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sessions = _viewModel.sessions;
    final gridMode = sessions.length > 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Platform view DUY NHẤT chứa mọi iframe — const nên không bao
            // giờ bị tạo lại; layout điều khiển bằng CSS.
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
                              top: 10,
                              left: i * colWidth + 10,
                              child: ValueListenableBuilder<ScrcpyState>(
                                valueListenable:
                                    _viewModel.sessions[i].state,
                                builder: (context, state, _) => _RegionBadge(
                                  label: 'Thiết bị ${i + 1}',
                                  stateColor: AppColors.stateColor(
                                    _isDark,
                                    state.name,
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
    );
  }

  // ── Dock điều khiển ────────────────────────────────────────

  Widget _buildControlDock(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final single = _viewModel.sessions.length == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final session in _viewModel.sessions)
                Expanded(child: _sessionControls(session)),
            ],
          ),
        ),
        // Gợi ý phím tắt - chỉ hiển thị khi đủ chỗ (một thiết bị).
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            height: 18,
            child: single
                ? Row(
                    children: [
                      const Spacer(),
                      Text(
                        'Esc = Back   ·   Chuột phải = Back   ·   '
                        'Chuột giữa = Home',
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontSize: 10.5,
                          letterSpacing: 0.3,
                          color: scheme.onSurfaceVariant.withAlpha(150),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  /// Nhóm điều khiển của một vùng màn hình, chia đều theo cột phía trên.
  Widget _sessionControls(ScrcpySession session) {
    return ValueListenableBuilder<ScrcpyState>(
      valueListenable: session.state,
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip(state: state, isDark: _isDark),
                const SizedBox(width: 12),
                if (state == ScrcpyState.connected) ...[
                  _NavButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: 'Back (Esc)',
                    onTap: () => session.sendKeyEvent('back'),
                  ),
                  _NavButton(
                    icon: Icons.home_outlined,
                    tooltip: 'Home (chuột giữa)',
                    onTap: () => session.sendKeyEvent('home'),
                  ),
                  _NavButton(
                    icon: Icons.apps,
                    tooltip: 'Mở danh sách ứng dụng',
                    onTap: () => session.sendKeyEvent('apps'),
                  ),
                  const SizedBox(width: 6),
                  _NavButton(
                    icon: Icons.link_off_rounded,
                    tooltip: 'Ngắt kết nối thiết bị',
                    danger: true,
                    onTap: session.disconnect,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tab một thiết bị trong dải tab: chấm tín hiệu + tên + nút đóng.
class _DeviceTab extends StatelessWidget {
  final int index;
  final ScrcpySessionsViewModel viewModel;
  final bool isDark;
  final VoidCallback onClose;

  const _DeviceTab({
    required this.index,
    required this.viewModel,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final session = viewModel.sessions[index];
    final selected = index == viewModel.activeIndex;
    final stateColor =
        AppColors.stateColor(isDark, session.state.value.name);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected
            ? scheme.surfaceContainerHigh
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: BorderSide(
            color: selected ? scheme.outline : Colors.transparent,
          ),
        ),
        child: InkWell(
          onTap: () => viewModel.setActive(index),
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 0, 5, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SignalDot(
                  color: stateColor,
                  pulse: session.state.value == ScrcpyState.connecting,
                ),
                const SizedBox(width: 9),
                Text(
                  'Thiết bị ${index + 1}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 2),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: scheme.onSurfaceVariant.withAlpha(
                        selected ? 255 : 140,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nhãn vùng màn hình khi nhiều thiết bị hiển thị cạnh nhau.
class _RegionBadge extends StatelessWidget {
  final String label;
  final Color stateColor;

  const _RegionBadge({required this.label, required this.stateColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SignalDot(color: stateColor, size: 7),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textHigh : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút điều hướng trong dock: icon trơn, viền mảnh khi hover.
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool danger;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        color: danger ? AppColors.coral : scheme.onSurfaceVariant,
        hoverColor: (danger ? AppColors.coral : scheme.primary).withAlpha(30),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
