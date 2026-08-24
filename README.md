<div align="center">

# Scrcpy Web

**Điều khiển điện thoại Android trực tiếp từ trình duyệt — không cần cài phần mềm**

[![Flutter](https://img.shields.io/badge/Flutter-Web-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![scrcpy](https://img.shields.io/badge/scrcpy--server-3.3.3-2EA043?style=flat-square)](https://github.com/Genymobile/scrcpy)
[![Chrome | Edge](https://img.shields.io/badge/Chrome%20%2F%20Edge-81%2B-4285F4?style=flat-square&logo=googlechrome&logoColor=white)](https://developer.mozilla.org/docs/Web/API/WebUSB_API)
[![License](https://img.shields.io/badge/License-MIT-8B5CF6?style=flat-square)](#license)

Kết nối qua **WebUSB** (ADB over USB) · Mirror màn hình real-time · Âm thanh · Điều khiển chuột & bàn phím

</div>

---

## Tính năng

| | |
|---|---|
| **Đa thiết bị** | Kết nối nhiều điện thoại cùng lúc — mỗi thiết bị một tab riêng, chuyển qua lại tự do |
| **Mirror real-time** | Màn hình điện thoại hiển thị mượt mà nhờ WebCodecs + WebGL (H.264 / H.265 / AV1) |
| **Âm thanh** | Truyền âm thanh từ điện thoại ra loa máy tính (Opus / AAC qua WebCodecs) |
| **Điều khiển chuột** | Click / kéo / cuộn; chuột phải = Back, chuột giữa = Home — giống scrcpy desktop |
| **Bàn phím PC → Android** | Gõ ký tự trực tiếp, phím điều hướng, Esc = Back |
| **Tắt màn hình điện thoại** | Điều khiển khi màn hình thật đã tắt — bật lại tự động khi ngắt kết nối |
| **Chụp màn hình** | Lưu khung hình gốc của điện thoại vào clipboard máy tính chỉ với một nút bấm |
| **Cấu hình linh hoạt** | Độ phân giải, bitrate, FPS, codec, xoay màn hình, camera mirroring... — tự lưu vào localStorage |
| **Clipboard sync** | Sao chép / dán hai chiều giữa máy tính và điện thoại |
| **Giao diện** | Dark / Light mode đồng bộ, responsive |

## Yêu cầu hệ thống

| Thành phần | Yêu cầu |
|---|---|
| Trình duyệt | Chrome 81+ hoặc Edge 81+ (hỗ trợ WebUSB) |
| Android | Đã bật **Gỡ lỗi USB (USB Debugging)** |
| Cáp | Dây USB hỗ trợ truyền dữ liệu (không phải cáp sạc thường) |
| Hosting | Trang phải chạy qua `https://` hoặc `localhost` (WebUSB yêu cầu secure context) |

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

## Sử dụng

1. Mở ứng dụng trên trình duyệt Chrome/Edge
2. Nhấn **Kết Nối Điện Thoại**
3. Chọn thiết bị Android trong hộp thoại quyền USB của trình duyệt
4. Xác nhận quyền gỡ lỗi trên màn hình điện thoại
5. Bắt đầu điều khiển!

> **Thêm thiết bị khác:** nhấn **＋** trên thanh app để mở tab kết nối mới.
> **Ngắt kết nối:** nút **✕ Ngắt kết nối** trên canvas hoặc thanh dưới.

## Kiến trúc

<details>
<summary><b>Cấu trúc dự án</b></summary>

```
lib/
├── main.dart                              # Entry point
├── models/
│   ├── scrcpy_options.dart                # Model tùy chọn scrcpy
│   └── scrcpy_state.dart                  # Enum trạng thái kết nối
├── services/
│   ├── scrcpy_service.dart                # Interface ScrcpySession + ScrcpyService
│   ├── scrcpy_web_service.dart            # Web impl: nhiều phiên, mỗi phiên 1 iframe
│   └── scrcpy_service_stub.dart           # Stub cho nền tảng khác web
├── viewmodels/
│   ├── scrcpy_sessions_view_model.dart    # Quản lý danh sách phiên (đa thiết bị)
│   └── theme_controller.dart              # Dark / Light mode
└── widgets/
    └── scrcpy_web_widget.dart             # Widget chính (tab thiết bị + IndexedStack)

web/
├── index.html                             # HTML entry point
├── scrcpy_frame.html                      # Logic WebUSB/scrcpy (JS) — mỗi iframe 1 phiên
├── vendor/scrcpy_bundle.js                # Bundle @yume-chan build bằng esbuild
└── scrcpy-server.jar                      # Server scrcpy chạy trên điện thoại

tools/jsbundle/                            # Nguồn bundle vendor (npm + esbuild)
```

</details>

<details>
<summary><b>Giao tiếp Flutter ↔ iframe</b></summary>

Mỗi phiên kết nối là một iframe độc lập. Flutter và iframe trao đổi qua `postMessage`
với kiểm tra same-origin ở cả hai chiều:

| Hướng | Kênh | Nội dung |
|---|---|---|
| Flutter → iframe | `postMessage` vào `contentWindow` (targetOrigin = origin hiện tại) | `{type: "keyEvent", key}` · `{type: "disconnect"}` · `{type: "theme", mode}` |
| iframe → Flutter | `window.parent.postMessage` (targetOrigin = origin hiện tại) | `{type: "scrcpyState", state}` |

Các nút Back/Home/Apps ở thanh dưới chỉ tác động lên tab đang chọn; bàn phím/chuột
tác động lên iframe đang focus.

</details>

<details>
<summary><b>Thư viện sử dụng</b></summary>

Các thư viện JavaScript được **bundle cục bộ** thành một file duy nhất
`web/vendor/scrcpy_bundle.js` (không phụ thuộc CDN lúc runtime):

| Package | Vai trò |
|---|---|
| `@yume-chan/adb` | ADB over WebUSB |
| `@yume-chan/adb-daemon-webusb` | Transport USB |
| `@yume-chan/adb-credential-web` | Lưu credential ADB |
| `@yume-chan/scrcpy` · `@yume-chan/adb-scrcpy` | Giao thức scrcpy |
| `@yume-chan/scrcpy-decoder-webcodecs` | Giải mã video (WebCodecs/WebGL) |

Bundle được build bằng esbuild để **dedupe dependency** — mọi package chia sẻ chung
một instance (tránh lỗi hai bản sao lớp `Adb` khi tải các bundle +esm riêng lẻ từ CDN).
Khi cần nâng cấp thư viện:

```bash
cd tools/jsbundle
# sửa version trong package.json nếu muốn
npm install
npm run build
```

</details>

## Phiên bản scrcpy-server

File `web/scrcpy-server.jar` phải tương thích với cấu hình giao thức trong
`web/scrcpy_frame.html`:

| Thành phần | Phiên bản |
|---|---|
| `scrcpy-server.jar` | **3.3.3** |
| Options class | `AdbScrcpyOptions3_3_3` (`version: "3.3.3"`) |

Nếu thay đổi server jar, hãy cập nhật class options tương ứng
(`AdbScrcpyOptions2_x`, `AdbScrcpyOptions3_x`...) trong `scrcpy_frame.html`.
Server jar tải về từ [scrcpy releases](https://github.com/Genymobile/scrcpy/releases).

## Xử lý sự cố

<details>
<summary><b>"The device is already in use by another program" / kết nối lại không được</b></summary>

Một tiến trình `adb.exe` (ADB server) trên máy tính — thường do **Android Studio**,
**VS Code extension** hoặc **scrcpy desktop** tự khởi động — đang chiếm độc quyền
giao diện USB của điện thoại, nên trình duyệt không thể chiếm.

```bash
# Nhả USB interface trên máy tính
adb kill-server
```

Hoặc đóng Android Studio / IDE đang chạy adb. Để hạn chế tái diễn:

- Đóng các IDE trước khi dùng ứng dụng web
- Tạo shortcut một cú bấm cho lệnh `adb kill-server` nếu hay cần
- Gỡ `platform-tools` nếu không cần adb trên desktop

Ứng dụng đã tự động xử lý: reset thiết bị USB trước khi kết nối, thử bắt tay ADB
tối đa 3 lần, và phát hiện chính xác tình trạng bị chiếm USB để hiển thị hướng dẫn.

</details>

<details>
<summary><b>Các lỗi thường gặp khác</b></summary>

| Hiện tượng | Nguyên nhân & cách xử lý |
|---|---|
| Không thấy thiết bị trong hộp thoại chọn | Bật *Gỡ lỗi USB* trên điện thoại; dùng cáp hỗ trợ truyền dữ liệu |
| Trang không mở được WebUSB | Phải chạy qua `https://` hoặc `localhost` (secure context) |
| Timeout khi khởi động gương | Phiên bản `scrcpy-server.jar` phải khớp cấu hình giao thức — xem phần trên |
| Không ghi được ảnh chụp vào clipboard | Trang cần đang được focus; nhấn lại nút sau khi click vào trang |
| Không nghe được âm thanh | Thiết bị phải hỗ trợ; kiểm tra tùy chọn codec âm thanh (Opus/AAC) |

</details>

## Build & Testing

```bash
# Build release cho web
flutter build web --release

# Build PWA (kèm wasm dry-run)
flutter build web --release --wasm

# Chạy tất cả tests
flutter test

# Tests với coverage
flutter test --coverage
```

## License

[MIT](LICENSE)

## Credits

- [scrcpy](https://github.com/Genymobile/scrcpy) — Dự án gốc
- [ya-webadb (@yume-chan)](https://github.com/yume-chan/ya-webadb) — Thư viện WebUSB/scrcpy cho web
