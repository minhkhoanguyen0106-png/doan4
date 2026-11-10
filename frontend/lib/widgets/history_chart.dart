import 'package:flutter/material.dart';
import '../models/water_models.dart';
import '../utils/formatters.dart';

class HistoryChart extends StatelessWidget {
  const HistoryChart({
    super.key,
    required this.measurements,
    required this.metric,
    required this.range,
    required this.onRangeChanged,
    required this.onMetricChanged,
  });
  final List<WaterMeasurement> measurements;
  final String metric;
  final Duration range;
  final ValueChanged<Duration> onRangeChanged;
  final ValueChanged<String> onMetricChanged;

  static const _metrics = <String, ({
    String label,
    String unit,
    IconData icon,
    Color color,
    Color bg,
  })>{
    'ph': (
      label: 'Độ pH',
      unit: '',
      icon: Icons.science_outlined,
      color: Color(0xFF7C3AED),
      bg: Color(0xFFF5F3FF),
    ),
    'dissolvedOxygenMgL': (
      label: 'Oxy hòa tan (DO)',
      unit: 'mg/L',
      icon: Icons.air_rounded,
      color: Color(0xFF059669),
      bg: Color(0xFFECFDF5),
    ),
    'turbidityNtu': (
      label: 'Độ đục',
      unit: 'NTU',
      icon: Icons.blur_on_rounded,
      color: Color(0xFFD97706),
      bg: Color(0xFFFFFBEB),
    ),
    'temperatureC': (
      label: 'Nhiệt độ nước',
      unit: '°C',
      icon: Icons.thermostat_rounded,
      color: Color(0xFFE11D48),
      bg: Color(0xFFFFF1F2),
    ),
    'tdsMgL': (
      label: 'Tổng khoáng TDS',
      unit: 'mg/L',
      icon: Icons.grain_rounded,
      color: Color(0xFF0284C7),
      bg: Color(0xFFF0F9FF),
    ),
    'nh3Pct': (
      label: 'Khí độc NH3 (Soft Sensor)',
      unit: '%',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFDC2626),
      bg: Color(0xFFFEF2F2),
    ),
    'salinityPpt': (
      label: 'Độ mặn ao nuôi',
      unit: '‰',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF0D9488),
      bg: Color(0xFFF0FDFA),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final points =
        measurements
            .where(
              (m) => m.qualityStatus == 'VALID' && m.getMetric(metric) != null,
            )
            .toList()
          ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final config = _metrics[metric] ?? _metrics['ph']!;
    final latest = points.isEmpty ? null : points.last.getMetric(metric);
    final change = points.length < 2
        ? null
        : points.last.getMetric(metric)! - points.first.getMetric(metric)!;
    final double? minVal = points.isEmpty
        ? null
        : points.map((p) => p.getMetric(metric)!.toDouble()).reduce((a, b) => a < b ? a : b);
    final double? maxVal = points.isEmpty
        ? null
        : points.map((p) => p.getMetric(metric)!.toDouble()).reduce((a, b) => a > b ? a : b);

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xu hướng ${rangeLabel(range)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      latest == null
                          ? 'Chưa có mẫu hợp lệ'
                          : '${formatNumber(latest)} ${config.unit} hiện tại · ${points.length} mẫu đo',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: metric,
                    isDense: true,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    dropdownColor: Colors.white,
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7), size: 18),
                    ),
                    selectedItemBuilder: (context) {
                      return _metrics.entries.map((e) {
                        final meta = e.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: meta.bg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(meta.icon, size: 14, color: meta.color),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              meta.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (meta.unit.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${meta.unit})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        );
                      }).toList();
                    },
                    items: _metrics.entries.map((entry) {
                      final key = entry.key;
                      final meta = entry.value;
                      final isSelected = key == metric;
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: meta.bg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: meta.color.withValues(alpha: 0.2)),
                                ),
                                child: Icon(meta.icon, size: 15, color: meta.color),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    meta.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? meta.color : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  if (meta.unit.isNotEmpty)
                                    Text(
                                      'Đơn vị: ${meta.unit}',
                                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, size: 16, color: meta.color),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onMetricChanged(value);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              _rangeChip(context, const Duration(hours: 6), '6 giờ'),
              _rangeChip(context, const Duration(hours: 24), '24 giờ'),
              _rangeChip(context, const Duration(days: 7), '7 ngày'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        change > 0
                            ? Icons.trending_up
                            : change < 0
                                ? Icons.trending_down
                                : Icons.trending_flat,
                        size: 14,
                        color: const Color(0xFF1769D2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Biến động ${change > 0 ? '+' : ''}${formatNumber(change)} ${config.unit}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1E40AF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (minVal != null && maxVal != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'Đáy: ${minVal.toStringAsFixed(2)}${config.unit.isNotEmpty ? ' ${config.unit}' : ''}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'Đỉnh: ${maxVal.toStringAsFixed(2)}${config.unit.isNotEmpty ? ' ${config.unit}' : ''}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: points.length < 2
                ? const Center(
                    child: Text(
                      'Cần ít nhất 2 mẫu để vẽ biểu đồ.',
                      style: TextStyle(
                        color: Color(0xFF8390A4),
                        fontSize: 12,
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: HistoryChartPainter(
                      points
                          .map(
                            (p) => (
                              p.measuredAt,
                              p.getMetric(metric)!.toDouble(),
                            ),
                          )
                          .toList(),
                      unit: config.unit,
                      primaryColor: config.color,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  points.isEmpty
                      ? '—'
                      : measurementTimeLabel(points.first.measuredAt, range),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  points.isEmpty
                      ? '—'
                      : measurementTimeLabel(points.last.measuredAt, range),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeChip(BuildContext context, Duration value, String label) {
    final active = range == value;
    return InkWell(
      onTap: () => onRangeChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
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

class HistoryChartPainter extends CustomPainter {
  HistoryChartPainter(
    this.samples, {
    this.unit = '',
    this.primaryColor = const Color(0xFF1769D2),
  });

  final List<(DateTime, double)> samples;
  final String unit;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 40.0;
    const rightMargin = 16.0;
    const topMargin = 22.0;
    const bottomMargin = 14.0;

    final plot = Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - bottomMargin,
    );

    final values = samples.map((sample) => sample.$2).toList();
    var minValue = values.reduce((a, b) => a < b ? a : b);
    var maxValue = values.reduce((a, b) => a > b ? a : b);

    if ((maxValue - minValue).abs() < 0.05) {
      minValue -= 0.5;
      maxValue += 0.5;
    } else {
      final pad = (maxValue - minValue) * 0.12;
      minValue -= pad;
      maxValue += pad;
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    // Draw 4 horizontal grid lines with clear Y-axis numbers
    for (var i = 0; i < 4; i++) {
      final y = plot.top + plot.height * i / 3;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);

      final val = maxValue - (maxValue - minValue) * (i / 3.0);
      final textSpan = TextSpan(
        text: val.toStringAsFixed(1),
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plot.left - tp.width - 6, y - tp.height / 2));
    }

    final start = samples.first.$1.millisecondsSinceEpoch.toDouble();
    final duration = samples.last.$1.millisecondsSinceEpoch - start;
    final offsets = <Offset>[];
    for (var i = 0; i < samples.length; i++) {
      final x = plot.left +
          (duration == 0
                  ? (samples.length == 1 ? 0.5 : i / (samples.length - 1))
                  : (samples[i].$1.millisecondsSinceEpoch - start) / duration) *
              plot.width;
      final y = plot.bottom -
          (samples[i].$2 - minValue) / (maxValue - minValue) * plot.height;
      offsets.add(Offset(x, y));
    }

    // Bezier smooth curve
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      final previous = offsets[i - 1];
      final current = offsets[i];
      final midX = (previous.dx + current.dx) / 2;
      path.quadraticBezierTo(
        previous.dx,
        previous.dy,
        midX,
        (previous.dy + current.dy) / 2,
      );
      if (i == offsets.length - 1) {
        path.quadraticBezierTo(
          midX,
          (previous.dy + current.dy) / 2,
          current.dx,
          current.dy,
        );
      }
    }

    // Gradient fill under the curve
    final fill = Path.from(path)
      ..lineTo(plot.right, plot.bottom)
      ..lineTo(plot.left, plot.bottom)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.22),
            primaryColor.withValues(alpha: 0.02),
          ],
        ).createShader(plot),
    );

    // Stroke line curve
    canvas.drawPath(
      path,
      Paint()
        ..color = primaryColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Draw small dots at each data point if samples count <= 35
    if (samples.length <= 35) {
      for (var i = 0; i < offsets.length - 1; i++) {
        canvas.drawCircle(offsets[i], 3, Paint()..color = Colors.white);
        canvas.drawCircle(
          offsets[i],
          2,
          Paint()..color = primaryColor.withValues(alpha: 0.7),
        );
      }
    }

    // Draw the latest / last data point (prominent dot with pulse ring)
    final lastOffset = offsets.last;
    canvas.drawCircle(
      lastOffset,
      6,
      Paint()..color = primaryColor.withValues(alpha: 0.25),
    );
    canvas.drawCircle(lastOffset, 4, Paint()..color = Colors.white);
    canvas.drawCircle(lastOffset, 3, Paint()..color = primaryColor);

    // Draw value badge on the latest point so user sees the exact number!
    final lastVal = samples.last.$2;
    final badgeText = '${lastVal.toStringAsFixed(2)}${unit.isNotEmpty ? ' $unit' : ''}';
    final badgeSpan = TextSpan(
      text: badgeText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
      ),
    );
    final badgeTp = TextPainter(
      text: badgeSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = badgeTp.width + 12;
    final badgeHeight = badgeTp.height + 6;

    var badgeX = lastOffset.dx - badgeWidth / 2;
    if (badgeX + badgeWidth > size.width - 4) {
      badgeX = size.width - badgeWidth - 4;
    }
    if (badgeX < plot.left) {
      badgeX = plot.left;
    }

    var badgeY = lastOffset.dy - badgeHeight - 8;
    if (badgeY < 2) {
      badgeY = lastOffset.dy + 8;
    }

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, badgeWidth, badgeHeight),
      const Radius.circular(6),
    );

    // Badge shadow
    canvas.drawRRect(
      badgeRect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    // Badge pill background
    canvas.drawRRect(badgeRect, Paint()..color = primaryColor);
    badgeTp.paint(canvas, Offset(badgeX + 6, badgeY + 3));
  }

  @override
  bool shouldRepaint(covariant HistoryChartPainter oldDelegate) =>
      oldDelegate.samples != samples ||
      oldDelegate.unit != unit ||
      oldDelegate.primaryColor != primaryColor;
}

