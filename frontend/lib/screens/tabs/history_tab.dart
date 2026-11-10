import 'package:flutter/material.dart';
import '../../models/water_models.dart';
import '../../utils/csv_exporter.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_views.dart';
import '../../widgets/history_chart.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({
    super.key,
    required this.sites,
    required this.selectedSite,
    required this.history,
    required this.chartMetric,
    required this.historyRange,
    required this.onCreateSite,
    required this.onSelectSite,
    required this.onSelectMetric,
    required this.onSelectRange,
  });

  final List<MonitoringSite> sites;
  final MonitoringSite? selectedSite;
  final List<WaterMeasurement> history;
  final String chartMetric;
  final Duration historyRange;
  final VoidCallback onCreateSite;
  final ValueChanged<MonitoringSite> onSelectSite;
  final ValueChanged<String> onSelectMetric;
  final ValueChanged<Duration> onSelectRange;

  @override
  Widget build(BuildContext context) {
    if (sites.isEmpty) {
      return EmptyState(
        icon: Icons.history_rounded,
        title: 'Chưa có lịch sử phép đo',
        subtitle:
            'Tạo điểm quan trắc và kết nối thiết bị để bắt đầu lưu dữ liệu.',
        action: FilledButton.icon(
          onPressed: onCreateSite,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Tạo điểm quan trắc'),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 650;
    final rows = [...history]
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      children: [
        // Subheader & System Identity
        if (isMobile) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PONDORA · WATER QUALITY TELEMETRY',
                style: TextStyle(
                  color: Color(0xFF0284C7),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lịch sử dữ liệu quan trắc',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                'Truy xuất chuỗi thời gian và đối chiếu ${rows.length} mẫu đo nước đã ghi nhận.',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  CsvExporter.exportMeasurements(rows, selectedSite!.name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang tải xuống tệp dữ liệu CSV / Excel...'),
                      backgroundColor: Color(0xFF0284C7),
                    ),
                  );
                },
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('Xuất file Excel / CSV'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PONDORA · WATER QUALITY TELEMETRY',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lịch sử dữ liệu quan trắc',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Truy xuất chuỗi thời gian và đối chiếu ${rows.length} mẫu đo nước đã ghi nhận.',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (rows.isNotEmpty)
                FilledButton.icon(
                  onPressed: () {
                    CsvExporter.exportMeasurements(rows, selectedSite!.name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang tải xuống tệp dữ liệu CSV / Excel...'),
                        backgroundColor: Color(0xFF0284C7),
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Xuất file Excel / CSV'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ],

        const SizedBox(height: 18),

        // Site picker
        SitePicker(
          sites: sites,
          selected: selectedSite!,
          onChanged: onSelectSite,
          onAdd: onCreateSite,
        ),

        const SizedBox(height: 16),

        // AI Time-Series Prediction & Anomaly Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEFF6FF), // Soft azure 50
                Color(0xFFF8FAFC),
                Color(0xFFFAF5FF), // Purple 50
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC7D2FE)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.04),
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
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'AI TIME-SERIES FORECASTING · DỰ BÁO CHUỖI THỜI GIAN',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4F46E5),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Động cơ AI phân tích xu hướng biến thiên Oxy hòa tan (DO) và pH theo chu kỳ sinh học ngày/đêm, tự động cảnh báo sớm rủi ro sụt giảm chất lượng nước 6–24 giờ.',
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

        // Interactive Trend Chart
        HistoryChart(
          measurements: history,
          metric: chartMetric,
          range: historyRange,
          onRangeChanged: onSelectRange,
          onMetricChanged: onSelectMetric,
        ),

        const SizedBox(height: 20),

        // Quick Time-Series Analytics Strip
        if (rows.isNotEmpty) ...[
          _buildAnalyticsStrip(rows, chartMetric),
          const SizedBox(height: 20),
        ],

        // Section Title & Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bảng nhật ký mẫu quan trắc',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Các mẫu đo mới nhất được sắp xếp ở đầu danh sách.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${rows.length} mẫu đo',
                style: const TextStyle(
                  color: Color(0xFF0F62FE),
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Master Measurements Table Card
        if (rows.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.query_stats_rounded,
                      size: 40, color: Color(0xFF94A3B8)),
                  SizedBox(height: 12),
                  Text(
                    'Không có phép đo trong khoảng thời gian đã chọn',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dữ liệu sẽ xuất hiện khi thiết bị gửi gói tin quan trắc qua MQTT/HTTP.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
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
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth =
                    constraints.maxWidth < 620 ? 620.0 : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'THỜI GIAN ĐO',
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
                                  'pH',
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
                                  'DO (mg/L)',
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
                                  'ĐỘ ĐỤC (NTU)',
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
                                  'NHIỆT ĐỘ (°C)',
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
                                  'ĐÁNH GIÁ AI',
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

                        // Table Rows (take 50)
                        ...rows.take(50).toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final m = entry.value;
                          final isLast =
                              index == (rows.length > 50 ? 49 : rows.length - 1);
                          final local = m.measuredAt.toLocal();
                          final invalid = m.qualityStatus != 'VALID';
                          final level = levelColor(m.assessmentLevel);

                          final phVal = m.readings['ph'];
                          final doVal = m.readings['dissolvedOxygenMgL'];
                          final turbVal = m.readings['turbidityNtu'];
                          final tempVal = m.readings['temperatureC'];

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    // Time
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.schedule_rounded,
                                              size: 16,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                timeLabel(local),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              Text(
                                                dateLabel(local),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // pH
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        phVal != null ? formatNumber(phVal) : '—',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    // DO
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        doVal != null ? formatNumber(doVal) : '—',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    // Turbidity
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        turbVal != null
                                            ? formatNumber(turbVal)
                                            : '—',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    // Temperature
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        tempVal != null
                                            ? formatNumber(tempVal)
                                            : '—',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    // Assessment Pill
                                    Expanded(
                                      flex: 3,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: invalid
                                                ? const Color(0xFFF1F5F9)
                                                : level.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            invalid
                                                ? '● Mẫu lỗi'
                                                : '● ${levelTitle(m.assessmentLevel)}',
                                            style: TextStyle(
                                              color: invalid
                                                  ? const Color(0xFF64748B)
                                                  : level,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
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
                );
              },
            ),
          ),

        if (rows.length > 50)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              'Đang hiển thị 50 trên ${rows.length} mẫu quan trắc gần nhất.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),

        const SizedBox(height: 20),
        const DisclaimerWidget(),
      ],
    );
  }

  Widget _buildAnalyticsStrip(List<WaterMeasurement> rows, String metric) {
    final vals = rows
        .map((r) => r.readings[metric])
        .whereType<num>()
        .map((n) => n.toDouble())
        .toList();

    if (vals.isEmpty) return const SizedBox.shrink();

    final minV = vals.reduce((a, b) => a < b ? a : b);
    final maxV = vals.reduce((a, b) => a > b ? a : b);
    final avgV = vals.reduce((a, b) => a + b) / vals.length;
    final deltaV = maxV - minV;

    final String unit = metric == 'temperatureC'
        ? '°C'
        : metric == 'dissolvedOxygenMgL'
            ? 'mg/L'
            : metric == 'turbidityNtu'
                ? 'NTU'
                : metric == 'tdsMgL'
                    ? 'mg/L'
                    : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Text(
                'THỐNG KÊ BIẾN THIÊN CHUỖI THỜI GIAN (${metricLabel(metric).toUpperCase()})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  'Cao nhất (Max)',
                  '${formatNumber(maxV)}${unit.isEmpty ? "" : " $unit"}',
                  const Color(0xFFEF4444),
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _statItem(
                  'Thấp nhất (Min)',
                  '${formatNumber(minV)}${unit.isEmpty ? "" : " $unit"}',
                  const Color(0xFF10B981),
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _statItem(
                  'Trung bình (Avg)',
                  '${formatNumber(avgV)}${unit.isEmpty ? "" : " $unit"}',
                  const Color(0xFF0284C7),
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _statItem(
                  'Dao động (Δ)',
                  '±${formatNumber(deltaV)}${unit.isEmpty ? "" : " $unit"}',
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
