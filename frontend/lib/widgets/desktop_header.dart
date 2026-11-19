import 'package:flutter/material.dart';
import 'underwater_ambient_canvas.dart';

class DesktopHeader extends StatelessWidget {
  const DesktopHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onRefresh,
    required this.accountMenu,
    required this.onlineDeviceCount,
    required this.deviceCount,
    this.activeAlertCount = 0,
    this.onAlertClick,
    this.onSimulate,
    this.isSimulating = false,
    this.lightingMode = OceanLightingMode.abyssal,
    this.onToggleLighting,
  });

  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onRefresh;
  final Widget accountMenu;
  final int onlineDeviceCount;
  final int deviceCount;
  final int activeAlertCount;
  final VoidCallback? onAlertClick;
  final VoidCallback? onSimulate;
  final bool isSimulating;
  final OceanLightingMode lightingMode;
  final VoidCallback? onToggleLighting;

  @override
  Widget build(BuildContext context) {
    final isAbyss = lightingMode == OceanLightingMode.abyssal;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: isAbyss
            ? const Color(0xE6051124) // Deep ocean glassmorphism
            : Colors.white.withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(
            color: isAbyss ? const Color(0x3338BDF8) : const Color(0xFFE8EEF6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Title & breadcrumb
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isAbyss ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isAbyss ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Active Alert Warning Pill
        if (activeAlertCount > 0) ...[
          InkWell(
            onTap: onAlertClick,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: isAbyss ? const Color(0x33EF4444) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAbyss ? const Color(0xFFEF4444) : const Color(0xFFFECACA),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: isAbyss ? 0.25 : 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$activeAlertCount Cảnh báo nước',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAbyss ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Online Device Pill with Beacon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: isAbyss ? const Color(0x2638BDF8) : const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAbyss ? const Color(0x4D38BDF8) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: onlineDeviceCount > 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFF94A3B8),
                  shape: BoxShape.circle,
                  boxShadow: onlineDeviceCount > 0
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$onlineDeviceCount/$deviceCount Máy đo đang bật',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isAbyss ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        if (onSimulate != null) ...[
          FilledButton.icon(
            onPressed: onSimulate,
            icon: Icon(
              isSimulating ? Icons.science_rounded : Icons.science_outlined,
              size: 16,
            ),
            label: Text(isSimulating ? 'Đang thử số liệu' : 'Thử số liệu'),
            style: FilledButton.styleFrom(
              backgroundColor: isSimulating ? const Color(0xFFF59E0B) : const Color(0xFFEEF2FF),
              foregroundColor: isSimulating ? Colors.white : const Color(0xFF4F46E5),
              elevation: 0,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSimulating ? const Color(0xFFD97706) : const Color(0xFFC7D2FE),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Underwater Ocean Lighting Toggle (Abyssal Bioluminescent vs Sunlit Lagoon)
        if (onToggleLighting != null) ...[
          IconButton.filledTonal(
            onPressed: onToggleLighting,
            tooltip: isAbyss
                ? 'Đang bật: Đại dương huyền ảo (Bấm để chuyển sang Nắng mai)'
                : 'Đang bật: Nước trong nắng mai (Bấm để chuyển sang Đại dương huyền ảo)',
            icon: Icon(
              isAbyss ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
              size: 19,
              color: isAbyss ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
            ),
            style: IconButton.styleFrom(
              backgroundColor: isAbyss
                  ? const Color(0xFF0C2449)
                  : const Color(0xFFFEF3C7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isAbyss ? const Color(0x6638BDF8) : const Color(0xFFFDE68A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Tactile Refresh Button
        IconButton.filledTonal(
          onPressed: onRefresh,
          tooltip: 'Làm mới dữ liệu',
          style: IconButton.styleFrom(
            backgroundColor: isAbyss ? const Color(0xFF0C2449) : const Color(0xFFF1F5F9),
            foregroundColor: isAbyss ? const Color(0xFF38BDF8) : const Color(0xFF0F62FE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isAbyss ? const Color(0x6638BDF8) : Colors.transparent,
              ),
            ),
          ),
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF0F62FE)),
                  ),
                )
              : const Icon(Icons.refresh_rounded, size: 20),
        ),

        const SizedBox(width: 8),

        // Account Menu
        accountMenu,
      ],
    ),
  );
  }
}
