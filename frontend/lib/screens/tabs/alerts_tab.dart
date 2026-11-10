import 'package:flutter/material.dart';
import '../../dialogs/alert_detail_dialog.dart';
import '../../models/water_models.dart';
import '../../services/alarm_sound_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_views.dart';
import '../../widgets/stat_cards.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({
    super.key,
    required this.sites,
    required this.selectedSite,
    required this.alerts,
    required this.onRefresh,
    required this.onSelectSite,
    required this.onCreateSite,
    required this.onResolveAlert,
  });

  final List<MonitoringSite> sites;
  final MonitoringSite? selectedSite;
  final List<WaterAlert> alerts;
  final Future<void> Function() onRefresh;
  final ValueChanged<MonitoringSite> onSelectSite;
  final VoidCallback onCreateSite;
  final ValueChanged<WaterAlert> onResolveAlert;

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  String _query = '';
  String _filter = 'ACTIVE'; // 'ACTIVE', 'ALL', 'CRITICAL', 'RESOLVED'

  @override
  Widget build(BuildContext context) {
    if (widget.sites.isEmpty) {
      return EmptyState(
        icon: Icons.warning_amber_rounded,
        title: 'Chưa có điểm quan trắc',
        subtitle: 'Tạo điểm quan trắc để theo dõi các cảnh báo tự động.',
        action: FilledButton.icon(
          onPressed: widget.onCreateSite,
          icon: const Icon(Icons.add),
          label: const Text('Tạo điểm đo'),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 700;
    final activeAlerts = widget.alerts.where((a) => a.isActive).toList();
    final criticalCount = activeAlerts.where((a) => a.isCritical).length;
    final highCount = activeAlerts.where((a) => a.isHigh).length;
    final resolvedCount = widget.alerts.length - activeAlerts.length;

    final query = _query.trim().toLowerCase();
    final filtered = widget.alerts.where((a) {
      final matchQuery = query.isEmpty ||
          a.title.toLowerCase().contains(query) ||
          a.message.toLowerCase().contains(query);
      if (!matchQuery) return false;

      if (_filter == 'ACTIVE') return a.isActive;
      if (_filter == 'CRITICAL') return a.isActive && a.isCritical;
      if (_filter == 'RESOLVED') return !a.isActive;
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        children: [
          // Subheader & System Identity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PONDORA · EARLY WARNING SYSTEM',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trung tâm cảnh báo tự động',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Phát hiện tự động chỉ số vượt ngưỡng hoặc thiết bị mất kết nối thời gian thực.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () {
                      setState(() {
                        AlarmSoundService.soundEnabled = !AlarmSoundService.soundEnabled;
                      });
                      if (AlarmSoundService.soundEnabled) {
                        AlarmSoundService.playAlarm(severity: 'HIGH');
                      }
                    },
                    icon: Icon(
                      AlarmSoundService.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      size: 16,
                      color: AlarmSoundService.soundEnabled ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                    ),
                    label: Text(
                      AlarmSoundService.soundEnabled ? 'Còi cảnh báo: BẬT' : 'Còi cảnh báo: TẮT',
                      style: TextStyle(
                        color: AlarmSoundService.soundEnabled ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AlarmSoundService.soundEnabled ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: widget.onRefresh,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Làm mới'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Site picker
          SitePicker(
            sites: widget.sites,
            selected: widget.selectedSite!,
            onChanged: widget.onSelectSite,
            onAdd: widget.onCreateSite,
          ),

          const SizedBox(height: 16),

          // AI Early Warning & Root-Cause Diagnosis Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFEF2F2), // Red 50
                  Color(0xFFF8FAFC),
                  Color(0xFFFFFBEB), // Amber 50
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.crisis_alert_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AI EARLY WARNING · HỆ THỐNG CẢNH BÁO SỚM & CHẨN ĐOÁN RỦI RO',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626),
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Thuật toán AI tự động phân loại mức độ rủi ro (Critical / High / Watch), phân tích tương quan đa tham số để chẩn đoán nguyên nhân và đề xuất xử lý kịp thời.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Stat Cards Grid (Equal Width, Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 860;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: AdminStat(
                        label: 'Cảnh báo đang mở',
                        value: '${activeAlerts.length}',
                        icon: Icons.notifications_active_rounded,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AdminStat(
                        label: 'Mức nguy cấp (Critical)',
                        value: '$criticalCount',
                        icon: Icons.error_outline_rounded,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AdminStat(
                        label: 'Cảnh báo cao (High)',
                        value: '$highCount',
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AdminStat(
                        label: 'Đã giải quyết',
                        value: '$resolvedCount',
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                );
              }
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: AdminStat(
                      label: 'Cảnh báo đang mở',
                      value: '${activeAlerts.length}',
                      icon: Icons.notifications_active_rounded,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: AdminStat(
                      label: 'Mức nguy cấp',
                      value: '$criticalCount',
                      icon: Icons.error_outline_rounded,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: AdminStat(
                      label: 'Cảnh báo cao',
                      value: '$highCount',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: AdminStat(
                      label: 'Đã giải quyết',
                      value: '$resolvedCount',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Tìm kiếm sự kiện hoặc nội dung...',
                                hintStyle: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.normal,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 6),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 10, color: Color(0xFFF1F5F9)),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('Đang mở ${activeAlerts.length}', 'ACTIVE'),
                            const SizedBox(width: 6),
                            _filterChip('Tất cả ${widget.alerts.length}', 'ALL'),
                            const SizedBox(width: 6),
                            _filterChip('Nguy cấp $criticalCount', 'CRITICAL'),
                            const SizedBox(width: 6),
                            _filterChip('Đã xử lý $resolvedCount', 'RESOLVED'),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm theo sự kiện hoặc nội dung cảnh báo...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.normal,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _filterChip('Đang mở ${activeAlerts.length}', 'ACTIVE'),
                      const SizedBox(width: 6),
                      _filterChip('Tất cả ${widget.alerts.length}', 'ALL'),
                      const SizedBox(width: 6),
                      _filterChip('Nguy cấp $criticalCount', 'CRITICAL'),
                      const SizedBox(width: 6),
                      _filterChip('Đã xử lý $resolvedCount', 'RESOLVED'),
                    ],
                  ),
          ),

          const SizedBox(height: 20),

          // Master Alerts Table Card
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 48,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _filter == 'ACTIVE'
                          ? 'Tuyệt vời! Không có cảnh báo nào đang mở.'
                          : 'Không có dữ liệu cảnh báo.',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hệ thống AI sẽ tự động kích hoạt cảnh báo khi phát hiện nước ô nhiễm hoặc mất kết nối.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header (Desktop only)
                  if (!isMobile)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 5,
                            child: Text(
                              'MỨC ĐỘ & SỰ KIỆN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'THỜI ĐIỂM',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'TRẠNG THÁI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'THAO TÁC',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!isMobile)
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // Alert Items (Responsive: Mobile card vs Desktop row)
                  ...filtered.asMap().entries.map((entry) {
                    final index = entry.key;
                    final alert = entry.value;
                    final isLast = index == filtered.length - 1;
                    final sevColor = levelColor(alert.severity);

                    return Column(
                      children: [
                        InkWell(
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => AlertDetailDialog(
                              alert: alert,
                              onResolve: () => widget.onResolveAlert(alert),
                            ),
                          ),
                          child: isMobile
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: sevColor
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              levelTitle(alert.severity),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: sevColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${timeLabel(alert.triggeredAt.toLocal())} • ${dateLabel(alert.triggeredAt.toLocal())}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: alert.isActive
                                                  ? const Color(0xFFFEF2F2)
                                                  : const Color(0xFFECFDF5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              alert.isActive
                                                  ? '● Đang mở'
                                                  : '● Đã xử lý',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: alert.isActive
                                                  ? const Color(0xFFDC2626)
                                                  : const Color(0xFF059669),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        alert.title,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        alert.message,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          height: 1.35,
                                        ),
                                      ),
                                      if (alert.isActive) ...[
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                widget.onResolveAlert(alert),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 6,
                                              ),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              side: const BorderSide(
                                                color: Color(0xFFCBD5E1),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Đã xử lý',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // Event level & title
                                      Expanded(
                                        flex: 5,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: sevColor
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                alert.isCritical
                                                    ? Icons.error_outline_rounded
                                                    : Icons.warning_amber_rounded,
                                                color: sevColor,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                          horizontal: 7,
                                                          vertical: 3,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: sevColor
                                                              .withValues(
                                                                  alpha: 0.12),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  6),
                                                        ),
                                                        child: Text(
                                                          levelTitle(
                                                              alert.severity),
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: sevColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          alert.title,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Color(0xFF0F172A),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    alert.message,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Timestamp
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dateLabel(
                                                  alert.triggeredAt.toLocal()),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              timeLabel(
                                                  alert.triggeredAt.toLocal()),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Status Pill
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: alert.isActive
                                                  ? const Color(0xFFFEF2F2)
                                                  : const Color(0xFFECFDF5),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              alert.isActive
                                                  ? '● Đang mở'
                                                  : '● Đã xử lý',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: alert.isActive
                                                    ? const Color(0xFFDC2626)
                                                    : const Color(0xFF059669),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Actions
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: alert.isActive
                                              ? OutlinedButton(
                                                  onPressed: () => widget
                                                      .onResolveAlert(alert),
                                                  style: OutlinedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                    side: const BorderSide(
                                                      color: Color(0xFFCBD5E1),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Đã xử lý',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                )
                                              : const Text(
                                                  'Đã hoàn tất',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF94A3B8),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ],
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0F62FE) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
