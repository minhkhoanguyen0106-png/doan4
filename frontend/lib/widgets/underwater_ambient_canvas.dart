import 'dart:math' as math;
import 'package:flutter/material.dart';

enum OceanLightingMode {
  abyssal, // 🌌 Magical Deep Ocean: deep navy, bioluminescent emerald & violet glows
  sunlit,  // ☀️ Sunlit Lagoon: clear turquoise azure, brilliant volumetric sunbeams
}

/// Magical Deep Ocean Ambient Engine
/// Renders a multi-layered, living marine ecosystem:
/// - Volumetric God Rays with sweeping ambient shimmer
/// - Procedural Water Caustics (reticulated light ripple mesh)
/// - Bioluminescent plankton spores with multi-stage bloom halos
/// - Schooling fish flocking in natural rhythmic formation
/// - Anatomical bioluminescent shrimps with paddling swimmerets & long floating antennae
/// - Glassy rising bubbles with specular glints & physics wobble
/// - Interactive water ripple disturbance reacting to mouse motion
class UnderwaterAmbientBackground extends StatefulWidget {
  const UnderwaterAmbientBackground({
    super.key,
    required this.child,
    this.scrollOffset = 0.0,
    this.lightingMode = OceanLightingMode.abyssal,
    this.onToggleLighting,
    this.brightness = 1.0,
    this.enableCreatures = true,
  });

  final Widget child;
  final double scrollOffset;
  final OceanLightingMode lightingMode;
  final VoidCallback? onToggleLighting;
  final double brightness;
  final bool enableCreatures;

  @override
  State<UnderwaterAmbientBackground> createState() => _UnderwaterAmbientBackgroundState();
}

class _UnderwaterAmbientBackgroundState extends State<UnderwaterAmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  Offset? _mousePosition;

  // Living Ecosystem State Pools
  late final List<_MagicalBubble> _bubbles;
  late final List<_PlanktonSpore> _spores;
  late final List<_ShrimpEntity> _shrimps;
  late final _FishSchool _fishSchool;
  late final List<_VolumetricBeam> _beams;

  @override
  void initState() {
    super.initState();
    final random = math.Random(1337);

    // 1. Rising glassy bubbles (60 items, varying depths & cluster offsets)
    _bubbles = List.generate(60, (i) => _MagicalBubble.random(random, i));

    // 2. Bioluminescent plankton spores (190 items with bloom properties)
    _spores = List.generate(190, (i) => _PlanktonSpore.random(random, i));

    // 3. Shrimps (4 distinct depth planes, graceful pacing)
    _shrimps = [
      _ShrimpEntity(depthLayer: 0, yRatio: 0.18, speed: 0.55, scale: 0.75, movingRight: true, seed: 1.2),
      _ShrimpEntity(depthLayer: 1, yRatio: 0.44, speed: 0.85, scale: 1.15, movingRight: false, seed: 3.4),
      _ShrimpEntity(depthLayer: 0, yRatio: 0.70, speed: 0.50, scale: 0.70, movingRight: true, seed: 5.6),
      _ShrimpEntity(depthLayer: 1, yRatio: 0.86, speed: 0.75, scale: 1.05, movingRight: false, seed: 7.8),
    ];

    // 4. Coordinated School of Pelagic Fish (flocking boids)
    _fishSchool = _FishSchool(count: 9, random: random);

    // 5. Volumetric Sweeping Light Rays (8 beams with sweeping angular frequencies)
    _beams = List.generate(8, (i) => _VolumetricBeam(
      baseAngle: -0.40 + (i * 0.05),
      originX: 0.12 + (i * 0.12),
      topWidth: 70.0 + (i * 22.0),
      bottomSpread: 210.0 + (i * 65.0),
      intensity: 0.18 + (random.nextDouble() * 0.20),
      sweepSpeed: 0.22 + (random.nextDouble() * 0.18),
      phase: i * 0.90,
    ));

    // Continuous 60 FPS animation ticker
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAbyss = widget.lightingMode == OceanLightingMode.abyssal;

    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      onExit: (_) {
        setState(() {
          _mousePosition = null;
        });
      },
      child: Stack(
        children: [
          // 1. Deep Multi-Tier Atmospheric Ocean Canvas Gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isAbyss
                      ? const [
                          Color(0xFF032238), // Night surface cyan-marine glow (Ảnh 2)
                          Color(0xFF02192A), // Deep pelagic ocean water
                          Color(0xFF011220), // Dark abyss depths
                          Color(0xFF010A14), // Benthic midnight ocean floor
                        ]
                      : const [
                          Color(0xFF0275B8), // Sunlit tropical azure surface (Ảnh 3 & 1)
                          Color(0xFF0EA5E9), // Crystal clear turquoise lagoon
                          Color(0xFF38BDF8), // Light water column
                          Color(0xFFBAE6FD), // Bright sandy seabed reflection
                        ],
                  stops: const [0.0, 0.30, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // 2. Multi-Layer Underwater Ambient Living Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ticker,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MagicalOceanPainter(
                    time: _ticker.value * 120.0,
                    scrollOffset: widget.scrollOffset,
                    isAbyss: isAbyss,
                    brightness: widget.brightness,
                    mousePos: _mousePosition,
                    bubbles: _bubbles,
                    spores: _spores,
                    shrimps: widget.enableCreatures ? _shrimps : const [],
                    school: widget.enableCreatures ? _fishSchool : null,
                    beams: _beams,
                  ),
                );
              },
            ),
          ),

          // 3. Foreground Child Content Pass-through
          widget.child,
        ],
      ),
    );
  }
}

// ===========================================================================
// LIVING ECOSYSTEM SIMULATION MODELS
// ===========================================================================

class _MagicalBubble {
  _MagicalBubble({
    required this.xRatio,
    required this.radius,
    required this.speed,
    required this.wobbleFreq,
    required this.wobbleAmp,
    required this.depth,
    required this.seed,
  });

  final double xRatio;
  final double radius;
  final double speed;
  final double wobbleFreq;
  final double wobbleAmp;
  final double depth; // 0.2 (far) to 1.0 (near)
  final double seed;

  factory _MagicalBubble.random(math.Random r, int index) {
    final roll = r.nextDouble();
    final double radius;
    if (roll < 0.50) {
      radius = 0.9 + (r.nextDouble() * 1.8); // Micro aeration bubble
    } else if (roll < 0.85) {
      radius = 2.8 + (r.nextDouble() * 2.2); // Medium buoyant bubble
    } else {
      radius = 5.2 + (r.nextDouble() * 3.6); // Large glint bubble
    }

    return _MagicalBubble(
      xRatio: r.nextDouble(),
      radius: radius,
      speed: 18.0 + (r.nextDouble() * 42.0),
      wobbleFreq: 1.4 + (r.nextDouble() * 2.4),
      wobbleAmp: 3.5 + (r.nextDouble() * 12.0),
      depth: 0.25 + (r.nextDouble() * 0.75),
      seed: index * 1.8,
    );
  }
}

class _PlanktonSpore {
  _PlanktonSpore({
    required this.xRatio,
    required this.yRatio,
    required this.radius,
    required this.pulseFreq,
    required this.paletteType,
    required this.driftSpeed,
    required this.depth,
  });

  final double xRatio;
  final double yRatio;
  final double radius;
  final double pulseFreq;
  final int paletteType; // 0: electric cyan, 1: sea emerald/mint, 2: starlight diamond white, 3: aqua glow
  final double driftSpeed;
  final double depth;

  factory _PlanktonSpore.random(math.Random r, int index) {
    // 70% tiny stars (0.7 to 1.8px), 20% medium (1.8 to 2.8px), 10% large glowing bloomers (2.8 to 4.2px)
    final roll = r.nextDouble();
    final double radius;
    if (roll < 0.70) {
      radius = 0.7 + (r.nextDouble() * 1.1);
    } else if (roll < 0.90) {
      radius = 1.8 + (r.nextDouble() * 1.0);
    } else {
      radius = 2.8 + (r.nextDouble() * 1.4);
    }

    return _PlanktonSpore(
      xRatio: r.nextDouble(),
      yRatio: r.nextDouble(),
      radius: radius,
      pulseFreq: 0.8 + (r.nextDouble() * 2.2),
      paletteType: index % 4,
      driftSpeed: 5.0 + (r.nextDouble() * 16.0),
      depth: 0.2 + (r.nextDouble() * 0.8),
    );
  }
}

class _ShrimpEntity {
  _ShrimpEntity({
    required this.depthLayer,
    required this.yRatio,
    required this.speed,
    required this.scale,
    required this.movingRight,
    required this.seed,
  });

  final int depthLayer; // 0: far, 1: near
  final double yRatio;
  final double speed;
  final double scale;
  final bool movingRight;
  final double seed;
}

class _FishSchool {
  _FishSchool({required int count, required math.Random random}) {
    members = List.generate(count, (i) => _SchoolMember(
      offsetX: (i * -26.0) + (random.nextDouble() * 12.0),
      offsetY: ((i % 3) * 16.0) - 16.0 + (random.nextDouble() * 8.0),
      scale: 0.82 + (random.nextDouble() * 0.28),
      phase: i * 0.45,
    ));
  }

  late final List<_SchoolMember> members;
}

class _SchoolMember {
  _SchoolMember({
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.phase,
  });

  final double offsetX;
  final double offsetY;
  final double scale;
  final double phase;
}

class _VolumetricBeam {
  _VolumetricBeam({
    required this.baseAngle,
    required this.originX,
    required this.topWidth,
    required this.bottomSpread,
    required this.intensity,
    required this.sweepSpeed,
    required this.phase,
  });

  final double baseAngle;
  final double originX;
  final double topWidth;
  final double bottomSpread;
  final double intensity;
  final double sweepSpeed;
  final double phase;
}

// ===========================================================================
// MASTER GPU CANVAS RENDERER — MAGICAL DEEP OCEAN
// ===========================================================================

class _MagicalOceanPainter extends CustomPainter {
  _MagicalOceanPainter({
    required this.time,
    required this.scrollOffset,
    required this.isAbyss,
    required this.brightness,
    required this.mousePos,
    required this.bubbles,
    required this.spores,
    required this.shrimps,
    required this.school,
    required this.beams,
  });

  final double time;
  final double scrollOffset;
  final bool isAbyss;
  final double brightness;
  final Offset? mousePos;
  final List<_MagicalBubble> bubbles;
  final List<_PlanktonSpore> spores;
  final List<_ShrimpEntity> shrimps;
  final _FishSchool? school;
  final List<_VolumetricBeam> beams;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Layer 0: Volumetric Sunbeams & Light Rays
    _paintVolumetricLightBeams(canvas, size);

    // Layer 1: Procedural Water Caustics Shimmer (reticulated light mesh)
    _paintAnimatedCaustics(canvas, size);

    // Layer 2: Deep Ambient Haze & Bioluminescent Nebulae
    _paintUnderwaterHaze(canvas, size);

    // Layer 2.5: Seabed Environment (Daytime Sand Caustics / Nighttime Benthic Reef)
    _paintSeabedEnvironment(canvas, size);

    // Layer 3: Far Depth Shrimps (subtle aquatic silhouettes)
    for (final shrimp in shrimps.where((s) => s.depthLayer == 0)) {
      _paintShrimp(canvas, size, shrimp);
    }

    // Layer 4: School of Pelagic Fish (flocking boids)
    if (school != null) {
      _paintFishSchool(canvas, size, school!);
    }

    // Layer 5: Bioluminescent Plankton with Multi-Tier Glow & Bloom
    _paintBioluminescentSpores(canvas, size);

    // Layer 6: Near Depth Shrimps (high definition with glowing contours)
    for (final shrimp in shrimps.where((s) => s.depthLayer == 1)) {
      _paintShrimp(canvas, size, shrimp);
    }

    // Layer 7: Rising Glassy Bubbles with Specular Highlights & Parallax
    _paintBubbles(canvas, size);

    // Layer 8: Interactive Cursor Water Halo & Repulsion
    if (mousePos != null) {
      _paintInteractiveWaterWake(canvas, size, mousePos!);
    }
  }

  // --- LAYER 0: VOLUMETRIC LIGHT BEAMS (GOD RAYS) ---
  void _paintVolumetricLightBeams(Canvas canvas, Size size) {
    final baseOpacity = (isAbyss ? 0.22 : 0.28) * brightness;
    final beamColor = isAbyss ? const Color(0xFF00E5FF) : const Color(0xFFFFFFFF);
    final beamColor2 = isAbyss ? const Color(0xFF0284C7) : const Color(0xFFBAE6FD);

    for (int i = 0; i < beams.length; i++) {
      final b = beams[i];
      // Angle orientation slanted from upper-right to lower-left like in reference photos
      final sweep = math.sin((time * b.sweepSpeed) + b.phase) * 0.05;
      final angle = (isAbyss ? -0.42 : -0.32) + (i * 0.05) + sweep;
      final startX = size.width * (0.15 + (b.originX * 0.78));
      final xOffsetBottom = math.tan(angle) * size.height;

      final path = Path()
        ..moveTo(startX - (b.topWidth * 0.35), 0)
        ..lineTo(startX + (b.topWidth * 0.65), 0)
        ..lineTo(startX + (b.bottomSpread * 0.85) + xOffsetBottom, size.height)
        ..lineTo(startX - (b.bottomSpread * 0.25) + xOffsetBottom, size.height)
        ..close();

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            beamColor.withValues(alpha: baseOpacity * b.intensity * 2.0),
            beamColor2.withValues(alpha: baseOpacity * b.intensity * 0.85),
            Colors.transparent,
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0);

      canvas.drawPath(path, paint);
    }
  }

  // --- LAYER 1: PROCEDURAL WATER CAUSTICS SHIMMER ---
  void _paintAnimatedCaustics(Canvas canvas, Size size) {
    final causticAlpha = (isAbyss ? 0.10 : 0.16) * brightness;
    final causticColor = isAbyss ? const Color(0xFF00D2FF) : const Color(0xFFFFFFFF);

    final path = Path();
    const rows = 4;
    final step = size.width / 45.0;

    for (int r = 0; r < rows; r++) {
      path.reset();
      final baseY = (size.height * 0.18) + (r * 180.0) - (scrollOffset * 0.08);

      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width + step; x += step) {
        // Dual-phase interference wave simulating organic water refraction web
        final y1 = math.sin((x * 0.009) + (time * 0.75) + (r * 1.6)) * 14.0;
        final y2 = math.cos((x * 0.016) - (time * 0.45) + (r * 2.2)) * 9.0;
        final y3 = math.sin((x * 0.024) + (time * 0.90)) * 4.0;
        path.lineTo(x, baseY + y1 + y2 + y3);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      final paint = Paint()
        ..color = causticColor.withValues(alpha: causticAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      canvas.drawPath(path, paint);
    }
  }

  // --- LAYER 2: DEEP UNDERWATER HAZE & NEBULAE ---
  void _paintUnderwaterHaze(Canvas canvas, Size size) {
    if (!isAbyss) return;

    // Top luminous aqua water fog
    final topHazePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D2FF).withValues(alpha: 0.15 * brightness),
          const Color(0xFF0284C7).withValues(alpha: 0.05 * brightness),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, 80), radius: size.width * 0.65))
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.6), topHazePaint);

    // Deep benthic abyssal violet bloom
    final benthicHazePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C3AED).withValues(alpha: 0.10 * brightness),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.85), radius: 380))
      ..blendMode = BlendMode.screen;

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.85), 380, benthicHazePaint);
  }

  // --- LAYER 2.5: SEABED CAUSTICS (DAYTIME ONLY) ---
  void _paintSeabedEnvironment(Canvas canvas, Size size) {
    if (isAbyss) return; // Clean, seamless, pure bioluminescent ocean gradient for nighttime (no dark line/band)

    // DAYTIME (Ảnh 3): Bright sandy seabed with shimmering caustics network
    final sandStartY = size.height * 0.68;
    final sandRect = Rect.fromLTWH(0, sandStartY, size.width, size.height - sandStartY);

    final sandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF7DD3FC).withValues(alpha: 0.18 * brightness),
          const Color(0xFFBAE6FD).withValues(alpha: 0.38 * brightness),
          const Color(0xFFE0F4FE).withValues(alpha: 0.55 * brightness),
        ],
        stops: const [0.0, 0.30, 0.70, 1.0],
      ).createShader(sandRect);

    canvas.drawRect(sandRect, sandPaint);

    // Sandy floor caustics wave mesh (Ảnh 3: gợn lưới nắng chiếu xuống cát trắng)
    final causticPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.24 * brightness)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..blendMode = BlendMode.screen
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final cPath = Path();
    const waveRows = 3;
    final xStep = size.width / 36.0;

    for (int wr = 0; wr < waveRows; wr++) {
      cPath.reset();
      final rowY = sandStartY + (wr * 50.0) + 20.0;
      cPath.moveTo(0, rowY);
      for (double x = 0; x <= size.width + xStep; x += xStep) {
        final dy = math.sin((x * 0.012) + (time * 0.8) + (wr * 2.1)) * 9.0
                 + math.cos((x * 0.022) - (time * 0.5) + wr) * 6.0;
        cPath.lineTo(x, rowY + dy);
      }
      canvas.drawPath(cPath, causticPaint);
    }
  }

  // --- LAYER 4: COHESIVE SCHOOL OF PELAGIC FISH (FLOCKING BOIDS) ---
  void _paintFishSchool(Canvas canvas, Size size, _FishSchool school) {
    final schoolSpeed = 26.0;
    final totalDistance = size.width + 360.0;
    final progress = ((time * schoolSpeed) % totalDistance);

    // School swims left to right along a gentle sinusoidal undulating current
    final schoolBaseX = -180.0 + progress;
    final schoolBaseY = (size.height * 0.32) + (math.sin(time * 0.6) * 45.0) - (scrollOffset * 0.14);

    if (schoolBaseY < -120 || schoolBaseY > size.height + 120) return;

    for (final fish in school.members) {
      final fishX = schoolBaseX + fish.offsetX;
      final fishY = schoolBaseY + fish.offsetY + (math.sin((time * 2.5) + fish.phase) * 6.0);

      if (fishX < -80 || fishX > size.width + 80) continue;

      canvas.save();
      canvas.translate(fishX, fishY);
      canvas.scale(fish.scale * 0.85, fish.scale * 0.85);

      final tailWag = math.sin((time * 7.5) + fish.phase) * 6.0;
      final bodyColor = isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
      final alpha = (isAbyss ? 0.40 : 0.65) * brightness;

      // Fish hydrodynamic body
      final path = Path()
        ..moveTo(24, 0)
        ..quadraticBezierTo(8, -8, -10, -3)
        ..lineTo(-24, -10 + tailWag)
        ..lineTo(-18, 0 + (tailWag * 0.4))
        ..lineTo(-24, 10 + tailWag)
        ..lineTo(-10, 3)
        ..quadraticBezierTo(8, 8, 24, 0)
        ..close();

      final fishPaint = Paint()
        ..color = bodyColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isAbyss ? 2.0 : 0.8);

      canvas.drawPath(path, fishPaint);

      // Bioluminescent eye beacon
      final eyePaint = Paint()
        ..color = isAbyss ? const Color(0xFF67E8F9) : const Color(0xFF0F172A)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(15, -2), 1.5, eyePaint);

      canvas.restore();
    }
  }

  // --- LAYER 3 & 6: ANATOMICAL BIOLUMINESCENT SHRIMPS ---
  void _paintShrimp(Canvas canvas, Size size, _ShrimpEntity shrimp) {
    final depthMult = shrimp.depthLayer == 0 ? 0.10 : 0.24;
    final parallaxY = scrollOffset * depthMult;

    final totalDistance = size.width + 300.0;
    final travelSpeed = shrimp.speed * 25.0;
    final currentX = shrimp.movingRight
        ? -150.0 + ((time * travelSpeed + (shrimp.seed * 80.0)) % totalDistance)
        : size.width + 150.0 - ((time * travelSpeed + (shrimp.seed * 80.0)) % totalDistance);

    // Natural undulating swimming wave (gentle sinusoidal hover)
    final undulation = math.sin((time * 2.2) + shrimp.seed) * 12.0;
    final currentY = (size.height * shrimp.yRatio) + undulation - parallaxY;

    if (currentY < -140 || currentY > size.height + 140) return;

    canvas.save();
    canvas.translate(currentX, currentY);

    if (!shrimp.movingRight) {
      canvas.scale(-1.0, 1.0); // flip horizontally for forward propulsion
    }

    // Dynamic pitch angle responding to swimming propulsion wave
    final pitchAngle = math.cos((time * 3.2) + shrimp.seed) * 0.08;
    canvas.rotate(pitchAngle);

    final scale = shrimp.scale * (shrimp.depthLayer == 0 ? 0.70 : 1.10);
    canvas.scale(scale, scale);

    _drawRealisticShrimp(canvas, shrimp, shrimp.depthLayer == 1);

    canvas.restore();
  }

  /// True Anatomical Penaeid Shrimp (Tôm thẻ chân trắng / Penaeus vannamei)
  /// Features:
  /// - Serrated rostrum with dorsal & ventral teeth
  /// - Stalked compound eyes with corneal specular glint
  /// - Translucent chitin body with soft, delicate, pale tones
  /// - 6 articulated overlapping abdominal tergites with characteristic 3rd segment dorsal hump
  /// - Subtle dorsal digestive tract (chỉ lưng) & soft specular ridge highlight
  /// - Tail fan: needle-sharp telson flanked by layered uropods with setae fringes
  /// - 5 pairs of articulated walking legs (pereiopods)
  /// - 5 pairs of metachronal paddling swimmerets (pleopods)
  /// - Long, sinuous trailing antennae with harmonic wave kinematics
  void _drawRealisticShrimp(Canvas canvas, _ShrimpEntity shrimp, bool isNear) {
    // 1. Biological swimming flexion:
    final swimCycle = (time * 3.4) + shrimp.seed;
    final swimKick = math.sin(swimCycle); // -1.0 to 1.0 abdominal contraction
    final abdominalDip = swimKick * 4.5;

    // 2. Translucent, soft & pale chitin palettes (màu tôm nhạt, thanh thoát, trong suốt):
    final alpha = (shrimp.depthLayer == 0 ? 0.18 : 0.38) * brightness;
    final baseChitin = isAbyss
        ? const Color(0x66BAE6FD).withValues(alpha: alpha)
        : const Color(0x557DD3FC).withValues(alpha: alpha);
    final coreAmber = isAbyss
        ? const Color(0x55FDBA74).withValues(alpha: alpha * 0.35)
        : const Color(0x44FCD34D).withValues(alpha: alpha * 0.30);
    final shellEdge = isAbyss
        ? const Color(0xBBF0F9FF).withValues(alpha: alpha * 0.80)
        : const Color(0x990284C7).withValues(alpha: alpha * 0.70);
    final specularHighlight = Colors.white.withValues(alpha: alpha * 0.60);

    // 3. LAYER A: CEPHALOTHORAX (ĐẦU NGỰC)
    // Rostrum with 7 dorsal serrations and 2 ventral serrations
    final carapacePath = Path();
    carapacePath.moveTo(32, -4);
    // Upper rostrum curve with fine dorsal teeth
    carapacePath.lineTo(36, -6);
    carapacePath.lineTo(37, -5.5);
    carapacePath.lineTo(41, -8);
    carapacePath.lineTo(42, -7.5);
    carapacePath.lineTo(46, -10);
    carapacePath.lineTo(47, -9.5);
    carapacePath.lineTo(52, -11.5);
    carapacePath.lineTo(53, -11);
    carapacePath.lineTo(58, -12);
    // Rostrum needle tip
    carapacePath.lineTo(64, -12.5);
    // Underside of rostrum with 2 teeth
    carapacePath.lineTo(56, -10.5);
    carapacePath.lineTo(52, -10);
    carapacePath.lineTo(48, -8);
    carapacePath.lineTo(34, -1);
    // Antennal notch and orbit
    carapacePath.quadraticBezierTo(32, 2, 30, 4);
    // Ventral carapace margin (covering gills)
    carapacePath.quadraticBezierTo(16, 12, -2, 10);
    // Posterior margin connecting to 1st abdominal segment
    carapacePath.lineTo(-4, -6);
    // Dorsal carapace crest
    carapacePath.quadraticBezierTo(14, -12, 32, -4);
    carapacePath.close();

    // Fill carapace with soft chitin gradient
    final carapacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          shellEdge,
          baseChitin,
          coreAmber,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(const Rect.fromLTWH(-6, -14, 72, 26))
      ..style = PaintingStyle.fill;
    canvas.drawPath(carapacePath, carapacePaint);

    final edgePaint = Paint()
      ..color = shellEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;
    canvas.drawPath(carapacePath, edgePaint);

    // Internal hepatopancreas (nội tạng màu ấm mờ nhạt bên trong vỏ)
    final organPaint = Paint()
      ..color = coreAmber
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawOval(const Rect.fromLTWH(8, -4, 18, 10), organPaint);

    // Cervical groove line (rãnh cổ đặc trưng)
    final groovePath = Path()
      ..moveTo(16, -9)
      ..quadraticBezierTo(14, -1, 8, 4);
    final groovePaint = Paint()
      ..color = (isAbyss ? const Color(0x3338BDF8) : const Color(0x220284C7)).withValues(alpha: alpha * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;
    canvas.drawPath(groovePath, groovePaint);

    // Compound Eye with articulated stalk
    final eyeStalkPath = Path()
      ..moveTo(29, -5)
      ..lineTo(33, -9);
    canvas.drawPath(eyeStalkPath, edgePaint..strokeWidth = 0.9);
    // Deep obsidian compound eye cornea
    final eyePaint = Paint()
      ..color = (isAbyss ? const Color(0xCC0F172A) : const Color(0xBB020617)).withValues(alpha: math.min(1.0, alpha * 2.2))
      ..style = PaintingStyle.fill;
    canvas.drawOval(const Rect.fromLTWH(31.5, -12.5, 4.5, 3.8), eyePaint);
    // Specular light reflection on eye
    final eyeGlintPaint = Paint()
      ..color = Colors.white.withValues(alpha: math.min(1.0, alpha * 2.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(34.2, -11.2), 0.8, eyeGlintPaint);

    // Antennular scale (Scaphocerite - vảy râu dạng phiến lá)
    final scaphoceritePath = Path()
      ..moveTo(31, 0)
      ..quadraticBezierTo(42, -2, 49, -4)
      ..lineTo(48, -1)
      ..quadraticBezierTo(40, 2, 31, 2)
      ..close();
    canvas.drawPath(scaphoceritePath, Paint()..color = baseChitin.withValues(alpha: alpha * 0.4)..style = PaintingStyle.fill);
    canvas.drawPath(scaphoceritePath, edgePaint..strokeWidth = 0.6);

    // 4. LAYER B: 6 ARTICULATED ABDOMINAL SEGMENTS (6 ĐỐT BỤNG)
    // Segment 1
    final seg1 = Path()
      ..moveTo(-2, -6)
      ..quadraticBezierTo(-8, -8, -14, -8)
      ..lineTo(-14, 8)
      ..quadraticBezierTo(-8, 9, -2, 10)
      ..close();
    canvas.drawPath(seg1, carapacePaint);
    canvas.drawPath(seg1, edgePaint..strokeWidth = 0.70);

    // Segment 2
    final seg2 = Path()
      ..moveTo(-12, -8)
      ..quadraticBezierTo(-19, -9, -26, -9)
      ..lineTo(-26, 7)
      ..quadraticBezierTo(-19, 8, -12, 8)
      ..close();
    canvas.drawPath(seg2, carapacePaint);
    canvas.drawPath(seg2, edgePaint..strokeWidth = 0.70);

    // Segment 3: Characteristic Dorsal Hump (Gù lưng tôm thẻ)
    final seg3 = Path()
      ..moveTo(-24, -9)
      ..quadraticBezierTo(-32, -9.5, -39, -6.5 + (abdominalDip * 0.2))
      ..lineTo(-38, 5.5 + (abdominalDip * 0.2))
      ..quadraticBezierTo(-31, 6.5, -24, 7)
      ..close();
    canvas.drawPath(seg3, carapacePaint);
    canvas.drawPath(seg3, edgePaint..strokeWidth = 0.70);

    // Segment 4
    final seg4 = Path()
      ..moveTo(-37, -6.5 + (abdominalDip * 0.2))
      ..quadraticBezierTo(-44, -3 + (abdominalDip * 0.4), -50, 0 + (abdominalDip * 0.5))
      ..lineTo(-49, 9.5 + (abdominalDip * 0.5))
      ..quadraticBezierTo(-43, 6.5 + (abdominalDip * 0.4), -37, 5.5 + (abdominalDip * 0.2))
      ..close();
    canvas.drawPath(seg4, carapacePaint);
    canvas.drawPath(seg4, edgePaint..strokeWidth = 0.70);

    // Segment 5
    final seg5 = Path()
      ..moveTo(-48, 0 + (abdominalDip * 0.5))
      ..quadraticBezierTo(-55, 3.5 + (abdominalDip * 0.7), -61, 7 + (abdominalDip * 0.85))
      ..lineTo(-60, 14.5 + (abdominalDip * 0.85))
      ..quadraticBezierTo(-54, 11.5 + (abdominalDip * 0.7), -48, 9.5 + (abdominalDip * 0.5))
      ..close();
    canvas.drawPath(seg5, carapacePaint);
    canvas.drawPath(seg5, edgePaint..strokeWidth = 0.70);

    // Segment 6 (Tail stem)
    final seg6 = Path()
      ..moveTo(-59, 7 + (abdominalDip * 0.85))
      ..quadraticBezierTo(-66, 11 + (abdominalDip * 1.0), -72, 14 + (abdominalDip * 1.15))
      ..lineTo(-71, 19 + (abdominalDip * 1.15))
      ..quadraticBezierTo(-65, 16.5 + (abdominalDip * 1.0), -59, 14.5 + (abdominalDip * 0.85))
      ..close();
    canvas.drawPath(seg6, carapacePaint);
    canvas.drawPath(seg6, edgePaint..strokeWidth = 0.70);

    // Dorsal digestive vessel (chỉ lưng tôm mảnh mai)
    final dorsalLinePath = Path()
      ..moveTo(20, -8)
      ..quadraticBezierTo(5, -9, -12, -7)
      ..quadraticBezierTo(-25, -7.5, -38, -5 + (abdominalDip * 0.2))
      ..quadraticBezierTo(-50, 1.5 + (abdominalDip * 0.5), -70, 15 + (abdominalDip * 1.15));
    canvas.drawPath(
      dorsalLinePath,
      Paint()
        ..color = (isAbyss ? const Color(0xFF0284C7) : const Color(0xFF0369A1)).withValues(alpha: alpha * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75,
    );

    // Dorsal Specular Ridge Highlight (Ánh sáng phản chiếu dịu nhẹ sống lưng)
    final dorsalHighlightPath = Path()
      ..moveTo(24, -9)
      ..quadraticBezierTo(10, -11, -10, -7.5)
      ..quadraticBezierTo(-24, -8.5, -38, -6 + (abdominalDip * 0.2));
    canvas.drawPath(
      dorsalHighlightPath,
      Paint()
        ..color = specularHighlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // 5. LAYER C: TAIL FAN (QUẠT ĐUÔI - TELSON & UROPODS)
    final tailOriginX = -71.0;
    final tailOriginY = 16.5 + (abdominalDip * 1.15);

    // Outer Upper Uropod (Exopod)
    final uropodOuterPath = Path()
      ..moveTo(tailOriginX, tailOriginY)
      ..quadraticBezierTo(tailOriginX - 12, tailOriginY - 8, tailOriginX - 25, tailOriginY - 5)
      ..quadraticBezierTo(tailOriginX - 18, tailOriginY + 2, tailOriginX - 2, tailOriginY + 1)
      ..close();
    canvas.drawPath(uropodOuterPath, Paint()..color = baseChitin.withValues(alpha: alpha * 0.5)..style = PaintingStyle.fill);
    canvas.drawPath(uropodOuterPath, edgePaint..strokeWidth = 0.6);

    // Outer Lower Uropod
    final uropodLowerPath = Path()
      ..moveTo(tailOriginX, tailOriginY)
      ..quadraticBezierTo(tailOriginX - 14, tailOriginY + 12, tailOriginX - 24, tailOriginY + 10)
      ..quadraticBezierTo(tailOriginX - 16, tailOriginY + 3, tailOriginX - 2, tailOriginY + 1)
      ..close();
    canvas.drawPath(uropodLowerPath, Paint()..color = baseChitin.withValues(alpha: alpha * 0.5)..style = PaintingStyle.fill);
    canvas.drawPath(uropodLowerPath, edgePaint..strokeWidth = 0.6);

    // Central Sharp Telson (Chóp kim telson ở giữa)
    final telsonPath = Path()
      ..moveTo(tailOriginX + 1, tailOriginY - 1)
      ..lineTo(tailOriginX - 28, tailOriginY + 2) // spear point
      ..lineTo(tailOriginX + 1, tailOriginY + 3)
      ..close();
    canvas.drawPath(telsonPath, Paint()..color = coreAmber.withValues(alpha: alpha * 0.6)..style = PaintingStyle.fill);
    canvas.drawPath(telsonPath, edgePaint..strokeWidth = 0.7);

    // Setae fringes on tail fan (viền lông tơ quạt đuôi mờ ảo)
    final setaePaint = Paint()
      ..color = (isAbyss ? const Color(0xFF67E8F9) : const Color(0xFF38BDF8)).withValues(alpha: alpha * 0.4)
      ..strokeWidth = 0.5;
    for (int s = 0; s < 5; s++) {
      final sx = tailOriginX - 16.0 - (s * 2.0);
      final sy = tailOriginY - 4.0 + (s * 3.0);
      canvas.drawLine(Offset(sx, sy), Offset(sx - 4.0, sy + 1.0), setaePaint);
    }

    // 6. LAYER D: APPENDAGES - WALKING LEGS (PEREIOPODS)
    final legPaint = Paint()
      ..color = shellEdge.withValues(alpha: alpha * 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    for (int leg = 0; leg < 5; leg++) {
      final legBaseX = 6.0 + (leg * 4.5);
      final legBaseY = 10.0 - (leg * 0.5);
      final legSway = math.sin(swimCycle + (leg * 0.4)) * 2.0;

      final legPath = Path()
        ..moveTo(legBaseX, legBaseY)
        ..lineTo(legBaseX - 3.0, legBaseY + 6.0)
        ..lineTo(legBaseX + 2.0 + legSway, legBaseY + 13.0);
      canvas.drawPath(legPath, legPaint);
    }

    // 7. LAYER E: APPENDAGES - SWIMMING PLEOPODS (CHÂN BƠI DƯỚI BỤNG)
    final pleopodPaint = Paint()
      ..color = (isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)).withValues(alpha: alpha * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    for (int p = 0; p < 5; p++) {
      final pPhase = swimCycle - (p * 0.65);
      final strokeKick = math.sin(pPhase) * 6.5;
      final pAngle = math.cos(pPhase) * 0.35;

      final px = -8.0 - (p * 11.0);
      final py = 8.0 + (p * 1.5) + (abdominalDip * (p / 5.0));

      final pleoPath = Path()
        ..moveTo(px, py)
        ..lineTo(px - 4.0 + strokeKick, py + 8.0)
        ..lineTo(px - 7.0 + (strokeKick * 1.2), py + 14.0 + (pAngle * 4.0));
      canvas.drawPath(pleoPath, pleopodPaint);

      // Secondary paddle blade
      canvas.drawLine(
        Offset(px - 4.0 + strokeKick, py + 8.0),
        Offset(px - 2.0 + strokeKick, py + 13.5),
        pleopodPaint..strokeWidth = 0.55,
      );
    }

    // 8. LAYER F: FLOWING TRAILING ANTENNAE (2 CẶP RÂU SIÊU DÀI, UỐN LƯỢN)
    final antennuleWave = math.sin(time * 4.0) * 3.0;
    final antennulePath = Path()
      ..moveTo(34, -4)
      ..quadraticBezierTo(48, -14 + antennuleWave, 68, -18 + antennuleWave)
      ..moveTo(34, -2)
      ..quadraticBezierTo(46, -8 - antennuleWave, 62, -10 - antennuleWave);
    canvas.drawPath(
      antennulePath,
      Paint()
        ..color = shellEdge.withValues(alpha: alpha * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.65,
    );

    // Long flagellar antennae
    final ant1 = Path();
    ant1.moveTo(33, -3);
    ant1.cubicTo(
      42, -18,
      12, -26 + math.sin(time * 2.8) * 4.0,
      -22, -22 + math.sin(time * 2.8 - 0.8) * 6.0,
    );
    ant1.cubicTo(
      -55, -18 + math.sin(time * 2.8 - 1.6) * 8.0,
      -95, -10 + math.sin(time * 2.8 - 2.4) * 9.0,
      -140, 2 + math.sin(time * 2.8 - 3.2) * 11.0,
    );

    final ant2 = Path();
    ant2.moveTo(32, 1);
    ant2.cubicTo(
      38, 8,
      6, -14 + math.cos(time * 2.5) * 4.0,
      -30, -12 + math.cos(time * 2.5 - 0.7) * 5.0,
    );
    ant2.cubicTo(
      -68, -8 + math.cos(time * 2.5 - 1.5) * 7.0,
      -110, 4 + math.cos(time * 2.5 - 2.2) * 8.0,
      -155, 18 + math.cos(time * 2.5 - 3.0) * 10.0,
    );

    final antennaPaint = Paint()
      ..color = shellEdge.withValues(alpha: alpha * 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;
    canvas.drawPath(ant1, antennaPaint);
    canvas.drawPath(ant2, antennaPaint..strokeWidth = 0.65);

    // 9. Bioluminescent photophores along lateral abdominal margin (for Abyssal Mode)
    if (isAbyss && isNear) {
      final dotPaint = Paint()
        ..color = const Color(0xFF67E8F9).withValues(alpha: alpha * 0.65)
        ..style = PaintingStyle.fill;
      final glowDotPaint = Paint()
        ..color = const Color(0xFF00D2FF).withValues(alpha: alpha * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);

      for (int d = 0; d < 6; d++) {
        final dx = 18.0 - (d * 14.0);
        final dy = 3.0 + (d * 2.1) + (abdominalDip * (d / 6.0));
        canvas.drawCircle(Offset(dx, dy), 1.8, glowDotPaint);
        canvas.drawCircle(Offset(dx, dy), 0.9, dotPaint);
      }
    }
  }

  // --- LAYER 5: BIOLUMINESCENT PLANKTON SPORES (BLOOM & GLOW - Ảnh 2) ---
  void _paintBioluminescentSpores(Canvas canvas, Size size) {
    for (final s in spores) {
      // Gentle Brownian floating drift + slight lateral current drift
      final driftX = ((s.xRatio * size.width) - (time * 1.8) + (math.cos((time * 0.35) + s.pulseFreq) * 18.0)) % size.width;
      final actualX = driftX < 0 ? driftX + size.width : driftX;
      final verticalTravel = (time * s.driftSpeed) + (scrollOffset * 0.16);
      final rawY = ((s.yRatio * size.height) - verticalTravel) % size.height;
      final driftY = rawY < 0 ? rawY + size.height : rawY;

      // Pulsing bioluminescence intensity
      final pulse = (0.50 + (0.50 * math.sin((time * s.pulseFreq) + s.xRatio * 14.0))) * brightness;

      final Color sporeCore;
      final Color sporeHalo;
      if (!isAbyss) {
        // Daytime: sunlit aquatic dust glints
        sporeCore = Colors.white;
        sporeHalo = const Color(0xFFBAE6FD);
      } else {
        switch (s.paletteType) {
          case 0:
            sporeCore = const Color(0xFF00F0FF); // Electric Cyan (Ảnh 2)
            sporeHalo = const Color(0xFF38BDF8);
            break;
          case 1:
            sporeCore = const Color(0xFF34D399); // Sea Emerald / Mint (Ảnh 2)
            sporeHalo = const Color(0xFF6EE7B7);
            break;
          case 2:
            sporeCore = const Color(0xFFF0FDF4); // Diamond Starlight White (Ảnh 2)
            sporeHalo = const Color(0xFF67E8F9);
            break;
          default:
            sporeCore = const Color(0xFF38BDF8); // Ocean Glow Aqua (Ảnh 2)
            sporeHalo = const Color(0xFF0284C7);
            break;
        }
      }

      // Outer soft Bloom Halo (multi-tier glow like Image 2)
      if (isAbyss && s.radius > 1.3) {
        final bloomPaint = Paint()
          ..color = sporeHalo.withValues(alpha: 0.32 * pulse * s.depth)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0 * s.depth);
        canvas.drawCircle(Offset(actualX, driftY), s.radius * 2.5, bloomPaint);
      }

      // Intense Core Spore
      final corePaint = Paint()
        ..color = sporeCore.withValues(alpha: (isAbyss ? 0.90 : 0.40) * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isAbyss ? 1.2 : 0.5);
      canvas.drawCircle(Offset(actualX, driftY), s.radius * (0.85 + (0.25 * pulse)), corePaint);
    }
  }

  // --- LAYER 7: RISING GLASSY BUBBLES WITH SPECULAR REFLECTION (Ảnh 1) ---
  void _paintBubbles(Canvas canvas, Size size) {
    for (int i = 0; i < bubbles.length; i++) {
      final b = bubbles[i];
      final parallaxRise = scrollOffset * (0.22 + (0.26 * b.depth));
      final totalYDist = size.height + 90.0;
      final yTravel = ((time * b.speed) + (b.seed * 35.0) + parallaxRise) % totalYDist;
      final currentY = size.height + 45.0 - yTravel;

      // Sinusoidal wobble horizontal drift
      final wobble = math.sin((time * b.wobbleFreq) + b.seed) * b.wobbleAmp;
      final currentX = ((b.xRatio * size.width) + wobble) % size.width;

      final bubbleAlpha = (isAbyss ? 0.42 : 0.68) * b.depth * brightness;
      final bubbleColor = isAbyss
          ? const Color(0xFF67E8F9).withValues(alpha: bubbleAlpha)
          : const Color(0xFFFFFFFF).withValues(alpha: bubbleAlpha);

      // Glassy bubble outer rim
      final rimPaint = Paint()
        ..color = bubbleColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = b.radius > 4.5 ? 1.3 : 0.9;
      canvas.drawCircle(Offset(currentX, currentY), b.radius, rimPaint);

      // Translucent inner refraction sphere
      final innerPaint = Paint()
        ..color = (isAbyss ? const Color(0xFF00E5FF) : Colors.white).withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), b.radius * 0.92, innerPaint);

      // Crescent light refraction along lower-left rim
      final crescentPaint = Paint()
        ..color = Colors.white.withValues(alpha: (isAbyss ? 0.35 : 0.50) * b.depth * brightness)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(currentX, currentY), radius: b.radius * 0.80),
        2.2, 1.6, false, crescentPaint,
      );

      // Sharp specular glint on upper-right crest (Ảnh 1)
      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: (isAbyss ? 0.90 : 1.0) * b.depth * brightness)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(currentX + (b.radius * 0.38), currentY - (b.radius * 0.38)),
        b.radius * 0.28,
        glintPaint,
      );
    }
  }

  // --- LAYER 8: INTERACTIVE CURSOR WATER WAKE ---
  void _paintInteractiveWaterWake(Canvas canvas, Size size, Offset mouse) {
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isAbyss ? const Color(0xFF00F0FF) : const Color(0xFF38BDF8)).withValues(alpha: 0.18 * brightness),
          (isAbyss ? const Color(0xFF7C3AED) : const Color(0xFF0284C7)).withValues(alpha: 0.05 * brightness),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: mouse, radius: 150))
      ..blendMode = BlendMode.screen;

    canvas.drawCircle(mouse, 150, auraPaint);
  }

  @override
  bool shouldRepaint(covariant _MagicalOceanPainter oldDelegate) => true;
}
