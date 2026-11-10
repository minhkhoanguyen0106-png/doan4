import 'package:flutter/material.dart';
import '../models/water_models.dart';

class WaterSidebar extends StatelessWidget {
  const WaterSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.isAdmin,
    required this.account,
    required this.onCreateSite,
    required this.onLogout,
    this.activeAlertCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isAdmin;
  final AccountUser account;
  final VoidCallback onCreateSite;
  final VoidCallback onLogout;
  final int activeAlertCount;

  @override
  Widget build(BuildContext context) => Container(
    width: 260,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D172A), // Soft dark navy at top
          Color(0xFF090E1B), // Deep obsidian
          Color(0xFF060912), // Deepest midnight base
          Color(0xFF0A1428), // Subtle oceanic blue bleed at bottom
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
      ),
      border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        // 1. Ambient Loang Màu (Subtle Glowing Mesh Lights)
        // Top-left cyan/sky glow behind brand logo
        Positioned(
          top: -40,
          left: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0284C7).withValues(alpha: 0.22),
                  const Color(0xFF00D2FF).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // Right-edge electric blue ambient glow near nav items
        Positioned(
          top: 200,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0F62FE).withValues(alpha: 0.16),
                  const Color(0xFF38BDF8).withValues(alpha: 0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // Bottom-left cyan ambient glow near profile card
        Positioned(
          bottom: 10,
          left: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),

        // 2. Foreground Sidebar Content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 20, 26),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F62FE), Color(0xFF00D2FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2FF).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PONDORA',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'SMART AQUACULTURE',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 9,
                              letterSpacing: 0.9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Section header
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 12, 10),
              child: Text(
                'KHÔNG GIAN LÀM VIỆC',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Nav items
            SidebarItem(
              icon: Icons.grid_view_rounded,
              label: 'Tổng quan hệ thống',
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            SidebarItem(
              icon: Icons.menu_book_rounded,
              label: 'Nhật ký ao tôm',
              selected: selectedIndex == 6,
              onTap: () => onSelect(6),
            ),
            SidebarItem(
              icon: Icons.pin_drop_rounded,
              label: 'Điểm quan trắc',
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
            SidebarItem(
              icon: Icons.sensors_rounded,
              label: 'Thiết bị cảm biến',
              selected: selectedIndex == 2,
              onTap: () => onSelect(2),
            ),
            SidebarItem(
              icon: Icons.show_chart_rounded,
              label: 'Lịch sử & Xu hướng',
              selected: selectedIndex == 3,
              onTap: () => onSelect(3),
            ),
            SidebarItem(
              icon: Icons.notifications_active_rounded,
              label: 'Cảnh báo & Rủi ro',
              selected: selectedIndex == 4,
              badgeCount: activeAlertCount,
              onTap: () => onSelect(4),
            ),
            if (isAdmin)
              SidebarItem(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Quản trị hệ thống',
                selected: selectedIndex == 5,
                onTap: () => onSelect(5),
              ),

            const SizedBox(height: 18),

            // Quick add card (Dark glass styled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF131D33).withValues(alpha: 0.85),
                      const Color(0xFF0D1526).withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2D4A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F62FE).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_location_alt_rounded,
                            color: Color(0xFF38BDF8),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Text(
                          'Thêm điểm mới',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Thiết lập điểm quan trắc mới và tạo mã nạp cho ESP32.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: onCreateSite,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Tạo điểm đo'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.8),
                          foregroundColor: const Color(0xFF38BDF8),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // User profile footer (Dark glass styled)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF131D33).withValues(alpha: 0.9),
                      const Color(0xFF0D1526).withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2D4A)),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: isAdmin
                              ? const Color(0xFF2E1065)
                              : const Color(0xFF0C4A6E),
                          child: Text(
                            account.displayName.isNotEmpty
                                ? account.displayName.substring(0, 1).toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: isAdmin
                                  ? const Color(0xFFC084FC)
                                  : const Color(0xFF38BDF8),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF111827), width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            account.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isAdmin ? 'Quản trị viên' : 'Người vận hành',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Tooltip(
                        message: 'Đăng xuất',
                        child: InkWell(
                          onTap: onLogout,
                          borderRadius: BorderRadius.circular(8),
                          hoverColor: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.logout_rounded,
                              size: 17,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      const Color(0xFF0F62FE).withValues(alpha: 0.25),
                      const Color(0xFF1E293B).withValues(alpha: 0.75),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.45)
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F62FE).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else if (selected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
