# Scrcpy Web — Điều khiển Android từ trình duyệt

Ứng dụng Flutter Web cho phép điều khiển điện thoại Android trực tiếp từ trình duyệt
thông qua **WebUSB**, không cần cài đặt ứng dụng trên máy tính.

## Tính năng

- Kết nối Android qua WebUSB (ADB over USB)
- Hiển thị màn hình điện thoại real-time (WebCodecs + WebGL)
- Điều khiển chuột/cảm ứng (hỗ trợ cả touch trên thiết bị di động)
- Gõ bàn phím PC → thiết bị (ký tự, Backspace, Enter, phím mũi tên...; Esc = Back)
- Ngắt kết nối an toàn từ UI
- Chỉ báo trạng thái kết nối đồng bộ giữa Flutter ↔ iframe
- Giao diện dark mode hiện đại, responsive layout

## Yêu cầu hệ thống

- Trình duyệt: Chrome 81+ hoặc Edge 81+ (hỗ trợ WebUSB)
- Android: đã bật **Gỡ lỗi USB (USB Debugging)**
- Cáp: dây sạc USB để kết nối
- Trang phải được phục vụ qua `https://` hoặc `localhost` (WebUSB yêu cầu secure context)

## Cài đặt

```bash
# Clone repository
git clone <repository-url>
cd scrcpy_web

# Cài đặt dependencies
flutter pub get

# Chạy trên web
flutter run -d chrome
```

## Cách sử dụng

1. Mở ứng dụng trên trình duyệt Chrome/Edge
2. Nhấn **Kết Nối Điện Thoại** trong iframe
3. Chọn thiết bị Android trong hộp thoại quyền USB của trình duyệt
4. Xác nhận quyền gỡ lỗi trên màn hình điện thoại
5. Bắt đầu điều khiển!
6. Nhấn **✕ Ngắt kết nối** (trên canvas hoặc thanh dưới Flutter) để ngắt kết nối an toàn

## Kiến trúc

```
lib/
├── main.dart                          # Entry point
├── models/
│   └── scrcpy_state.dart              # Enum trạng thái kết nối
├── services/
│   ├── scrcpy_service.dart            # Interface trừu tượng
│   ├── scrcpy_web_service.dart        # Web impl (package:web + js_interop)
│   └── scrcpy_service_stub.dart       # Stub cho nền tảng khác web
├── viewmodels/
│   └── scrcpy_view_model.dart         # Quản lý state (ChangeNotifier)
└── widgets/
    └── scrcpy_web_widget.dart         # Widget chính (HtmlElementView)
web/
├── index.html                         # HTML entry point
├── scrcpy_frame.html                  # Logic WebUSB/scrcpy (JS)
├── vendor/                            # Thư viện @yume-chan bundle cục bộ
└── scrcpy-server.jar                  # Server scrcpy chạy trên điện thoại
```

### Luồng giao tiếp Flutter ↔ iframe

| Hướng | Kênh | Nội dung |
|---|---|---|
| Flutter → iframe | `postMessage` vào `contentWindow` (targetOrigin = origin hiện tại) | `{type: "keyEvent", key}`, `{type: "disconnect"}` |
| iframe → Flutter | `window.parent.postMessage` (targetOrigin = origin hiện tại) | `{type: "scrcpyState", state}` |

Cả hai chiều đều kiểm tra origin và chỉ chấp nhận same-origin message.

### Thư viện sử dụng

Các thư viện JavaScript được **bundle cục bộ** thành một file duy nhất
`web/vendor/scrcpy_bundle.js` (không phụ thuộc CDN lúc runtime):

- `@yume-chan/adb` — ADB over WebUSB
- `@yume-chan/adb-daemon-webusb` — Transport USB
- `@yume-chan/adb-credential-web` — Lưu credential ADB
- `@yume-chan/scrcpy` / `@yume-chan/adb-scrcpy` — Giao thức scrcpy
- `@yume-chan/scrcpy-decoder-webcodecs` — Giải mã video (WebCodecs/WebGL)

Bundle được build bằng esbuild để **dedupe dependency** — mọi package chia sẻ
chung một instance (tránh lỗi hai bản sao lớp `Adb` khi tải các bundle +esm
riêng lẻ từ CDN). Khi cần nâng cấp thư viện:

```bash
cd tools/jsbundle
# sửa version trong package.json nếu muốn
npm install
npm run build
```

## Phiên bản scrcpy-server

File `web/scrcpy-server.jar` phải tương thích với cấu hình giao thức trong
`web/scrcpy_frame.html`. Hiện tại đang dùng:

| Thành phần | Phiên bản |
|---|---|
| `scrcpy-server.jar` | **3.3.3** |
| Options class | `AdbScrcpyOptions3_3_3` (`version: "3.3.3"`) |

Nếu thay đổi server jar, hãy cập nhật class options tương ứng
(`AdbScrcpyOptions2_x`, `AdbScrcpyOptions3_x`...) trong `scrcpy_frame.html`.
Server jar tải về từ: https://github.com/Genymobile/scrcpy/releases

## Xử lý sự cố

### "The device is already in use by another program" / kết nối lại không được

Một tiến trình `adb.exe` (ADB server) trên máy tính — thường do **Android Studio**,
**VS Code extension** hoặc **scrcpy desktop** tự khởi động — đang chiếm độc quyền
giao diện USB của điện thoại, nên trình duyệt không thể chiếm.

Cách xử lý:

```bash
# Nhả USB interface trên máy tính
adb kill-server
```

hoặc đóng Android Studio / IDE đang chạy adb. Để hạn chế tái diễn:

- Đóng các IDE trước khi dùng ứng dụng web
- Tạo shortcut một cú bấm cho lệnh `adb kill-server` nếu hay cần
- Gỡ `platform-tools` nếu không cần adb trên desktop

Ứng dụng web đã tự động: reset thiết bị USB trước khi kết nối, thử bắt tay ADB
tối đa 3 lần, và phát hiện chính xác tình trạng bị chiếm USB để hiển thị hướng dẫn.

### Lỗi khác

- **Không thấy thiết bị trong hộp thoại chọn**: kiểm tra đã bật *Gỡ lỗi USB*
  và cáp hỗ trợ truyền dữ liệu (không phải cáp sạc thường)
- **Trang không mở được WebUSB**: phải chạy qua `https://` hoặc `localhost`
  (WebUSB yêu cầu secure context)
- **Timeout khi khởi động gương**: phiên bản `scrcpy-server.jar` phải khớp với
  cấu hình giao thức — xem phần *Phiên bản scrcpy-server*

## Testing

```bash
# Chạy tất cả tests
flutter test

# Chạy tests với coverage
flutter test --coverage
```

## Build

```bash
# Build cho web
flutter build web --release

# Build PWA
flutter build web --release --wasm
```

## License

MIT License

## Credits

- [scrcpy](https://github.com/Genymobile/scrcpy) — Dự án gốc
- [@yume-chan](https://github.com/yume-chan/ya-webadb) — Thư viện WebUSB/scrcpy cho web
