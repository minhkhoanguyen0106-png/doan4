import 'package:flutter/material.dart';
import '../../models/water_models.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_views.dart';
import '../../widgets/stat_cards.dart';

class DevicesTab extends StatefulWidget {
  const DevicesTab({
    super.key,
    required this.sites,
    required this.selectedSite,
    required this.devices,
    required this.onCreateSite,
    required this.onCreateDevice,
    required this.onSelectSite,
  });

  final List<MonitoringSite> sites;
  final MonitoringSite? selectedSite;
  final List<IotDevice> devices;
  final VoidCallback onCreateSite;
  final VoidCallback onCreateDevice;
  final ValueChanged<MonitoringSite> onSelectSite;

  @override
  State<DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  String _query = '';
  String _filter = 'ALL'; // 'ALL', 'ONLINE', 'OFFLINE'

  @override
  Widget build(BuildContext context) {
    if (widget.sites.isEmpty) {
      return EmptyState(
        icon: Icons.sensors_outlined,
        title: 'Chưa có điểm quan trắc',
        subtitle: 'Tạo điểm quan trắc trước khi thêm thiết bị.',
        action: FilledButton.icon(
          onPressed: widget.onCreateSite,
          icon: const Icon(Icons.add),
          label: const Text('Tạo điểm quan trắc'),
        ),
      );
    }

    final onlineCount = widget.devices.where((d) => d.online).length;
    final offlineCount = widget.devices.length - onlineCount;

    final query = _query.trim().toLowerCase();
    final filtered = widget.devices.where((d) {
      final matchQuery = query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.deviceCode.toLowerCase().contains(query);
      if (!matchQuery) return false;

      if (_filter == 'ONLINE') return d.online;
      if (_filter == 'OFFLINE') return !d.online;
      return true;
    }).toList();

    return ListView(
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
                  'PONDORA · IOT HARDWARE & SENSORS',
                  style: TextStyle(
                    color: Color(0xFF0284C7),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thiết bị & Cảm biến quan trắc',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Theo dõi ${widget.devices.length} trạm đo vi điều khiển ESP32 và cảm biến vi lưu.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: widget.onCreateDevice,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Thêm thiết bị'),
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

        const SizedBox(height: 18),

        // Site selector
        SitePicker(
          sites: widget.sites,
          selected: widget.selectedSite!,
          onChanged: widget.onSelectSite,
          onAdd: widget.onCreateSite,
        ),

        const SizedBox(height: 16),

        // AI Sensor Telemetry & Anomaly Detection Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEFF6FF), // Soft azure 50
                Color(0xFFF8FAFC),
                Color(0xFFF0FDF4), // Mint 50
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBAE6FD)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.04),
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
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'AI EDGE TELEMETRY · KIỂM ĐỊNH SỐ ĐO CẢM BIẾN TỰ ĐỘNG',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Thuật toán AI tự động lọc nhiễu gói tin ESP32, kiểm tra độ ổn định kết nối và phát hiện trôi lệch cảm biến (sensor drift) theo chuẩn thời gian thực.',
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
            final isWide = constraints.maxWidth > 780;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: AdminStat(
                      label: 'Tổng thiết bị',
                      value: '${widget.devices.length}',
                      icon: Icons.sensors_rounded,
                      color: const Color(0xFF0F62FE),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AdminStat(
                      label: 'Đang trực tuyến',
                      value: '$onlineCount',
                      icon: Icons.wifi_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AdminStat(
                      label: 'Mất kết nối / Offline',
                      value: '$offlineCount',
                      icon: Icons.wifi_off_rounded,
                      color: const Color(0xFFF59E0B),
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
                    label: 'Tổng thiết bị',
                    value: '${widget.devices.length}',
                    icon: Icons.sensors_rounded,
                    color: const Color(0xFF0F62FE),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: AdminStat(
                    label: 'Đang trực tuyến',
                    value: '$onlineCount',
                    icon: Icons.wifi_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth,
                  child: AdminStat(
                    label: 'Mất kết nối / Offline',
                    value: '$offlineCount',
                    icon: Icons.wifi_off_rounded,
                    color: const Color(0xFFF59E0B),
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
          child: Row(
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
                    hintText: 'Tìm kiếm theo tên thiết bị hoặc mã ESP32...',
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
              _filterChip('Tất cả ${widget.devices.length}', 'ALL'),
              const SizedBox(width: 6),
              _filterChip('Trực tuyến $onlineCount', 'ONLINE'),
              const SizedBox(width: 6),
              _filterChip('Offline $offlineCount', 'OFFLINE'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Master Device Table Card
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
                  const Icon(Icons.sensors_off_rounded,
                      size: 40, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(
                    widget.devices.isEmpty
                        ? 'Chưa gắn thiết bị nào cho ao này'
                        : 'Không tìm thấy thiết bị phù hợp',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.devices.isEmpty
                        ? 'Đăng ký trạm đo ESP32 để bắt đầu nhận luồng dữ liệu quan trắc.'
                        : 'Thử kiểm tra lại từ khóa tìm kiếm hoặc bộ lọc.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  if (widget.devices.isEmpty) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: widget.onCreateDevice,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Thêm thiết bị mới'),
                    ),
                  ],
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
                // Table Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'THIẾT BỊ / MÃ ESP32',
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
                          'GIAO THỨC',
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
                          'TRẠNG THÁI',
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
                          'DỮ LIỆU GẦN NHẤT',
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
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // Table Rows
                ...filtered.asMap().entries.map((entry) {
                  final index = entry.key;
                  final device = entry.value;
                  final isLast = index == filtered.length - 1;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Device name & code
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF2FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.sensors_rounded,
                                      color: Color(0xFF0F62FE),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          device.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          device.deviceCode,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Protocol Badge
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'WiFi · MQTT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Status Pill
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: device.status != 'ACTIVE'
                                        ? const Color(0xFFF1F5F9)
                                        : device.online
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    device.status != 'ACTIVE'
                                        ? '● Đã tắt'
                                        : device.online
                                            ? '● Đang trực tuyến'
                                            : '● Mất kết nối',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: device.status != 'ACTIVE'
                                          ? const Color(0xFF64748B)
                                          : device.online
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Last seen timestamp
                            Expanded(
                              flex: 3,
                              child: Text(
                                device.lastSeenAt == null
                                    ? 'Chưa gửi dữ liệu'
                                    : 'Nhận ${timeLabel(device.lastSeenAt!.toLocal())}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
