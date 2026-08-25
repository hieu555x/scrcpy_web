import 'dart:async';

import 'package:flutter/material.dart';
import '../models/scrcpy_state.dart';
import '../theme/app_theme.dart';

/// Chấm tín hiệu — phần tử nhận diện lặp lại khắp giao diện:
/// tab thiết bị, chip trạng thái, dock điều khiển.
/// Nhịp pulse chỉ chạy khi đang kết nối; tôn trọng giảm chuyển động.
class SignalDot extends StatefulWidget {
  final Color color;
  final bool pulse;
  final double size;

  const SignalDot({
    super.key,
    required this.color,
    this.pulse = false,
    this.size = 8,
  });

  @override
  State<SignalDot> createState() => _SignalDotState();
}

class _SignalDotState extends State<SignalDot> with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (widget.pulse && !reduced && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    } else if ((!widget.pulse || reduced) && _controller != null) {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void didUpdateWidget(covariant SignalDot old) {
    super.didUpdateWidget(old);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final shouldPulse = widget.pulse && !reduced;
    if (shouldPulse && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    } else if (!shouldPulse && _controller != null) {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final core = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withAlpha(110),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    final controller = _controller;
    if (controller == null) return core;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size + t * 8,
              height: widget.size + t * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withAlpha(((1 - t) * 90).round()),
              ),
            ),
            core,
          ],
        );
      },
    );
  }
}

/// Hiệu ứng vào trang: trượt nhẹ + hiện dần, lệch nhau theo [delay].
/// Bỏ qua hoàn toàn khi người dùng bật giảm chuyển động.
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeIn({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        setState(() => _visible = true);
        return;
      }
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _visible = true);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.015),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Khối thương hiệu: ô vuông bo góc chứa chấm tín hiệu + wordmark
/// Space Grotesk + nhãn kỹ thuật WebUSB bằng mono.
class BrandMark extends StatelessWidget {
  final bool isDark;

  const BrandMark({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDark ? AppColors.mint : AppColors.mintDeep,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: SignalDot(
            color: isDark ? AppColors.bg : Colors.white,
            size: 9,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Scrcpy Web',
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            'WEBUSB',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Nút hành động chính "Kết nối thiết bị" trên thanh trên.
class ConnectButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ConnectButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.usb, size: 17),
      label: const Text('Kết nối thiết bị'),
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );
  }
}

/// Trạng thái kết nối dạng chữ mono in hoa kèm chấm tín hiệu.
class StatusChip extends StatelessWidget {
  final ScrcpyState state;
  final bool isDark;

  const StatusChip({super.key, required this.state, required this.isDark});

  String get _label {
    switch (state) {
      case ScrcpyState.connected:
        return 'ĐÃ KẾT NỐI';
      case ScrcpyState.connecting:
        return 'ĐANG KẾT NỐI';
      case ScrcpyState.error:
        return 'LỖI';
      case ScrcpyState.disconnected:
        return 'CHƯA KẾT NỐI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.stateColor(isDark, state.name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: color.withAlpha(26),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SignalDot(color: color, pulse: state == ScrcpyState.connecting),
          const SizedBox(width: 7),
          Text(
            _label,
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
