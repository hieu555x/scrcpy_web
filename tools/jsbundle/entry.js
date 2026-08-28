// Điểm vào bundle: re-export đúng những gì scrcpy_frame.html cần dùng.
// Tất cả package chia sẻ chung một instance dependency (npm dedupe),
// khắc phục lỗi hai bản sao lớp Adb khi dùng các bundle +esm riêng lẻ của jsDelivr.
export { Adb, AdbDaemonTransport } from "@yume-chan/adb";
export { AdbDaemonWebUsbDeviceManager } from "@yume-chan/adb-daemon-webusb";
export { default as AdbWebCredentialStore } from "@yume-chan/adb-credential-web";
export {
  AndroidKeyEventAction,
  AndroidKeyCode,
  AndroidMotionEventAction,
  AndroidMotionEventButton,
  AndroidScreenPowerMode,
  DefaultServerPath,
  ScrcpyAudioCodec,
  ScrcpyPointerId,
  ScrcpyNewDisplay as NewDisplay,
} from "@yume-chan/scrcpy";
export { AdbScrcpyClient, AdbScrcpyOptions3_3_3 } from "@yume-chan/adb-scrcpy";
export {
  BitmapVideoFrameRenderer,
  WebCodecsVideoDecoder,
  WebGLVideoFrameRenderer,
} from "@yume-chan/scrcpy-decoder-webcodecs";
