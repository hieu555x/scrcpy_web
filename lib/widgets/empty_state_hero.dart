import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Trang rỗng: lời mời hành động duy nhất - cắm điện thoại và kết nối.
/// Ba bước đánh số vì đây là trình tự thật người dùng phải theo.
class EmptyStateHero extends StatelessWidget {
  final VoidCallback onConnect;

  const EmptyStateHero({super.key, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.mint : AppColors.mintDeep)
                      .withAlpha(24),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (isDark ? AppColors.mint : AppColors.mintDeep)
                        .withAlpha(70),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.usb,
                  size: 30,
                  color: isDark ? AppColors.mint : AppColors.mintDeep,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cắm điện thoại để bắt đầu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mirror màn hình, truyền âm thanh và điều khiển Android '
                'ngay trong trình duyệt qua WebUSB.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              _Steps(isDark: isDark),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onConnect,
                icon: const Icon(Icons.usb, size: 18),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('Kết nối thiết bị'),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.mint : AppColors.mintDeep,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  final bool isDark;

  const _Steps({required this.isDark});

  static const _items = [
    (
      '01',
      'Bật Gỡ lỗi USB',
      'Trong Cài đặt > Tuỳ chọn nhà phát triển trên điện thoại',
    ),
    (
      '02',
      'Cắm cáp dữ liệu',
      'Dùng cáp USB hỗ trợ truyền dữ liệu, không phải cáp sạc thường',
    ),
    (
      '03',
      'Chọn thiết bị trong trình duyệt',
      'Nhấn Kết nối thiết bị rồi chọn máy trong hộp thoại quyền USB',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = isDark ? AppColors.mint : AppColors.mintDeep;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final (num, title, desc) in _items)
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 190),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh.withAlpha(90),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    num,
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.45,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Màn hình hiển thị khi chạy trên nền tảng không phải web.
class UnsupportedPlatformView extends StatelessWidget {
  const UnsupportedPlatformView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.usb_off, size: 56, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Tính năng này chỉ khả dụng trên trình duyệt web',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
