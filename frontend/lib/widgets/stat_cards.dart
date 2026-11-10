import 'package:flutter/material.dart';
import '../models/water_models.dart';
import '../utils/formatters.dart';

class AssessmentCard extends StatelessWidget {
  const AssessmentCard({
    super.key,
    required this.level,
    required this.sampleCount,
    required this.deviceCount,
    required this.day,
    required this.onPickDay,
    this.species,
    this.onViewActionPlan,
  });

  final String level;
  final int sampleCount;
  final int deviceCount;
  final DateTime day;
  final VoidCallback onPickDay;
  final AquacultureSpecies? species;
  final VoidCallback? onViewActionPlan;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final statusColor = levelColor(level);
    final isPending = level == 'INSUFFICIENT_DATA' || level.isEmpty || sampleCount == 0;
    final accentColor = isPending ? const Color(0xFF0F62FE) : statusColor;
    final displayTitle = isPending
        ? 'Hệ thống AI sẵn sàng giám sát & phân tích'
        : levelTitle(level);
    final displayDesc = isPending
        ? 'Mô hình AI PONDORA v2.4 đã sẵn sàng bộ trọng số tiêu chuẩn QCVN 02-19:2014/BNNPTNT. Tự động tính toán WQI và dự báo rủi ro ngay khi có dữ liệu cảm biến.'
        : _levelDescription(level);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFC),
            accentColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glowing Water Halo watermark in top-right corner
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.15),
                    accentColor.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with date picker & AI Model Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F62FE),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isMobile
                                    ? 'AI PHÂN TÍCH CHẤT LƯỢNG NƯỚC'
                                    : 'AI TỔNG HỢP & PHÂN TÍCH CHẤT LƯỢNG NƯỚC',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF0F62FE),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onPickDay,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Color(0xFF0284C7), size: 14),
                            const SizedBox(width: 5),
                            Text(
                              dateLabel(day),
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Main assessment status
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isPending ? Icons.auto_awesome_rounded : levelIcon(level),
                        color: accentColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayDesc,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12.5,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isPending ? const Color(0xFF10B981) : accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isPending ? const Color(0xFF10B981) : accentColor).withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // AI Standard Target Thresholds
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _aiParamPill('pH tối ưu', '${species?.optimalPhMin ?? 6.5} – ${species?.optimalPhMax ?? 8.5}', const Color(0xFF0284C7))),
                                Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                                Expanded(child: _aiParamPill('Oxy (DO)', '≥ ${species?.optimalDoMin ?? 4.0} mg/L', const Color(0xFF10B981))),
                              ],
                            ),
                            const Divider(height: 12, color: Color(0xFFF1F5F9)),
                            Row(
                              children: [
                                Expanded(child: _aiParamPill('Độ đục', '≤ ${species?.maxTurbidity ?? 25.0} NTU', const Color(0xFFF59E0B))),
                                Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                                Expanded(child: _aiParamPill('Nhiệt độ ao', '${species?.optimalTempMin ?? 26.0} – ${species?.optimalTempMax ?? 31.5} °C', const Color(0xFFEF4444))),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _aiParamPill('pH tối ưu', '${species?.optimalPhMin ?? 6.5} – ${species?.optimalPhMax ?? 8.5}', const Color(0xFF0284C7)),
                            Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                            _aiParamPill('Oxy hòa tan (DO)', '≥ ${species?.optimalDoMin ?? 4.0} mg/L', const Color(0xFF10B981)),
                            Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                            _aiParamPill('Độ đục tối đa', '≤ ${species?.maxTurbidity ?? 25.0} NTU', const Color(0xFFF59E0B)),
                            Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                            _aiParamPill('Nhiệt độ ao', '${species?.optimalTempMin ?? 26.0} – ${species?.optimalTempMax ?? 31.5} °C', const Color(0xFFEF4444)),
                          ],
                        ),
                ),

                if (onViewActionPlan != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accentColor.withValues(alpha: 0.22)),
                    ),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.psychology_rounded, color: accentColor, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Khuyến nghị xử lý (${species?.name ?? "Mô hình nuôi"})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Xem phác đồ sục khí, liều lượng vôi, rỉ đường & chế phẩm sinh học',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: onViewActionPlan,
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                                  label: const Text('Xem phác đồ AI'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.psychology_rounded, color: accentColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Khuyến nghị kỹ thuật xử lý nước (${species?.name ?? "Mô hình nuôi"})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      'Xem phác đồ sục khí, liều lượng vôi, rỉ đường & chế phẩm sinh học',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: onViewActionPlan,
                                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                                label: const Text('Phác đồ AI'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],

                const SizedBox(height: 14),

                // Stat counters at bottom
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: HeroStat(
                          icon: Icons.query_stats_rounded,
                          value: '$sampleCount',
                          label: isMobile ? 'mẫu đo hợp lệ' : 'mẫu quan trắc hợp lệ',
                          accent: const Color(0xFF0284C7),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        color: const Color(0xFFE2E8F0),
                      ),
                      Expanded(
                        child: HeroStat(
                          icon: Icons.hub_rounded,
                          value: '$deviceCount',
                          label: isMobile ? 'thiết bị' : 'thiết bị kết nối',
                          accent: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiParamPill(String label, String value, Color color) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );

  String _levelDescription(String lvl) {
    switch (lvl) {
      case 'WATCH':
        return 'Cần lưu ý: một số chỉ số đang tiến gần ngưỡng cảnh báo.';
      case 'HIGH':
        return 'Cảnh báo: phát hiện chỉ số lệch ngưỡng tiêu chuẩn.';
      case 'CRITICAL':
        return 'Nguy cấp: nguồn nước đang ô nhiễm nghiêm trọng, cần xử lý ngay.';
      case 'NORMAL':
        return 'Chất lượng nước ổn định, nằm hoàn toàn trong phạm vi an toàn.';
      default:
        return 'Chưa đủ dữ liệu mẫu để tính toán điểm đánh giá tổng hợp ngày.';
    }
  }
}

class HeroStat extends StatelessWidget {
  const HeroStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accent = const Color(0xFF0284C7),
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: accent, size: 15),
      ),
      const SizedBox(width: 6),
      Text(
        value,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w900,
          fontSize: 14.5,
        ),
      ),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

class AdminStat extends StatelessWidget {
  const AdminStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.stat,
    this.accent = const Color(0xFF0F62FE),
    this.selected = false,
    this.onTap,
    this.safeMin,
    this.safeMax,
    this.safeLabel,
  });

  final String label;
  final num? value;
  final String unit;
  final IconData icon;
  final MetricStats? stat;
  final Color accent;
  final bool selected;
  final VoidCallback? onTap;
  final double? safeMin;
  final double? safeMax;
  final String? safeLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? accent : const Color(0xFFE2E8F0),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFFF8FAFD),
        child: Container(
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.05),
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: Icon, Label, and Status dot
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: value != null ? accent : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Value & Unit row
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value == null ? '—' : formatNumber(value!),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (unit.isNotEmpty && value != null) ...[
                    const SizedBox(width: 5),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),

              // Visual Range Mini Gauge
              if (value != null && safeMin != null && safeMax != null) ...[
                const SizedBox(height: 6),
                _buildGaugeBar(value!.toDouble(), safeMin!, safeMax!),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        safeLabel ?? 'Tối ưu: $safeMin – $safeMax',
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildStatusChip(value!.toDouble(), safeMin!, safeMax!),
                  ],
                ),
                const SizedBox(height: 4),
              ] else
                const SizedBox(height: 8),

              // Stat range footer
              if (stat != null && stat!.count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'TB ${formatNumber(stat!.average!)} · Min ${formatNumber(stat!.min!)} - Max ${formatNumber(stat!.max!)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                Text(
                  value != null ? 'Chưa đủ mẫu trung bình ngày' : 'Chưa có dữ liệu cảm biến',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGaugeBar(double val, double sMin, double sMax) {
    final double lower = sMin * 0.7;
    final double upper = sMax * 1.3;
    final double range = upper - lower > 0 ? upper - lower : 1.0;

    final double normVal = ((val - lower) / range).clamp(0.0, 1.0);
    final double normSafeStart = ((sMin - lower) / range).clamp(0.0, 1.0);
    final double normSafeEnd = ((sMax - lower) / range).clamp(0.0, 1.0);

    final bool isSafe = val >= sMin && val <= sMax;
    final Color pinColor = isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return LayoutBuilder(
      builder: (context, box) {
        final totalWidth = box.maxWidth;
        final safeLeft = normSafeStart * totalWidth;
        final safeWidth = (normSafeEnd - normSafeStart) * totalWidth;
        final pinLeft = (normVal * (totalWidth - 8)).clamp(0.0, totalWidth - 8);

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 5,
              width: totalWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Positioned(
              left: safeLeft,
              width: safeWidth > 0 ? safeWidth : 10,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Positioned(
              left: pinLeft,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: pinColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: pinColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(double val, double sMin, double sMax) {
    final bool isSafe = val >= sMin && val <= sMax;
    final bool isHigh = val > sMax;
    final String text = isSafe ? 'TỐI ƯU' : (isHigh ? 'VƯỢT NGƯỠNG' : 'DƯỚI CHUẨN');
    final Color col = isSafe
        ? const Color(0xFF10B981)
        : (isHigh ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: col),
      ),
    );
  }
}

class ReadingPill extends StatelessWidget {
  const ReadingPill({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final num? value;
  final String unit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: value == null
                ? '—'
                : '${formatNumber(value!)}${unit.isEmpty ? '' : ' $unit'}',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}
