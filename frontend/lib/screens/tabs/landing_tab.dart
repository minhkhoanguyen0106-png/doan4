import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/water_models.dart';
import '../../widgets/underwater_ambient_canvas.dart';
import '../../widgets/tutorial_video_player.dart';

/// ============================================================================
/// CẤU HÌNH ĐƯỜNG DẪN VIDEO HƯỚNG DẪN HỆ THỐNG PONDORA (SYSTEM TUTORIAL VIDEO)
/// ============================================================================
/// Dán URL video hướng dẫn vào hằng số kTutorialVideoUrl bên dưới.
/// Hỗ trợ: đường dẫn file .mp4, .webm, CDN, stream hoặc video trực tiếp.
/// Nếu để trống (""), hệ thống sẽ hiển thị ảnh Poster nghệ thuật cùng chế độ
/// mô phỏng 4 giai đoạn hệ thống chuẩn mực, tuyệt đối không phát video mẫu sai lệch.
const String kTutorialVideoUrl = kDefaultTutorialVideoUrl; // <-- DÁN LINK VIDEO TẠI ĐÂY
const String kTutorialVideoPoster = kDefaultTutorialVideoPoster;

class LandingTab extends StatefulWidget {
  const LandingTab({
    super.key,
    required this.onNavigateToOverview,
    required this.onNavigateToDiary,
    required this.onNavigateToSites,
    required this.onViewActionPlan,
    required this.onSimulate,
    this.latest,
    this.lightingMode = OceanLightingMode.abyssal,
    this.onToggleLighting,
    this.onOpenMenu,
    this.videoUrl = kTutorialVideoUrl,
    this.videoPoster = kTutorialVideoPoster,
  });

  final VoidCallback onNavigateToOverview;
  final VoidCallback onNavigateToDiary;
  final VoidCallback onNavigateToSites;
  final VoidCallback onViewActionPlan;
  final VoidCallback onSimulate;
  final WaterMeasurement? latest;
  final OceanLightingMode lightingMode;
  final VoidCallback? onToggleLighting;
  final VoidCallback? onOpenMenu;
  final String videoUrl;
  final String videoPoster;

  @override
  State<LandingTab> createState() => _LandingTabState();
}

class _LandingTabState extends State<LandingTab> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  AnimationController? _ribbonController;
  AnimationController get ribbonAnim {
    _ribbonController ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    return _ribbonController!;
  }
  final GlobalKey<TutorialVideoPlayerState> _videoPlayerKey = GlobalKey<TutorialVideoPlayerState>();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (mounted) {
      final offset = _scrollController.offset;
      setState(() {
        _scrollOffset = offset;
      });
      // Tự động tạm dừng phát video khi người dùng cuộn rời xa khu vực video (tránh phát ngầm)
      if (offset < 40 || offset > 1650) {
        _videoPlayerKey.currentState?.pauseVideo();
      }
    }
  }

  @override
  void dispose() {
    _ribbonController?.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 980;
    final isTablet = width >= 680 && width < 980;
    final isAbyss = widget.lightingMode == OceanLightingMode.abyssal;

    return UnderwaterAmbientBackground(
      scrollOffset: _scrollOffset,
      lightingMode: widget.lightingMode,
      onToggleLighting: widget.onToggleLighting,
      child: Stack(
        children: [
          // Ambient Oceanic Glows
          Positioned(
            top: -120,
            left: width * 0.15,
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D2FF).withValues(alpha: isAbyss ? 0.14 : 0.06),
                    const Color(0xFF0284C7).withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 400,
            right: -100,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withValues(alpha: isAbyss ? 0.12 : 0.04),
                    const Color(0xFF38BDF8).withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Body
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            interactive: true,
            thickness: 7,
            radius: const Radius.circular(8),
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : (isTablet ? 32 : 18),
                vertical: 14,
              ),
              children: [
                // 1. Floating Pill Navbar
                _buildFloatingNav(context, isDesktop, isAbyss),

                SizedBox(height: isDesktop ? 20 : 14),

                // 2. Editorial Hero Headline & Action Group
                _buildHeroHeader(context, isDesktop, isAbyss),

                SizedBox(height: isDesktop ? 14 : 10),

                // 3. 3D Perspective Flip Video Showcase (Khám phá cách sử dụng hệ thống)
                _build3DVideoShowcase(context, isDesktop, isAbyss),

                SizedBox(height: isDesktop ? 64 : 44),

                // 4. Live Precision Telemetry Strip (Instrument bar)
                _buildPrecisionTelemetryStrip(context, isDesktop, isAbyss),

                SizedBox(height: isDesktop ? 80 : 56),

                // 5. Asymmetric Editorial Problem Section ("Biến động vô hình")
                _buildEditorialProblemSection(context, isDesktop, isAbyss),

                SizedBox(height: isDesktop ? 84 : 60),

                // 6. Bento-Grid Architecture ("4 Trụ Cột Nền Tảng")
                _buildBentoTechnologySection(context, isDesktop, isAbyss),

                SizedBox(height: isDesktop ? 84 : 60),

                // 7. Minimalist Operational Metrics (Reliability)
                _buildEditorialMetricsSection(context, isDesktop, isAbyss),

                SizedBox(height: isDesktop ? 80 : 56),

                // 8. 3-Step Turnkey Deployment
                _buildEditorialWorkflowSection(context, isDesktop, isAbyss),

                SizedBox(height: isDesktop ? 80 : 56),

                // 9. Premium Editorial Call To Action Banner
                _buildEditorialCtaBanner(context, isDesktop, isAbyss),

                const SizedBox(height: 72),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. FLOATING PILL NAVBAR
  // ===========================================================================
  Widget _buildFloatingNav(BuildContext context, bool isDesktop, bool isAbyss) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1080),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isAbyss
              ? const Color(0xCC061226)
              : Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isAbyss ? const Color(0x3338BDF8) : const Color(0xFFBAE6FD),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isAbyss ? Colors.black : const Color(0xFF0F172A)).withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Drawer menu toggle (available on full-screen landing view)
            if (widget.onOpenMenu != null) ...[
              IconButton(
                onPressed: widget.onOpenMenu,
                tooltip: 'Menu hệ thống & Quản trị',
                icon: Icon(
                  Icons.menu_rounded,
                  color: isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0F62FE),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isAbyss ? const Color(0x2238BDF8) : const Color(0xFFE0F2FE),
                  padding: const EdgeInsets.all(7),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Brand Mark & Monogram
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2FF), Color(0xFF0F62FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'PONDORA',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
                color: isAbyss ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: 1.6,
              ),
            ),
            const Spacer(),

            if (isDesktop) ...[
              _navLinkItem('XEM NƯỚC AO', widget.onNavigateToOverview, isAbyss),
              _navLinkItem('GỢI Ý XỬ LÝ', widget.onViewActionPlan, isAbyss),
              _navLinkItem('THỬ SỐ LIỆU', widget.onSimulate, isAbyss),
              _navLinkItem('SỔ NHẬT KÝ', widget.onNavigateToDiary, isAbyss),
              const SizedBox(width: 12),
            ],

            // Ocean Lighting Mode Toggle Button
            if (widget.onToggleLighting != null) ...[
              IconButton(
                onPressed: widget.onToggleLighting,
                tooltip: isAbyss
                    ? 'Chế độ hiện tại: Đại dương huyền ảo (Bấm để chuyển sang Nắng mai)'
                    : 'Chế độ hiện tại: Nước trong nắng mai (Bấm để chuyển sang Đại dương)',
                icon: Icon(
                  isAbyss ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                  color: isAbyss ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
                  size: 19,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isAbyss ? const Color(0xFF0B1E3B) : const Color(0xFFFEF3C7),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Primary Enter Dashboard Button
            FilledButton.icon(
              onPressed: widget.onNavigateToOverview,
              icon: const Icon(Icons.speed_rounded, size: 15),
              label: Text(
                'VÀO XEM AO',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLinkItem(String label, VoidCallback onTap, bool isAbyss) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: (isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)).withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: isAbyss ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 13.0,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. EDITORIAL HERO BANNER
  // ===========================================================================
  Widget _buildHeroHeader(BuildContext context, bool isDesktop, bool isAbyss) {
    return Column(
      children: [
        // Category Eyebrow Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isAbyss
                ? const Color(0xFF00D2FF).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAbyss
                  ? const Color(0xFF00D2FF).withValues(alpha: 0.35)
                  : const Color(0xFF0284C7).withValues(alpha: 0.35),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isAbyss ? Colors.black : const Color(0xFF0284C7)).withValues(alpha: isAbyss ? 0.20 : 0.10),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7)).withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'THEO DÕI NƯỚC AO TÔM TỰ ĐỘNG',
                style: GoogleFonts.jetBrainsMono(
                  color: isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Expressive Main Headline with Controlled Hierarchy
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: isDesktop ? 33 : 23,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                height: 1.22,
                color: isAbyss ? Colors.white : const Color(0xFF061A3A),
                shadows: isAbyss
                    ? const [
                        Shadow(color: Color(0x3D000000), blurRadius: 10, offset: Offset(0, 2)),
                      ]
                    : [
                        Shadow(color: Colors.white.withValues(alpha: 0.9), blurRadius: 16, offset: const Offset(0, 1)),
                      ],
              ),
              children: [
                const TextSpan(text: 'Theo dõi chất lượng nước &\n'),
                TextSpan(
                  text: 'chăm sóc ao tôm dễ dàng',
                  style: TextStyle(
                    color: isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    shadows: isAbyss
                        ? const [
                            Shadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 2)),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Editorial Narrative Lead
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            'Hệ thống tự động đo pH, oxy, nhiệt độ và tính khí độc liên tục ngày đêm. Cảnh báo ngay khi nước có dấu hiệu bất thường và gợi ý cách xử lý kịp thời.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isDesktop ? 13.5 : 12,
              fontWeight: isAbyss ? FontWeight.w600 : FontWeight.w700,
              color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
              height: 1.5,
              shadows: isAbyss
                  ? const [
                      Shadow(color: Color(0x28000000), blurRadius: 6, offset: Offset(0, 1)),
                    ]
                  : [
                      Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 10, offset: const Offset(0, 1)),
                    ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Action Buttons with Distinct Typographic & Visual Weights
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: widget.onNavigateToOverview,
              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
              label: Text(
                'XEM NƯỚC AO',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.onViewActionPlan,
              icon: const Icon(Icons.psychology_rounded, size: 16),
              label: Text(
                'GỢI Ý XỬ LÝ NƯỚC',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isAbyss ? Colors.white : const Color(0xFF0284C7),
                backgroundColor: isAbyss ? const Color(0x28FFFFFF) : Colors.white.withValues(alpha: 0.95),
                side: BorderSide(
                  color: isAbyss ? const Color(0x6638BDF8) : const Color(0xFFBAE6FD),
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isAbyss ? 0 : 2,
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.onSimulate,
              icon: const Icon(Icons.science_outlined, size: 16),
              label: Text(
                'THỬ NGHIỆM SỐ LIỆU',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isAbyss ? Colors.white : const Color(0xFF4338CA),
                backgroundColor: isAbyss ? const Color(0x28FFFFFF) : Colors.white.withValues(alpha: 0.95),
                side: BorderSide(
                  color: isAbyss ? const Color(0x666366F1) : const Color(0xFFC7D2FE),
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isAbyss ? 0 : 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. 3D FLIP VIDEO SHOWCASE — LẬT MÀN HÌNH 3D PHÁT VIDEO HƯỚNG DẪN HỆ THỐNG
  // ===========================================================================
  Widget _build3DVideoShowcase(BuildContext context, bool isDesktop, bool isAbyss) {
    // Scroll progress: Activates as the user scrolls towards the middle of this showcase section
    // Starts engaging smoothly right from the start, settling upright cleanly.
    final double rawProgress = (_scrollOffset / 320.0).clamp(0.0, 1.0);

    // Dynamic Ease-Out curve with a gentle natural spring bounce cushion
    final double t = rawProgress;
    final double easeOut = 1.0 - math.pow(1.0 - t, 3.2);
    final double spring = math.sin(t * math.pi) * 0.025 * (1.0 - t);
    final double progress = (easeOut + spring).clamp(0.0, 1.0);

    // Pronounced 3D Backward Lean (-0.40 rad ≈ -23°) rising smoothly to 0.0 rad (flat upright facing user)
    final double tiltAngle = -(1.0 - progress) * 0.40;
    final double scaleFactor = 0.92 + (0.08 * progress);
    final double translateY = -(1.0 - progress) * 16.0;

    return Column(
      children: [
        // Section Category Eyebrow Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isAbyss ? const Color(0x2600D2FF) : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAbyss ? const Color(0x5900D2FF) : const Color(0xFFBAE6FD),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isAbyss ? 0.20 : 0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7)).withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'HƯỚNG DẪN DỄ HIỂU',
                style: GoogleFonts.jetBrainsMono(
                  color: isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Prominent Required Headline: "Khám phá cách sử dụng hệ thống"
        Text(
          'Khám phá cách sử dụng hệ thống',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isDesktop ? 22 : 18,
            fontWeight: FontWeight.w900,
            color: isAbyss ? Colors.white : const Color(0xFF061A3A),
            letterSpacing: -0.5,
            shadows: isAbyss
                ? const [
                    Shadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
                  ]
                : [
                    Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 10, offset: const Offset(0, 1)),
                  ],
          ),
        ),
        const SizedBox(height: 4),

        // Required Subtitle: "Tìm hiểu các chức năng và cách thao tác thông qua video hướng dẫn trực quan"
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            'Tìm hiểu các chức năng và cách thao tác thông qua video hướng dẫn trực quan',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isDesktop ? 12 : 11,
              fontWeight: isAbyss ? FontWeight.w600 : FontWeight.w700,
              color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
              shadows: isAbyss
                  ? const [
                      Shadow(color: Color(0x28000000), blurRadius: 6, offset: Offset(0, 1)),
                    ]
                  : [
                      Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 1)),
                    ],
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 10 : 8),

        // 3D Perspective Flip Transform with Physical Bezel & Thickness
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 980 : 720),
            // Outer 3D ambient shadow & water floor caustics
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                // Deep physical contact shadow that responds to tilt angle
                BoxShadow(
                  color: Colors.black.withValues(alpha: isAbyss ? 0.70 : 0.35),
                  blurRadius: 40 + (24 * (1.0 - progress)),
                  offset: Offset(0, 26 + (18 * (1.0 - progress))),
                  spreadRadius: 2,
                ),
                // Bioluminescent ocean floor underglow
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(
                    alpha: isAbyss ? (0.16 + 0.12 * progress) : 0.08,
                  ),
                  blurRadius: 55,
                  offset: const Offset(0, 16),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Transform(
              alignment: const Alignment(0.0, 0.90), // Bottom pivot point for natural easel flip
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0014) // Deep 3D perspective foreshortening
                ..rotateX(tiltAngle)
                ..multiply(Matrix4.diagonal3Values(scaleFactor, scaleFactor, 1.0))
                ..multiply(Matrix4.translationValues(0.0, translateY, 0.0)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Simulated 3D Bezel Chassis Edge (Physical depth & thickness)
                  Positioned(
                    left: 4,
                    right: 4,
                    bottom: -8 * (1.0 - progress),
                    height: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isAbyss ? const Color(0xFF050E1E) : const Color(0xFFCBD5E1),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main High-Tech Display Frame
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isAbyss
                            ? const Color(0xFF38BDF8).withValues(alpha: 0.45 + (0.35 * progress))
                            : const Color(0xFFBAE6FD),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: TutorialVideoPlayer(
                      key: _videoPlayerKey,
                      videoUrl: widget.videoUrl,
                      videoPoster: widget.videoPoster,
                      isDesktop: isDesktop,
                      isAbyss: isAbyss,
                      isFlippedOpen: progress >= 0.70,
                      onNavigateToOverview: widget.onNavigateToOverview,
                    ),
                  ),

                  // Top Specular Horizon Light (Crisp glass rim reflection)
                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    height: 1.2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF00D2FF).withValues(alpha: 0.85),
                            Colors.white.withValues(alpha: 0.95),
                            const Color(0xFF00D2FF).withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. PRECISION TELEMETRY STRIP (HIGH-TECH INSTRUMENT BAR)
  // ===========================================================================
  Widget _buildPrecisionTelemetryStrip(BuildContext context, bool isDesktop, bool isAbyss) {
    final ph = widget.latest?.readings['ph']?.toDouble() ?? 7.85;
    final doVal = widget.latest?.readings['dissolvedOxygenMgL']?.toDouble() ?? 6.2;
    final temp = widget.latest?.readings['temperatureC']?.toDouble() ?? 28.5;
    final nh3Pct = widget.latest?.nh3Percentage ?? 3.8;

    final phOk = ph >= 7.5 && ph <= 8.5;
    final doOk = doVal >= 4.5;
    final nh3Ok = nh3Pct <= 4.5;
    final tempOk = temp >= 25.0 && temp <= 32.0;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1040),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isAbyss ? const Color(0xCC07152B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAbyss ? const Color(0x3338BDF8) : const Color(0xFFBAE6FD),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isAbyss ? Colors.black : const Color(0xFF0F172A)).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 720;
            if (isNarrow) {
              return Wrap(
                spacing: 16,
                runSpacing: 14,
                alignment: WrapAlignment.spaceAround,
                children: [
                  _telemetryInstrument('ĐỘ pH NƯỚC', ph.toStringAsFixed(2), phOk ? 'Nước tốt (7.5–8.5)' : 'Cần kiểm tra lại', phOk ? const Color(0xFF10B981) : const Color(0xFFF59E0B), isAbyss),
                  _telemetryInstrument('OXY HÒA TAN', '$doVal mg/L', doOk ? 'Tôm thở khỏe' : 'Thiếu oxy - Bật quạt', doOk ? const Color(0xFF00D2FF) : const Color(0xFFEF4444), isAbyss),
                  _telemetryInstrument('KHÍ ĐỘC NH₃', '${nh3Pct.toStringAsFixed(1)} %', nh3Ok ? 'Nước an toàn' : 'Khí độc cao - Nguy hiểm', nh3Ok ? const Color(0xFF10B981) : const Color(0xFFEF4444), isAbyss),
                  _telemetryInstrument('NHIỆT ĐỘ NƯỚC', '$temp °C', tempOk ? 'Nhiệt độ ấm tốt' : 'Nước bị lạnh/nóng', tempOk ? const Color(0xFF10B981) : const Color(0xFF38BDF8), isAbyss),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _telemetryInstrument('ĐỘ pH NƯỚC', ph.toStringAsFixed(2), phOk ? 'Nước tốt (7.5–8.5)' : 'Cần kiểm tra lại', phOk ? const Color(0xFF10B981) : const Color(0xFFF59E0B), isAbyss)),
                _verticalSeparator(isAbyss),
                Expanded(child: _telemetryInstrument('OXY HÒA TAN', '$doVal mg/L', doOk ? 'Tôm thở khỏe' : 'Thiếu oxy - Bật quạt', doOk ? const Color(0xFF00D2FF) : const Color(0xFFEF4444), isAbyss)),
                _verticalSeparator(isAbyss),
                Expanded(child: _telemetryInstrument('KHÍ ĐỘC NH₃', '${nh3Pct.toStringAsFixed(1)} %', nh3Ok ? 'Nước an toàn' : 'Khí độc cao - Nguy hiểm', nh3Ok ? const Color(0xFF10B981) : const Color(0xFFEF4444), isAbyss)),
                _verticalSeparator(isAbyss),
                Expanded(child: _telemetryInstrument('NHIỆT ĐỘ NƯỚC', '$temp °C', tempOk ? 'Nhiệt độ ấm tốt' : 'Nước bị lạnh/nóng', tempOk ? const Color(0xFF10B981) : const Color(0xFF38BDF8), isAbyss)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _verticalSeparator(bool isAbyss) => Container(
    height: 38,
    width: 1,
    color: isAbyss ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );

  Widget _telemetryInstrument(String label, String value, String status, Color statusColor, bool isAbyss) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isAbyss ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isAbyss ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(width: 5, height: 5, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                status,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. ASYMMETRIC EDITORIAL PROBLEM SECTION (SPLIT LAYOUT)
  // ===========================================================================
  Widget _buildEditorialProblemSection(BuildContext context, bool isDesktop, bool isAbyss) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Editorial Lead Column
                  Expanded(
                    flex: 4,
                    child: _buildProblemEditorialLead(isAbyss),
                  ),
                  const SizedBox(width: 48),
                  // Right Narrative Danger Zones Column
                  Expanded(
                    flex: 6,
                    child: _buildProblemDangerList(isAbyss),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProblemEditorialLead(isAbyss),
                  const SizedBox(height: 32),
                  _buildProblemDangerList(isAbyss),
                ],
              ),
      ),
    );
  }

  Widget _buildProblemEditorialLead(bool isAbyss) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge
        Text(
          'RỦI RO THƯỜNG GẶP',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFEF4444),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nước ao đổi màu, trở trời -\nnguy hiểm không kịp trở tay.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.25,
            color: isAbyss ? Colors.white : const Color(0xFF061A3A),
            shadows: isAbyss
                ? null
                : [
                    Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 10, offset: const Offset(0, 1)),
                  ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Chỉ một cơn mưa rào hay nửa đêm cạn oxy, môi trường nước có thể thay đổi rất nhanh làm tôm yếu hoặc chết nếu không phát hiện sớm.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: isAbyss ? FontWeight.w500 : FontWeight.w600,
            color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
            height: 1.6,
            shadows: isAbyss
                ? const [
                    Shadow(color: Color(0x28000000), blurRadius: 6, offset: Offset(0, 1)),
                  ]
                : [
                    Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 1)),
                  ],
          ),
        ),
        const SizedBox(height: 24),

        // Editorial Stat Callout
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isAbyss ? const Color(0xFF131D33) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAbyss ? const Color(0x33EF4444) : const Color(0xFFFECACA),
            ),
          ),
          child: Row(
            children: [
              Text(
                '40%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFEF4444),
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'thiệt hại vụ tôm thường do phát hiện muộn khi nước bị tụt pH sau mưa hoặc thiếu oxy rạng sáng.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProblemDangerList(bool isAbyss) {
    final risks = [
      {
        'phase': 'KHI TRỜI MƯA RÀO',
        'title': 'Nước mưa xả phèn làm tụt pH',
        'desc': 'Mưa cuốn phèn bờ ao làm nước chua nhanh, tôm dễ bị mềm vỏ, lột dính và yếu sức.',
        'accent': const Color(0xFFF59E0B),
      },
      {
        'phase': 'NỬA ĐÊM & RẠNG SÁNG',
        'title': 'Thiếu oxy lúc 3h - 5h sáng',
        'desc': 'Tảo và bùn đáy cạn oxy làm tôm nổi đầu tấp mé nếu không kịp thời bật quạt nước.',
        'accent': const Color(0xFFEF4444),
      },
      {
        'phase': 'TRƯA NẮNG GẮT',
        'title': 'Tảo phát triển mạnh, sinh khí độc',
        'desc': 'Nắng gắt làm pH tăng vọt sinh khí độc NH₃ gây bỏng mang tôm và khó thở.',
        'accent': const Color(0xFFEC4899),
      },
    ];

    return Column(
      children: risks.map((r) {
        final color = r['accent'] as Color;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isAbyss ? const Color(0xCC07152B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: isAbyss ? 0.30 : 0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['phase'] as String,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        r['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isAbyss ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        r['desc'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: isAbyss ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // 6. S-CURVE RIBBON JOURNEY — DÒNG NƯỚC CHẢY UỐN LƯỢN & ĐÀN CÁ BƠI XEN KẼ
  // ===========================================================================
  Widget _buildBentoTechnologySection(BuildContext context, bool isDesktop, bool isAbyss) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1140),
        child: Column(
          children: [
            // Section Header
            _editorialSectionHeader(
              badge: 'TÍNH NĂNG CHÍNH',
              title: 'Bốn trợ thủ đắc lực cho người nuôi tôm',
              subtitle: 'Giúp người nuôi yên tâm quản lý ao tôm, giảm chi phí và phòng ngừa rủi ro từ sớm.',
              isAbyss: isAbyss,
            ),
            const SizedBox(height: 52),

            // S-Curve Animated Water Current & Swimming Fish Flow
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                if (isDesktop && width >= 860) {
                  return _buildDesktopSCurveJourney(width, isAbyss);
                } else {
                  return _buildMobileSCurveJourney(width, isAbyss);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSCurveJourney(double width, bool isAbyss) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background animated S-curve water stream with swimming fish
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: ribbonAnim,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WaterStreamFishPainter(
                    progress: ribbonAnim.value,
                    isAbyss: isAbyss,
                    isDesktop: true,
                  ),
                );
              },
            ),
          ),
        ),

        // Foreground 4 Journey Milestone Rows (Defines the true natural height of the Stack)
        Column(
          children: [
            // Row 01: Tính tự động (Bên trái)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildBentoSoftSensorCard(isAbyss)),
                const SizedBox(width: 24),
                _buildMilestoneNode('01', isAbyss),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 56),

            // Row 02: Máy đo tự động (Bên phải)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: SizedBox()),
                const SizedBox(width: 24),
                _buildMilestoneNode('02', isAbyss),
                const SizedBox(width: 24),
                Expanded(child: _buildBentoEsp32Card(isAbyss)),
              ],
            ),
            const SizedBox(height: 56),

            // Row 03: Gợi ý kỹ thuật (Bên trái)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildBentoAiPrescriptionCard(isAbyss)),
                const SizedBox(width: 24),
                _buildMilestoneNode('03', isAbyss),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 56),

            // Row 04: Sổ ghi chép dễ dùng (Bên phải)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: SizedBox()),
                const SizedBox(width: 24),
                _buildMilestoneNode('04', isAbyss),
                const SizedBox(width: 24),
                Expanded(child: _buildBentoDiaryCard(isAbyss)),
              ],
            ),
            const SizedBox(height: 36),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileSCurveJourney(double width, bool isAbyss) {
    const double vSpacing = 28.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: ribbonAnim,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WaterStreamFishPainter(
                    progress: ribbonAnim.value,
                    isAbyss: isAbyss,
                    isDesktop: false,
                  ),
                );
              },
            ),
          ),
        ),
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMilestoneNode('01', isAbyss),
                const SizedBox(width: 14),
                Expanded(child: _buildBentoSoftSensorCard(isAbyss)),
              ],
            ),
            const SizedBox(height: vSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMilestoneNode('02', isAbyss),
                const SizedBox(width: 14),
                Expanded(child: _buildBentoEsp32Card(isAbyss)),
              ],
            ),
            const SizedBox(height: vSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMilestoneNode('03', isAbyss),
                const SizedBox(width: 14),
                Expanded(child: _buildBentoAiPrescriptionCard(isAbyss)),
              ],
            ),
            const SizedBox(height: vSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMilestoneNode('04', isAbyss),
                const SizedBox(width: 14),
                Expanded(child: _buildBentoDiaryCard(isAbyss)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestoneNode(String stepNum, bool isAbyss) {
    final goldColor = isAbyss ? const Color(0xFFDFB76C) : const Color(0xFFD97706);
    final emeraldColor = isAbyss ? const Color(0xFF00E5A3) : const Color(0xFF10B981);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isAbyss ? const Color(0xFF07142A) : Colors.white,
        border: Border.all(
          color: goldColor,
          width: 2.4,
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: isAbyss ? 0.45 : 0.30),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: emeraldColor.withValues(alpha: isAbyss ? 0.30 : 0.20),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stepNum,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: goldColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 5.5,
            height: 5.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: emeraldColor,
              boxShadow: [
                BoxShadow(
                  color: emeraldColor,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoSoftSensorCard(bool isAbyss) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: isAbyss ? const Color(0xEE091932) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAbyss ? const Color(0x4438BDF8) : const Color(0xFFBAE6FD),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7))
                .withValues(alpha: isAbyss ? 0.12 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'TÍNH TỰ ĐỘNG',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00D2FF),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.bolt_rounded, color: Color(0xFF00D2FF), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tự tính khí độc NH₃ – Không cần mua đầu đo đắt tiền',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isAbyss ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Máy đo khí độc thường có giá rất cao và nhanh hỏng màng đo. PONDORA tự động tính nồng độ khí độc chính xác từ độ pH và nhiệt độ nước theo công thức Emerson, giúp bà con tiết kiệm chi phí.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isAbyss ? const Color(0x2238BDF8) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  'Công thức chuẩn hóa học Emerson',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF38BDF8),
                  ),
                ),
                const Spacer(),
                Text(
                  'Chi phí đầu dò: 0đ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoEsp32Card(bool isAbyss) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: isAbyss ? const Color(0xEE091932) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAbyss ? const Color(0x4438BDF8) : const Color(0xFFBAE6FD),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7))
                .withValues(alpha: isAbyss ? 0.12 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'MÁY ĐO TỰ ĐỘNG',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF38BDF8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.sensors_rounded, color: Color(0xFF38BDF8), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Máy đo cắm tại ao – Tự gửi số liệu 24/24',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isAbyss ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đo đạc tự động 3 giây một lần, lọc nhiễu chính xác và tự gửi số liệu về điện thoại qua Wi-Fi mà không cần lội ao múc nước đo tay. Thiết bị chuẩn chống nước IP67 bền bỉ ngoài trời.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _techFeaturePill('Báo động ngay khi mất điện hoặc mất mạng', isAbyss),
        ],
      ),
    );
  }

  Widget _buildBentoAiPrescriptionCard(bool isAbyss) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: isAbyss ? const Color(0xEE091932) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAbyss ? const Color(0x4410B981) : const Color(0xFFBAE6FD),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: isAbyss ? 0.12 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GỢI Ý KỸ THUẬT',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.psychology_rounded, color: Color(0xFF10B981), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Gợi ý lượng vôi, oxy viên và vi sinh cần đánh',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isAbyss ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Khi nước có dấu hiệu xấu hoặc biến động lạ, hệ thống phân tích và tính sẵn lượng vôi nông nghiệp, men vi sinh EM hoặc oxy viên cần đánh cho đúng diện tích và thể tích ao của bạn.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _techFeaturePill('Tính sẵn số ký thuốc theo thể tích khối nước ao', isAbyss),
        ],
      ),
    );
  }

  Widget _buildBentoDiaryCard(bool isAbyss) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: isAbyss ? const Color(0xEE091932) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAbyss ? const Color(0x44F59E0B) : const Color(0xFFBAE6FD),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: isAbyss ? 0.12 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SỔ GHI CHÉP DỄ DÙNG',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF59E0B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.menu_book_rounded, color: Color(0xFFF59E0B), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sổ nhật ký ao nuôi trên điện thoại',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isAbyss ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ghi lại số lượng thức ăn mỗi bữa, tiền thuốc và quá trình tôm lớn. Thay thế sổ tay giấy, dễ tra cứu bất kỳ lúc nào và tự động tính hệ số FCR để tối ưu chi phí vụ nuôi.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _techFeaturePill('Quản lý tiền thức ăn và chi phí rõ ràng', isAbyss),
        ],
      ),
    );
  }

  Widget _techFeaturePill(String text, bool isAbyss) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isAbyss ? const Color(0x2238BDF8) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
          const SizedBox(width: 7),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

// 7. MINIMALIST OPERATIONAL RELIABILITY METRICS
  // ===========================================================================
  Widget _buildEditorialMetricsSection(BuildContext context, bool isDesktop, bool isAbyss) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1040),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: isAbyss ? const Color(0x28FFFFFF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isAbyss ? const Color(0x3838BDF8) : const Color(0xFFE2E8F0),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 650;
            if (isNarrow) {
              return Column(
                children: [
                  _editorialMetricNode('99.8%', 'Thời gian máy đo hoạt động', 'Đo đạc bền bỉ cả ngày lẫn đêm', isAbyss),
                  Divider(color: isAbyss ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 32),
                  _editorialMetricNode('< 1 Giây', 'Báo động tức thì', 'Phát hiện ngay khi nước có dấu hiệu lạ', isAbyss),
                  Divider(color: isAbyss ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 32),
                  _editorialMetricNode('85%+', 'Tôm sống khỏe mạnh', 'Giảm tối đa thiệt hại do sốc nước', isAbyss),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _editorialMetricNode('99.8%', 'Thời gian máy đo hoạt động', 'Đo đạc bền bỉ cả ngày lẫn đêm', isAbyss)),
                _verticalSeparator(isAbyss),
                Expanded(child: _editorialMetricNode('< 1 Giây', 'Báo động tức thì', 'Phát hiện ngay khi nước có dấu hiệu lạ', isAbyss)),
                _verticalSeparator(isAbyss),
                Expanded(child: _editorialMetricNode('85%+', 'Tôm sống khỏe mạnh', 'Giảm tối đa thiệt hại do sốc nước', isAbyss)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _editorialMetricNode(String num, String title, String sub, bool isAbyss) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          num,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF00D2FF),
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isAbyss ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: isAbyss ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 8. 3-STEP TURNKEY DEPLOYMENT
  // ===========================================================================
  Widget _buildEditorialWorkflowSection(BuildContext context, bool isDesktop, bool isAbyss) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Column(
          children: [
            _editorialSectionHeader(
              badge: 'HƯỚNG DẪN DỄ LÀM',
              title: 'Sử dụng dễ dàng chỉ trong 3 bước',
              subtitle: 'Lắp đặt đơn giản, nông dân nào cũng có thể tự làm được trong 10 phút.',
              isAbyss: isAbyss,
            ),
            const SizedBox(height: 36),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 750;
                if (isNarrow) {
                  return Column(
                    children: [
                      _editorialStepCard('01', 'Cắm điện & Thả đầu đo xuống ao', 'Thả các đầu đo pH, Oxy và Nhiệt độ vào vị trí nước chảy gần dàn quạt.', isAbyss),
                      const SizedBox(height: 14),
                      _editorialStepCard('02', 'Kết nối với hệ thống', 'Thiết bị tự kết nối Wi-Fi và gửi số liệu đo về điện thoại ngay lập tức.', isAbyss),
                      const SizedBox(height: 14),
                      _editorialStepCard('03', 'Xem nước & Nhận hướng dẫn', 'Mở điện thoại xem tình trạng nước mọi lúc mọi nơi, có cảnh báo khi nước xấu.', isAbyss),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _editorialStepCard('01', 'Cắm điện & Thả đầu đo xuống ao', 'Thả các đầu đo pH, Oxy và Nhiệt độ vào vị trí nước chảy gần dàn quạt.', isAbyss)),
                    const SizedBox(width: 16),
                    Expanded(child: _editorialStepCard('02', 'Kết nối với hệ thống', 'Thiết bị tự kết nối Wi-Fi và gửi số liệu đo về điện thoại ngay lập tức.', isAbyss)),
                    const SizedBox(width: 16),
                    Expanded(child: _editorialStepCard('03', 'Xem nước & Nhận hướng dẫn', 'Mở điện thoại xem tình trạng nước mọi lúc mọi nơi, có cảnh báo khi nước xấu.', isAbyss)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _editorialStepCard(String stepNum, String title, String desc, bool isAbyss) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isAbyss ? const Color(0x28FFFFFF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAbyss ? const Color(0x3838BDF8) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepNum,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0284C7),
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isAbyss ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: isAbyss ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 9. PREMIUM EDITORIAL CALL TO ACTION BANNER
  // ===========================================================================
  Widget _buildEditorialCtaBanner(BuildContext context, bool isDesktop, bool isAbyss) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1040),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24, vertical: 40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0348C7), Color(0xFF0072CE), Color(0xFF0284C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.35),
              blurRadius: 36,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Bắt đầu theo dõi ao tôm của bạn ngay hôm nay',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isDesktop ? 27 : 21,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(
                'Nuôi tôm an tâm hơn với hệ thống đo nước tự động và trợ lý nhắc nhở cách chăm sóc ao mỗi ngày.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: const Color(0xFFE0F2FE),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: widget.onNavigateToOverview,
              icon: const Icon(Icons.rocket_launch_rounded, size: 17),
              label: Text(
                'Vào Xem Nước Ao Ngay',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // REUSABLE EDITORIAL SECTION HEADER
  // ===========================================================================
  Widget _editorialSectionHeader({
    required String badge,
    required String title,
    required String subtitle,
    required bool isAbyss,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isAbyss
                ? const Color(0xFF00D2FF).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAbyss
                  ? const Color(0xFF00D2FF).withValues(alpha: 0.35)
                  : const Color(0xFF0284C7).withValues(alpha: 0.35),
              width: 1.1,
            ),
            boxShadow: [
              if (!isAbyss)
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Text(
            badge,
            style: GoogleFonts.jetBrainsMono(
              color: isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: isAbyss ? Colors.white : const Color(0xFF061A3A),
            letterSpacing: -0.5,
            shadows: isAbyss
                ? const [
                    Shadow(color: Color(0x3D000000), blurRadius: 10, offset: Offset(0, 2)),
                  ]
                : [
                    Shadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 10, offset: const Offset(0, 1)),
                  ],
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: isAbyss ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
              fontWeight: isAbyss ? FontWeight.w500 : FontWeight.w600,
              fontSize: 13.5,
              height: 1.5,
              shadows: isAbyss
                  ? const [
                      Shadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 1)),
                    ]
                  : [
                      Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 1)),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaterStreamFishPainter extends CustomPainter {
  _WaterStreamFishPainter({
    required this.progress,
    required this.isAbyss,
    required this.isDesktop,
  });

  final double progress;
  final bool isAbyss;
  final bool isDesktop;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final Path path = Path();
    final centerX = size.width / 2.0;

    // 4 Node Y centers based on proportional row layout
    final y1 = size.height * 0.115;
    final y2 = size.height * 0.370;
    final y3 = size.height * 0.625;
    final y4 = size.height * 0.880;
    final dy = y2 - y1;

    if (isDesktop) {
      // Gentle horizontal wave amplitude into the empty half of each row
      final amplitude = math.min(180.0, size.width * 0.20);

      // 1. Entry curve from top ocean surface into Node 01
      path.moveTo(centerX - 35.0, 0.0);
      path.cubicTo(
        centerX - 15.0, y1 * 0.40,
        centerX, y1 * 0.75,
        centerX, y1,
      );

      // 2. S-curve 01 -> 02: Sweeps smoothly to the RIGHT into the empty space of Row 1
      path.cubicTo(
        centerX + amplitude * 1.30, y1 + dy * 0.32,
        centerX + amplitude * 1.30, y2 - dy * 0.32,
        centerX, y2,
      );

      // 3. S-curve 02 -> 03: Sweeps smoothly to the LEFT into the empty space of Row 2
      path.cubicTo(
        centerX - amplitude * 1.30, y2 + dy * 0.32,
        centerX - amplitude * 1.30, y3 - dy * 0.32,
        centerX, y3,
      );

      // 4. S-curve 03 -> 04: Sweeps smoothly to the RIGHT into the empty space of Row 3
      path.cubicTo(
        centerX + amplitude * 1.30, y3 + dy * 0.32,
        centerX + amplitude * 1.30, y4 - dy * 0.32,
        centerX, y4,
      );

      // 5. Exit curve below Node 04 into the deep abyss
      path.cubicTo(
        centerX, y4 + (size.height - y4) * 0.40,
        centerX - 25.0, size.height - 15.0,
        centerX - 40.0, size.height,
      );
    } else {
      // Mobile: Clean vertical glowing water stream along node centers (x = 26.0)
      const railX = 26.0;
      path.moveTo(railX, 10.0);
      path.lineTo(railX, math.max(10.0, size.height - 10.0));
    }

    // =======================================================================
    // 1. DÒNG NƯỚC CHẢY ĐẠI DƯƠNG (Aqua Water Current Stream)
    // =======================================================================
    // 1a. Outer Water Glow Aura (Hào quang nước biển phát sáng lan tỏa)
    final auraColors = isAbyss
        ? [
            const Color(0x3500D2FF),
            const Color(0x4500E5A3),
            const Color(0x3038BDF8),
          ]
        : [
            const Color(0x250284C7),
            const Color(0x3510B981),
            const Color(0x250369A1),
          ];

    final auraPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14.0)
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        auraColors,
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(path, auraPaint);

    // 1b. Translucent Water Stream Bed (Dải nước trong suốt uốn lượn)
    final streamBedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = (isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7)).withValues(alpha: 0.22);
    canvas.drawPath(path, streamBedPaint);

    // 1c. Flowing Water Current Core Line (Lõi dòng nước phát sáng lấp lánh)
    final coreWaterColors = isAbyss
        ? [
            const Color(0xDD00D2FF),
            const Color(0xFFDFB76C),
            const Color(0xEE00E5A3),
          ]
        : [
            const Color(0xDD0284C7),
            const Color(0xFFD97706),
            const Color(0xEE10B981),
          ];

    final coreWaterPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        coreWaterColors,
        [0.0, 0.45, 1.0],
      );
    canvas.drawPath(path, coreWaterPaint);

    // =======================================================================
    // 2. GỢN SÓNG NƯỚC TỎA TRÒN TẠI CÁC NỐT MỐC (Water Ripple Rings at Nodes)
    // =======================================================================
    if (isDesktop) {
      final ripplePulse = (progress * 2.0) % 1.0;
      final ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * (1.0 - ripplePulse)
        ..color = (isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7))
            .withValues(alpha: 0.50 * (1.0 - ripplePulse));

      for (final ny in [y1, y2, y3, y4]) {
        canvas.drawCircle(Offset(centerX, ny), 28.0 + ripplePulse * 16.0, ripplePaint);
      }
    }

    // =======================================================================
    // 3. BỌT NƯỚC NỔI DỌC DÒNG CHẢY (Flowing Ocean Bubbles)
    // =======================================================================
    final metrics = path.computeMetrics();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final totalLen = metric.length;

    // Draw 10 ambient flowing bubbles
    for (int i = 0; i < 10; i++) {
      final bubbleProgress = (progress + (i / 10.0)) % 1.0;
      final tangent = metric.getTangentForOffset(totalLen * bubbleProgress);
      if (tangent != null) {
        final pos = tangent.position;
        final floatWag = math.sin((progress * 12.0 + i) * math.pi) * 7.0;
        final bubblePos = Offset(pos.dx + floatWag, pos.dy);
        final bubbleRadius = 2.2 + (i % 3) * 1.5;

        canvas.drawCircle(
          bubblePos,
          bubbleRadius,
          Paint()
            ..color = (isAbyss ? const Color(0x9900D2FF) : const Color(0x880284C7))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
        canvas.drawCircle(
          Offset(bubblePos.dx - 0.7, bubblePos.dy - 0.7),
          bubbleRadius * 0.4,
          Paint()..color = Colors.white.withValues(alpha: 0.85),
        );
      }
    }

    // =======================================================================
    // 4. ĐÀN CÁ BƠI UỐN LƯỢN DỌC DÒNG S (Swimming Fish along S-Curve)
    // =======================================================================
    // 4a. Chú cá dẫn đầu (Lead Swimming Fish)
    final leadTangent = metric.getTangentForOffset(totalLen * progress);
    if (leadTangent != null) {
      final pos = leadTangent.position;
      final angle = math.atan2(leadTangent.vector.dy, leadTangent.vector.dx);
      final tailWag = math.sin(progress * 28.0 * math.pi);
      _drawSwimmingFish(canvas, pos, angle, tailWag, scale: 1.20, isAbyss: isAbyss);
    }

    // 4b. Chú cá nhỏ bơi theo sau (Little Companion Fish following)
    final followProgress = (progress - 0.14) < 0 ? (progress - 0.14 + 1.0) : (progress - 0.14);
    final followTangent = metric.getTangentForOffset(totalLen * followProgress);
    if (followTangent != null) {
      final pos = followTangent.position;
      final angle = math.atan2(followTangent.vector.dy, followTangent.vector.dx);
      final tailWag = math.sin((progress - 0.14) * 28.0 * math.pi);
      _drawSwimmingFish(canvas, pos, angle, tailWag, scale: 0.78, isAbyss: isAbyss);
    }
  }

  /// Vẽ chú cá bơi sinh động với vây cá, đuôi vẫy sóng và mắt cá phát quang
  void _drawSwimmingFish(
    Canvas canvas,
    Offset pos,
    double angle,
    double tailWag, {
    required double scale,
    required bool isAbyss,
  }) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    canvas.scale(scale);

    // 1. Water Ripple Wake behind fish tail (Gợn nước sau đuôi cá)
    final wakePaint = Paint()
      ..color = (isAbyss ? const Color(0xFF00D2FF) : const Color(0xFF0284C7)).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(Offset(-22, tailWag * 3), 4.5, wakePaint);

    // 2. Bioluminescent Aura (Hào quang bơi phát quang)
    final fishAura = Paint()
      ..color = (isAbyss ? const Color(0xFF00E5A3) : const Color(0xFF10B981)).withValues(alpha: 0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 34, height: 16), fishAura);

    // 3. Fish Body (Thân cá uốn lượn thon gọn)
    final bodyPath = Path();
    bodyPath.moveTo(15, 0); // Mũi cá
    bodyPath.quadraticBezierTo(4, -8, -10, -4); // Lưng cá
    bodyPath.lineTo(-19, tailWag * 7 - 5); // Vây đuôi trên (vẫy sóng)
    bodyPath.lineTo(-14, tailWag * 3); // Khuyết đuôi giữa
    bodyPath.lineTo(-19, tailWag * 7 + 5); // Vây đuôi dưới (vẫy sóng)
    bodyPath.lineTo(-10, 4); // Bụng cá
    bodyPath.quadraticBezierTo(4, 8, 15, 0); // Bụng về mũi
    bodyPath.close();

    final bodyGradient = ui.Gradient.linear(
      const Offset(-19, 0),
      const Offset(15, 0),
      isAbyss
          ? [const Color(0xFF00E5A3), const Color(0xFFDFB76C), const Color(0xFFFFFFFF)]
          : [const Color(0xFF10B981), const Color(0xFFD97706), const Color(0xFFFFFFFF)],
      [0.0, 0.65, 1.0],
    );

    final bodyPaint = Paint()
      ..shader = bodyGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    // 4. Fish Fins (Vây cá bơi 2 bên)
    final finPaint = Paint()
      ..color = (isAbyss ? const Color(0xFFDFB76C) : const Color(0xFFD97706)).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final finPath = Path()
      ..moveTo(1, 3)
      ..quadraticBezierTo(-4, 10, -9, 7)
      ..lineTo(-4, 3)
      ..close();
    canvas.drawPath(finPath, finPaint);

    // 5. Fish Eye (Mắt cá biển phát quang)
    final eyeWhite = Paint()..color = Colors.white;
    final eyePupil = Paint()..color = const Color(0xFF040A18);
    canvas.drawCircle(const Offset(8.5, -2.5), 2.2, eyeWhite);
    canvas.drawCircle(const Offset(9.0, -2.5), 1.1, eyePupil);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WaterStreamFishPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isAbyss != isAbyss ||
        oldDelegate.isDesktop != isDesktop;
  }
}
