import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    padding: const EdgeInsets.symmetric(horizontal: 28),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE8EEF6), width: 1)),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
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
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
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
                    '$activeAlertCount Cảnh báo phát hiện',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB91C1C),
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
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                '$onlineDeviceCount/$deviceCount Thiết bị trực tuyến',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        if (onSimulate != null) ...[
          OutlinedButton.icon(
            onPressed: onSimulate,
            icon: const Icon(Icons.science_outlined, size: 16),
            label: const Text('Mô phỏng AI & Cảm biến'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
              side: const BorderSide(color: Color(0xFFC7D2FE)),
              backgroundColor: const Color(0xFFEEF2FF),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF0F62FE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
