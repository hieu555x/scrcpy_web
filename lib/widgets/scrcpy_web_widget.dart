import 'dart:html' as html;
import 'dart:ui_web' as ui; // Phù hợp với Flutter 3.x trở lên
import 'package:flutter/material.dart';

class ScrcpyWebWidget extends StatefulWidget {
  const ScrcpyWebWidget({super.key});

  @override
  State<ScrcpyWebWidget> createState() => _ScrcpyWebWidgetState();
}

class _ScrcpyWebWidgetState extends State<ScrcpyWebWidget> {
  late final html.IFrameElement _iframeElement;

  @override
  void initState() {
    super.initState();

    // 1. Tạo một IFrameElement trỏ trực tiếp tới file HTML của chúng ta
    _iframeElement = html.IFrameElement()
      ..src =
          'scrcpy_frame.html' // Đường dẫn tương đối tới file trong thư mục web/
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    // 🔴 BƯỚC QUAN TRỌNG NHẤT: Cấp quyền USB cho IFrame!
    // Trình duyệt chặn tất cả các IFrame sử dụng WebUSB trừ khi thuộc tính allow="usb" được bật rõ ràng.
    _iframeElement.setAttribute('allow', 'usb');

    // 2. Đăng ký IFrame View Factory vào hệ thống render của Flutter Web
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'scrcpy-webusb-view',
      (int viewId) => _iframeElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khiển Android trực tiếp (Không cài đặt)'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 900,
          height: 700,
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2d2d34), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            // Hiển thị IFrame đã đăng ký
            child: HtmlElementView(viewType: 'scrcpy-webusb-view'),
          ),
        ),
      ),
    );
  }
}
