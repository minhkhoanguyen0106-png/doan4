import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// CẤU HÌNH VIDEO HƯỚNG DẪN HỆ THỐNG PONDORA (SYSTEM TUTORIAL VIDEO CONFIG)
/// ============================================================================
/// Dán đường dẫn URL video hướng dẫn vào hằng số kDefaultTutorialVideoUrl bên dưới.
/// Hỗ trợ: file .mp4, .webm, link stream CDN / Cloudflare / S3 trực tiếp.
/// Nếu để trống (""), hệ thống sẽ hiển thị ảnh Poster nghệ thuật cùng trạng thái
/// chờ video thực tế từ quản trị viên, tuyệt đối không hiển thị video mẫu sai nội dung.
const String kDefaultTutorialVideoUrl = ''; // <-- DÁN LINK VIDEO TẠI ĐÂY KHI CÓ VIDEO THẬT
const String kDefaultTutorialVideoPoster = 'assets/images/video_poster.jpg';

/// Tutorial video step information for the interactive system walkthrough
class _TutorialStep {
  final String timeCode;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String keyMetric;
  final String metricValue;
  final String statusText;

  const _TutorialStep({
    required this.timeCode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.keyMetric,
    required this.metricValue,
    required this.statusText,
  });
}

class TutorialVideoPlayer extends StatefulWidget {
  const TutorialVideoPlayer({
    super.key,
    this.videoUrl = kDefaultTutorialVideoUrl,
    this.videoPoster = kDefaultTutorialVideoPoster,
    this.isDesktop = true,
    this.isAbyss = true,
    this.isFlippedOpen = false,
    this.onPlayStateChanged,
    this.onNavigateToOverview,
  });

  final String videoUrl;
  final String videoPoster;
  final bool isDesktop;
  final bool isAbyss;
  final bool isFlippedOpen;
  final ValueChanged<bool>? onPlayStateChanged;
  final VoidCallback? onNavigateToOverview;

  @override
  State<TutorialVideoPlayer> createState() => TutorialVideoPlayerState();
}

class TutorialVideoPlayerState extends State<TutorialVideoPlayer> {
  bool _isPlaying = false;
  bool _isMuted = false;
  double _volume = 0.85;
  double _playbackSpeed = 1.0;
  Duration _currentTime = Duration.zero;
  final Duration _totalDuration = const Duration(minutes: 4, seconds: 15);
  bool _isControlsHovered = false;
  bool _showControls = true;
  bool _isPlayHovered = false;
  Timer? _playbackTimer;
  Timer? _hideControlsTimer;

  static const List<_TutorialStep> _steps = [
    _TutorialStep(
      timeCode: '00:00 - 01:05',
      title: 'Bước 1: Máy đo tự động cắm tại ao',
      subtitle: 'Tự động đo độ pH, oxy và nhiệt độ nước liên tục 3 giây một lần.',
      icon: Icons.sensors_rounded,
      accentColor: Color(0xFF00D2FF),
      keyMetric: 'Tốc độ đo',
      metricValue: '3.0 Giây / Lần',
      statusText: 'Đo tự động liên tục ngày đêm',
    ),
    _TutorialStep(
      timeCode: '01:05 - 02:15',
      title: 'Bước 2: Tự tính khí độc NH₃',
      subtitle: 'Tự tính nồng độ khí độc từ pH và nhiệt độ nước, không cần mua máy đo đắt tiền.',
      icon: Icons.biotech_rounded,
      accentColor: Color(0xFF10B981),
      keyMetric: 'Độ chính xác',
      metricValue: 'Rất chuẩn xác',
      statusText: 'Tự tính theo công thức chuẩn',
    ),
    _TutorialStep(
      timeCode: '02:15 - 03:20',
      title: 'Bước 3: Báo động khi nước xấu',
      subtitle: 'Báo ngay khi thiếu oxy lúc nửa đêm, nước tụt pH sau mưa hoặc khí độc tăng cao.',
      icon: Icons.warning_amber_rounded,
      accentColor: Color(0xFFF59E0B),
      keyMetric: 'Thời gian báo',
      metricValue: '< 1 Giây',
      statusText: 'Cảnh báo chuông và màu đỏ rõ ràng',
    ),
    _TutorialStep(
      timeCode: '03:20 - 04:15',
      title: 'Bước 4: Gợi ý cách xử lý nước',
      subtitle: 'Hướng dẫn cụ thể lượng vôi, khoáng tạt hoặc men vi sinh cần đánh cho từng ao.',
      icon: Icons.psychology_rounded,
      accentColor: Color(0xFF8B5CF6),
      keyMetric: 'Liều lượng thuốc',
      metricValue: 'Tính theo thể tích ao',
      statusText: 'Dễ hiểu, dễ làm theo',
    ),
  ];

  int get _currentStepIndex {
    final sec = _currentTime.inSeconds;
    if (sec < 65) return 0;
    if (sec < 135) return 1;
    if (sec < 200) return 2;
    return 3;
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void pauseVideo() {
    if (_isPlaying) {
      _togglePlay(false);
    }
  }

  void _togglePlay([bool? forceState]) {
    final nextState = forceState ?? !_isPlaying;
    if (nextState == _isPlaying) return;

    setState(() {
      _isPlaying = nextState;
      if (_isPlaying) {
        _startPlaybackTimer();
        _scheduleHideControls();
      } else {
        _playbackTimer?.cancel();
        _showControls = true;
      }
    });

    widget.onPlayStateChanged?.call(_isPlaying);
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      final addedMs = (100 * _playbackSpeed).round();
      final newDuration = _currentTime + Duration(milliseconds: addedMs);

      if (newDuration >= _totalDuration) {
        setState(() {
          _currentTime = Duration.zero;
          _isPlaying = false;
          _playbackTimer?.cancel();
          _showControls = true;
        });
        widget.onPlayStateChanged?.call(false);
      } else {
        setState(() {
          _currentTime = newDuration;
        });
      }
    });
  }

  void _seekTo(double ratio) {
    final targetSec = (ratio.clamp(0.0, 1.0) * _totalDuration.inMilliseconds).round();
    setState(() {
      _currentTime = Duration(milliseconds: targetSec);
    });
  }

  void _skipSeconds(int seconds) {
    final target = _currentTime + Duration(seconds: seconds);
    if (target < Duration.zero) {
      setState(() => _currentTime = Duration.zero);
    } else if (target > _totalDuration) {
      setState(() => _currentTime = _totalDuration);
    } else {
      setState(() => _currentTime = target);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _cycleSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.25;
      } else if (_playbackSpeed == 1.25) {
        _playbackSpeed = 1.5;
      } else {
        _playbackSpeed = 1.0;
      }
      if (_isPlaying) {
        _startPlaybackTimer();
      }
    });
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying && !_isControlsHovered) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _openFullscreenDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (ctx) {
        return Dialog.fullscreen(
          backgroundColor: const Color(0xFF060B18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildVideoContentArea(context, isFullscreen: true),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  tooltip: 'Thoát toàn màn hình (ESC)',
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRealVideo = widget.videoUrl.trim().isNotEmpty;
    final progress = _currentTime.inMilliseconds / _totalDuration.inMilliseconds.clamp(1, double.infinity);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070E1E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.isAbyss
              ? const Color(0x6638BDF8)
              : const Color(0xFFBAE6FD),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D2FF).withValues(alpha: widget.isAbyss ? 0.20 : 0.08),
            blurRadius: 36,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. macOS Header Bar with Status Pill
          _buildMacOsWindowBar(hasRealVideo),

          // 2. Video Player Content Area (16:9 Aspect Ratio on Desktop/Tablet)
          MouseRegion(
            onEnter: (_) {
              setState(() {
                _showControls = true;
                _isControlsHovered = true;
              });
            },
            onExit: (_) {
              setState(() {
                _isControlsHovered = false;
              });
              if (_isPlaying) {
                _scheduleHideControls();
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildVideoContentArea(context),

                // Top Vignette Overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x99000000), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Central Big Play/Pause Button when paused or hovering
                if (!_isPlaying)
                  _buildBigCenterPlayButton()
                else if (_showControls)
                  _buildCenterPauseOverlay(),

                // Bottom Floating Control Bar (Glassmorphic)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _showControls || !_isPlaying ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: _buildControlsBar(context, progress),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // macOS Top Bar
  // ===========================================================================
  Widget _buildMacOsWindowBar(bool hasRealVideo) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF050B17),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Row(
        children: [
          // Traffic light dots
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
          const SizedBox(width: 16),

          // URL Pill
          Expanded(
            child: Container(
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D172E),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_rounded, size: 13, color: Color(0xFF00D2FF)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'pondora.vn — Hướng Dẫn Sử Dụng Hệ Thống',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF94A3B8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (hasRealVideo ? const Color(0xFF10B981) : const Color(0xFF0284C7)).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (hasRealVideo ? const Color(0xFF10B981) : const Color(0xFF0284C7)).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: hasRealVideo ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  hasRealVideo ? 'SẴN SÀNG PHÁT' : 'HƯỚNG DẪN 4 BƯỚC',
                  style: GoogleFonts.jetBrainsMono(
                    color: hasRealVideo ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Video Content Area (Poster & Interactive Simulation Walkthrough)
  // ===========================================================================
  Widget _buildVideoContentArea(BuildContext context, {bool isFullscreen = false}) {
    final height = isFullscreen
        ? null
        : (widget.isDesktop ? 390.0 : 280.0);
    final activeStep = _steps[_currentStepIndex];

    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF060B18),
      ),
      child: Stack(
        children: [
          // Subtle Ocean Caustic Grid Backdrop
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    activeStep.accentColor.withValues(alpha: 0.16),
                    const Color(0xFF0B172E).withValues(alpha: 0.6),
                    const Color(0xFF050B16),
                  ],
                ),
              ),
            ),
          ),

          // High-Tech Grid Lines Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _TechGridPainter(
                accentColor: activeStep.accentColor.withValues(alpha: 0.25),
              ),
            ),
          ),

          // If NOT playing: Display the authentic Pondora Dashboard Mockup
          if (!_isPlaying)
            Positioned.fill(
              child: _buildDashboardMockup(context),
            )
          else
            // Central Visual Studio Artwork / Telemetry Showcase (When playing)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Step Navigation Pill Indicators
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: List.generate(_steps.length, (idx) {
                        final step = _steps[idx];
                        final isCurrent = idx == _currentStepIndex;
                        return InkWell(
                          onTap: () {
                            final targetSec = idx == 0
                                ? 0
                                : idx == 1
                                    ? 65
                                    : idx == 2
                                        ? 135
                                        : 200;
                            _seekTo(targetSec / _totalDuration.inSeconds);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? step.accentColor.withValues(alpha: 0.22)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCurrent
                                    ? step.accentColor.withValues(alpha: 0.6)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  step.icon,
                                  size: 11,
                                  color: isCurrent ? step.accentColor : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Giai đoạn ${idx + 1}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                    color: isCurrent ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),

                    // Active Step Title & Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeStep.accentColor.withValues(alpha: 0.15),
                            border: Border.all(color: activeStep.accentColor.withValues(alpha: 0.4)),
                          ),
                          child: Icon(activeStep.icon, color: activeStep.accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            activeStep.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: widget.isDesktop ? 18 : 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Active Step Subtitle
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Text(
                        activeStep.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: widget.isDesktop ? 13 : 11.5,
                          color: const Color(0xFF94A3B8),
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // High-Tech Telemetry Gauge Strip
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1426).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: activeStep.accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeStep.keyMetric.toUpperCase(),
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9.5,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activeStep.metricValue,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 14,
                                      color: activeStep.accentColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 28, color: const Color(0xFF1E293B)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TRẠNG THÁI VẬN HÀNH',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9.5,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activeStep.statusText,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFFCBD5E1),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Authentic Pondora Live Dashboard Mockup
  Widget _buildDashboardMockup(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.isDesktop ? 32 : 18,
        widget.isDesktop ? 24 : 14,
        widget.isDesktop ? 32 : 18,
        widget.isDesktop ? 22 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb & ESP32 Online Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'AO NUÔI SỐ 01 · TÔM THẺ CHÂN TRẮNG',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF38BDF8),
                    fontSize: widget.isDesktop ? 11.5 : 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      'Trạm ESP32: Online',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Main Title
          Text(
            'Bảng Giám Sát Cảm Biến Thời Gian Thực',
            style: GoogleFonts.plusJakartaSans(
              fontSize: widget.isDesktop ? 20 : 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: widget.isDesktop ? 16 : 10),

          // 4 Parameter Cards in Row
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildMockupParamCard(
                  title: 'pH Nước',
                  value: '7.85',
                  sub: 'Tối ưu 7.5–8.5',
                  valColor: const Color(0xFF10B981),
                ),
                SizedBox(width: widget.isDesktop ? 12 : 6),
                _buildMockupParamCard(
                  title: 'Oxy (DO)',
                  value: '6.2 mg/L',
                  sub: 'Hô hấp tốt',
                  valColor: const Color(0xFF38BDF8),
                ),
                SizedBox(width: widget.isDesktop ? 12 : 6),
                _buildMockupParamCard(
                  title: 'Khí Độc NH₃',
                  value: '3.8 %',
                  sub: 'Soft-Sensor APHA',
                  valColor: const Color(0xFF38BDF8),
                ),
                SizedBox(width: widget.isDesktop ? 12 : 6),
                _buildMockupParamCard(
                  title: 'Nhiệt Độ',
                  value: '28.5 °C',
                  sub: 'Chuẩn sinh học',
                  valColor: const Color(0xFFFB923C),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.isDesktop ? 12 : 8),

          // 24H Trend Chart Container
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1428).withValues(alpha: 0.50),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.show_chart_rounded, size: 14, color: Color(0xFF00D2FF)),
                      const SizedBox(width: 6),
                      Text(
                        'Biểu Đồ Xu Hướng 24 Giờ (Chỉ Số Oxy & pH)',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF64748B),
                          fontSize: widget.isDesktop ? 10.5 : 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    height: widget.isDesktop ? 48 : 34,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _MockupWavePainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupParamCard({
    required String title,
    required String value,
    required String sub,
    required Color valColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isDesktop ? 14 : 8,
          vertical: widget.isDesktop ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1428).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF94A3B8),
                fontSize: widget.isDesktop ? 11 : 9.5,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  color: valColor,
                  fontSize: widget.isDesktop ? 18 : 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontSize: widget.isDesktop ? 10 : 8.5,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Central Play/Pause Overlay Buttons
  // ===========================================================================
  Widget _buildBigCenterPlayButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isPlayHovered = true),
      onExit: (_) => setState(() => _isPlayHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _togglePlay(true),
        child: AnimatedScale(
          scale: _isPlayHovered ? 1.10 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D2FF).withValues(alpha: 0.70),
                      blurRadius: 44,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF0F62FE),
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF070E1E).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D2FF).withValues(alpha: 0.3),
                      blurRadius: 18,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Bấm Để Xem Trực Tiếp Ao Nuôi',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPauseOverlay() {
    return GestureDetector(
      onTap: () => _togglePlay(false),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Icon(
            Icons.pause_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Bottom Glassmorphic Controls Bar
  // ===========================================================================
  Widget _buildControlsBar(BuildContext context, double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xEB070F22),
        border: const Border(
          top: BorderSide(color: Color(0x3338BDF8), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Interactive Scrubbing Timeline
          Row(
            children: [
              Text(
                _formatDuration(_currentTime),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: const Color(0xFF38BDF8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: const Color(0xFF00D2FF),
                    inactiveTrackColor: const Color(0xFF1E293B),
                    thumbColor: Colors.white,
                    overlayColor: const Color(0xFF00D2FF).withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (val) {
                      _seekTo(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_totalDuration),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // 2. Control Buttons Bar
          Row(
            children: [
              // Play/Pause Button
              IconButton(
                onPressed: () => _togglePlay(),
                icon: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: _isPlaying ? 'Tạm dừng (Space)' : 'Phát tiếp (Space)',
              ),

              // Replay 10s
              IconButton(
                onPressed: () => _skipSeconds(-10),
                icon: const Icon(Icons.replay_10_rounded, color: Color(0xFF94A3B8), size: 19),
                tooltip: 'Lùi lại 10 giây',
              ),

              // Forward 10s
              IconButton(
                onPressed: () => _skipSeconds(10),
                icon: const Icon(Icons.forward_10_rounded, color: Color(0xFF94A3B8), size: 19),
                tooltip: 'Tua tới 10 giây',
              ),

              const SizedBox(width: 6),

              // Volume & Mute Toggle
              IconButton(
                onPressed: _toggleMute,
                icon: Icon(
                  _isMuted || _volume == 0
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: _isMuted ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                  size: 20,
                ),
                tooltip: _isMuted ? 'Bật âm thanh' : 'Tắt tiếng',
              ),

              if (widget.isDesktop) ...[
                SizedBox(
                  width: 75,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.5),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                      activeTrackColor: const Color(0xFF38BDF8),
                      inactiveTrackColor: const Color(0xFF1E293B),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _isMuted ? 0.0 : _volume,
                      onChanged: (v) {
                        setState(() {
                          _volume = v;
                          _isMuted = false;
                        });
                      },
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Playback Speed Toggle
              InkWell(
                onTap: _cycleSpeed,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Fullscreen Button
              IconButton(
                onPressed: () => _openFullscreenDialog(context),
                icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22),
                tooltip: 'Toàn màn hình',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for futuristic studio grid backdrop
class _TechGridPainter extends CustomPainter {
  final Color accentColor;

  _TechGridPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 48.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_TechGridPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}

/// Custom painter for the 24H telemetry spline wave in the dashboard mockup
class _MockupWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.85);

    final cp1 = Offset(size.width * 0.25, size.height * 0.82);
    final p1 = Offset(size.width * 0.45, size.height * 0.60);
    path.quadraticBezierTo(cp1.dx, cp1.dy, p1.dx, p1.dy);

    final cp2 = Offset(size.width * 0.65, size.height * 0.38);
    final p2 = Offset(size.width * 0.85, size.height * 0.44);
    path.quadraticBezierTo(cp2.dx, cp2.dy, p2.dx, p2.dy);

    final cp3 = Offset(size.width * 0.95, size.height * 0.40);
    final p3 = Offset(size.width, size.height * 0.35);
    path.quadraticBezierTo(cp3.dx, cp3.dy, p3.dx, p3.dy);

    // Glowing cyan under-trace
    final glowPaint = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF00D2FF), Color(0xFF38BDF8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
