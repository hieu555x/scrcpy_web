import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/scrcpy_service_stub.dart'
    if (dart.library.js_interop) '../services/scrcpy_web_service.dart';
import '../viewmodels/scrcpy_view_model.dart';
import '../models/scrcpy_state.dart';

class ScrcpyWebWidget extends StatefulWidget {
  const ScrcpyWebWidget({super.key});

  @override
  State<ScrcpyWebWidget> createState() => _ScrcpyWebWidgetState();
}

class _ScrcpyWebWidgetState extends State<ScrcpyWebWidget> {
  late final ScrcpyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ScrcpyViewModel();
    // Nhận trạng thái kết nối từ iframe (connecting/connected/error/disconnected).
    scrcpyService.onStateChanged = _viewModel.updateState;
  }

  @override
  void dispose() {
    scrcpyService.onStateChanged = null;
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khiển Android (WebUSB)'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ValueListenableBuilder<ScrcpyState>(
              valueListenable: _viewModel.stateNotifier,
              builder: (context, state, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DotIndicator(color: _getStateColor(state)),
                    const SizedBox(width: 8),
                    Text(
                      _getStateText(state),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: constraints.maxWidth > 900 ? 900 : constraints.maxWidth * 0.95,
              height: constraints.maxHeight > 700 ? 700 : constraints.maxHeight * 0.9,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1e),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2d2d34), width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 5)),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: kIsWeb
                    ? const HtmlElementView(viewType: 'scrcpy-webusb-view')
                    : const _UnsupportedPlatformView(),
              ),
            ),
          );
        },
      ),
      bottomSheet: ValueListenableBuilder<ScrcpyState>(
        valueListenable: _viewModel.stateNotifier,
        builder: (context, state, child) {
          if (state != ScrcpyState.connected) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1a1a1e),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavButton(Icons.chevron_left, 'Back', () => scrcpyService.sendKeyEvent('back')),
                const SizedBox(width: 24),
                _buildNavButton(Icons.home, 'Home', () => scrcpyService.sendKeyEvent('home')),
                const SizedBox(width: 24),
                _buildNavButton(Icons.apps, 'Apps', () => scrcpyService.sendKeyEvent('apps')),
                const SizedBox(width: 24),
                _buildNavButton(Icons.link_off, 'Ngắt kết nối', () => scrcpyService.disconnect()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onPressed) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
        ),
      ),
    );
  }

  Color _getStateColor(ScrcpyState state) {
    switch (state) {
      case ScrcpyState.connected: return Colors.green;
      case ScrcpyState.connecting: return Colors.orange;
      case ScrcpyState.error: return Colors.red;
      case ScrcpyState.disconnected: return Colors.grey;
    }
  }

  String _getStateText(ScrcpyState state) {
    switch (state) {
      case ScrcpyState.connected: return 'Đã kết nối';
      case ScrcpyState.connecting: return 'Đang kết nối...';
      case ScrcpyState.error: return 'Lỗi';
      case ScrcpyState.disconnected: return 'Chưa kết nối';
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.usb_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tính năng này chỉ khả dụng trên Web',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
