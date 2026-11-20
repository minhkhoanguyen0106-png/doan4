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
    this.isAbyss = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isAdmin;
  final AccountUser account;
  final VoidCallback onCreateSite;
  final VoidCallback onLogout;
  final int activeAlertCount;
  final bool isAbyss;

  @override
  Widget build(BuildContext context) {
    // ĐỒNG BỘ MÀU SẮC ĐẠI DƯƠNG:
    // Khi ban đêm (isAbyss = true) -> Sidebar tối màu huyền bí, sâu thẳm
    // Khi ban ngày (isAbyss = false) -> Sidebar sáng màu ngọc lam tươi mát
    // Inverse dashboard contrast rule:
    // Sunlit / Daytime mode (!isAbyss) -> Dashboard sidebar is DARK (isSidebarLight = false)
    // Abyssal / Nighttime mode (isAbyss) -> Dashboard sidebar is LIGHT (isSidebarLight = true)
    final bool isSidebarLight = isAbyss;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isSidebarLight ? Colors.white : const Color(0xFF081226),
        gradient: isSidebarLight
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF8FAFC),
                  Color(0xFFF1F5F9),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D172A),
                  Color(0xFF090E1B),
                  Color(0xFF060912),
                  Color(0xFF0A1428),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
        border: Border(
          right: BorderSide(
            color: isSidebarLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isSidebarLight ? const Color(0xFF0F172A) : Colors.black).withValues(alpha: isSidebarLight ? 0.06 : 0.40),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ambient Mesh Glows
          if (!isSidebarLight) ...[
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
          ],

          // Foreground Content: Pinned Header, Scrollable Middle, Pinned Footer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pinned Brand Header
              InkWell(
                onTap: () => onSelect(7),
                borderRadius: BorderRadius.circular(16),
                splashColor: const Color(0xFF00D2FF).withValues(alpha: 0.1),
                hoverColor: isSidebarLight ? const Color(0xFFF1F5F9) : Colors.white.withValues(alpha: 0.04),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F62FE), Color(0xFF00D2FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D2FF).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PONDORA',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                              fontSize: 16.5,
                              color: isSidebarLight ? const Color(0xFF0F172A) : Colors.white,
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
                              Text(
                                'NUÔI TÔM THÔNG MINH',
                                style: TextStyle(
                                  color: isSidebarLight ? const Color(0xFF0284C7) : const Color(0xFF38BDF8),
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
              ),

              // 2. Middle Scrollable Nav List & Quick Add Card (Tránh bị cắt cụt phía dưới)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 12, 8),
                        child: Text(
                          'CHỨC NĂNG',
                          style: TextStyle(
                            color: isSidebarLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      SidebarItem(
                        icon: Icons.home_rounded,
                        label: 'Trang chủ',
                        selected: selectedIndex == 7,
                        isSidebarLight: isSidebarLight,
                        onTap: () => onSelect(7),
                      ),
                      SidebarItem(
                        icon: Icons.grid_view_rounded,
                        label: 'Xem nước ao',
                        selected: selectedIndex == 0,
                        isSidebarLight: isSidebarLight,
                        onTap: () => onSelect(0),
                      ),
                      SidebarItem(
                        icon: Icons.menu_book_rounded,
                        label: 'Sổ nhật ký ao',
                        selected: selectedIndex == 6,
                        isSidebarLight: isSidebarLight,
                        onTap: () => onSelect(6),
                      ),
                      SidebarItem(
                        icon: Icons.pin_drop_rounded,
                        label: 'Danh sách ao đo',
                        selected: selectedIndex == 1,
                        isSidebarLight: isSidebarLight,
                        onTap: () => onSelect(1),
                      ),
                      SidebarItem(
                        icon: Icons.sensors_rounded,
                        label: 'Thiết bị đo',
                        selected: selectedIndex == 2,
                        isSidebarLight: isSidebarLight,
                        onTap: () => onSelect(2),
                      ),
                      SidebarItem(
                        icon: Icons.show_chart_rounded,
                        label: 'Lịch sử đo nước',
                        selected: selectedIndex == 3,
                        isSidebarLight: isSidebarLight,
                        onTap: () => onSelect(3),
                      ),
                      SidebarItem(
                        icon: Icons.notifications_active_rounded,
                        label: 'Cảnh báo nước',
                        selected: selectedIndex == 4,
                        isSidebarLight: isSidebarLight,
                        badgeCount: activeAlertCount,
                        onTap: () => onSelect(4),
                      ),
                      if (isAdmin)
                        SidebarItem(
                          icon: Icons.admin_panel_settings_rounded,
                          label: 'Quản lý tài khoản',
                          selected: selectedIndex == 5,
                          isSidebarLight: isSidebarLight,
                          onTap: () => onSelect(5),
                        ),

                      const SizedBox(height: 14),

                      // Quick Add Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSidebarLight
                                ? const Color(0xFFF0F9FF)
                                : const Color(0xFF131D33).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSidebarLight
                                  ? const Color(0xFFBAE6FD)
                                  : const Color(0xFF1E2D4A),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F62FE).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add_location_alt_rounded,
                                      color: Color(0xFF0284C7),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thêm ao mới',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                      color: isSidebarLight ? const Color(0xFF0F172A) : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Tạo thêm ao nuôi để gắn máy đo và theo dõi nước.',
                                style: TextStyle(
                                  color: isSidebarLight ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                  fontSize: 10.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonalIcon(
                                  onPressed: onCreateSite,
                                  icon: const Icon(Icons.add_rounded, size: 15),
                                  label: const Text('Thêm ao'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isSidebarLight
                                        ? const Color(0xFFE0F2FE)
                                        : const Color(0xFF1E293B).withValues(alpha: 0.8),
                                    foregroundColor: const Color(0xFF0284C7),
                                    elevation: 0,
                                    side: BorderSide(
                                      color: isSidebarLight
                                          ? const Color(0xFFBAE6FD)
                                          : const Color(0xFF334155),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    textStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
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
                ),
              ),

              // 3. Pinned Bottom User Profile with Safe Area
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSidebarLight
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF131D33).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSidebarLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E2D4A),
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isAdmin
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFF0284C7),
                              child: Text(
                                account.displayName.isNotEmpty
                                    ? account.displayName.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
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
                                  border: Border.all(
                                    color: isSidebarLight ? Colors.white : const Color(0xFF111827),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                account.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: isSidebarLight ? const Color(0xFF0F172A) : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                isAdmin ? 'Quản trị viên' : 'Người vận hành',
                                style: TextStyle(
                                  color: isSidebarLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  fontSize: 10.5,
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
                              hoverColor: const Color(0xFF7F1D1D).withValues(alpha: 0.15),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.logout_rounded,
                                  size: 16,
                                  color: isSidebarLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
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
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    this.isSidebarLight = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isSidebarLight;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        hoverColor: isSidebarLight
            ? const Color(0xFFF1F5F9)
            : const Color(0xFF1E293B).withValues(alpha: 0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9.5),
          decoration: BoxDecoration(
            color: selected
                ? (isSidebarLight
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF0F62FE).withValues(alpha: 0.28))
                : null,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected
                  ? (isSidebarLight
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF38BDF8).withValues(alpha: 0.5))
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: (isSidebarLight ? const Color(0xFF0284C7) : const Color(0xFF0F62FE))
                          .withValues(alpha: isSidebarLight ? 0.28 : 0.2),
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
                size: 19,
                color: selected
                    ? (isSidebarLight ? Colors.white : const Color(0xFF38BDF8))
                    : (isSidebarLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : (isSidebarLight ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
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
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else if (selected && !isSidebarLight)
                Container(
                  width: 5,
                  height: 5,
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
