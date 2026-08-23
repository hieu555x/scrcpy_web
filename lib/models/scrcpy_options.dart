/// Mô hình tùy chọn scrcpy được người dùng cấu hình trước khi kết nối.
class ScrcpyOptions {
  // --- Video ---
  /// Bật/tắt video. Mặc định: true.
  final bool video;

  /// Độ phân giải: 'default' (mặc định), 'original' (theo thiết bị), hoặc
  /// 'custom' → dùng [customWidth] và [customHeight].
  final String resolution;

  /// Chiều rộng tùy chỉnh (chỉ dùng khi [resolution] == 'custom').
  final int customWidth;

  /// Chiều cao tùy chỉnh (chỉ dùng khi [resolution] == 'custom').
  final int customHeight;

  /// Bit rate video (bit/giây). Mặc định: 8_000_000 (8 Mbps).
  final int videoBitRate;

  /// FPS tối đa. 0 = không giới hạn. Mặc định: 0.
  final int maxFps;

  /// Video codec: h264, h265, av1. Mặc định: h264.
  final String videoCodec;

  // --- Audio ---
  /// Bật/tắt âm thanh. Mặc định: true.
  final bool audio;

  /// Audio codec: opus, aac, raw. Mặc định: opus.
  final String audioCodec;

  /// Bit rate âm thanh (bit/giây). Mặc định: 128_000 (128 kbps).
  final int audioBitRate;

  /// Nguồn âm thanh. Mặc định: 'output'.
  final String audioSource;

  // --- Screen ---
  /// Cho phép điều khiển từ bàn phím/chuột. Mặc định: true.
  final bool control;

  /// Gửi metadata frame (kích thước video thay đổi). Mặc định: true.
  final bool sendFrameMeta;

  /// Đồng bộ clipboard 2 chiều. Mặc định: true.
  final bool clipboardAutosync;

  /// Giữ màn hình thiết bị sáng. Mặc định: false.
  final bool stayAwake;

  // --- Camera ---
  /// Bật/tắt camera mirroring. Mặc định: false.
  final bool cameraMirror;

  // --- Các option khác ---
  /// Góc xoay màn hình (0, 90, 180, 270). Mặc định: 0.
  final int angle;

  /// Hiển thị điểm chạm. Mặc định: false.
  final bool showTouches;

  const ScrcpyOptions({
    this.video = true,
    this.resolution = 'default',
    this.customWidth = 1080,
    this.customHeight = 1920,
    this.videoBitRate = 8_000_000,
    this.maxFps = 0,
    this.videoCodec = 'h264',
    this.audio = true,
    this.audioCodec = 'opus',
    this.audioBitRate = 128_000,
    this.audioSource = 'output',
    this.control = true,
    this.sendFrameMeta = true,
    this.clipboardAutosync = true,
    this.stayAwake = false,
    this.cameraMirror = false,
    this.angle = 0,
    this.showTouches = false,
  });

  ScrcpyOptions copyWith({
    bool? video,
    String? resolution,
    int? customWidth,
    int? customHeight,
    int? videoBitRate,
    int? maxFps,
    String? videoCodec,
    bool? audio,
    String? audioCodec,
    int? audioBitRate,
    String? audioSource,
    bool? control,
    bool? sendFrameMeta,
    bool? clipboardAutosync,
    bool? stayAwake,
    bool? cameraMirror,
    int? angle,
    bool? showTouches,
  }) {
    return ScrcpyOptions(
      video: video ?? this.video,
      resolution: resolution ?? this.resolution,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      videoBitRate: videoBitRate ?? this.videoBitRate,
      maxFps: maxFps ?? this.maxFps,
      videoCodec: videoCodec ?? this.videoCodec,
      audio: audio ?? this.audio,
      audioCodec: audioCodec ?? this.audioCodec,
      audioBitRate: audioBitRate ?? this.audioBitRate,
      audioSource: audioSource ?? this.audioSource,
      control: control ?? this.control,
      sendFrameMeta: sendFrameMeta ?? this.sendFrameMeta,
      clipboardAutosync: clipboardAutosync ?? this.clipboardAutosync,
      stayAwake: stayAwake ?? this.stayAwake,
      cameraMirror: cameraMirror ?? this.cameraMirror,
      angle: angle ?? this.angle,
      showTouches: showTouches ?? this.showTouches,
    );
  }

  Map<String, dynamic> toJson() => {
        'video': video,
        'resolution': resolution,
        'customWidth': customWidth,
        'customHeight': customHeight,
        'videoBitRate': videoBitRate,
        'maxFps': maxFps,
        'videoCodec': videoCodec,
        'audio': audio,
        'audioCodec': audioCodec,
        'audioBitRate': audioBitRate,
        'audioSource': audioSource,
        'control': control,
        'sendFrameMeta': sendFrameMeta,
        'clipboardAutosync': clipboardAutosync,
        'stayAwake': stayAwake,
        'cameraMirror': cameraMirror,
        'angle': angle,
        'showTouches': showTouches,
      };

  factory ScrcpyOptions.fromJson(Map<String, dynamic> json) => ScrcpyOptions(
        video: json['video'] ?? true,
        resolution: json['resolution'] ?? 'default',
        customWidth: json['customWidth'] ?? 1080,
        customHeight: json['customHeight'] ?? 1920,
        videoBitRate: json['videoBitRate'] ?? 8_000_000,
        maxFps: json['maxFps'] ?? 0,
        videoCodec: json['videoCodec'] ?? 'h264',
        audio: json['audio'] ?? true,
        audioCodec: json['audioCodec'] ?? 'opus',
        audioBitRate: json['audioBitRate'] ?? 128_000,
        audioSource: json['audioSource'] ?? 'output',
        control: json['control'] ?? true,
        sendFrameMeta: json['sendFrameMeta'] ?? true,
        clipboardAutosync: json['clipboardAutosync'] ?? true,
        stayAwake: json['stayAwake'] ?? false,
        cameraMirror: json['cameraMirror'] ?? false,
        angle: json['angle'] ?? 0,
        showTouches: json['showTouches'] ?? false,
      );

  static const ScrcpyOptions defaults = ScrcpyOptions();
}
