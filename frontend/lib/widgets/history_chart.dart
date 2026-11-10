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
  };

  @override
  Widget build(BuildContext context) {
    final points =
        measurements
            .where(
              (m) => m.qualityStatus == 'VALID' && m.readings[metric] != null,
            )
            .toList()
          ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final config = _metrics[metric]!;
    final latest = points.isEmpty ? null : points.last.readings[metric];
    final change = points.length < 2
        ? null
        : points.last.readings[metric]! - points.first.readings[metric]!;
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
                          : '${formatNumber(latest)} ${config.unit} hiện tại · ${points.length} mẫu',
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
            if (change != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
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
                      size: 16,
                      color: const Color(0xFF1769D2),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Biến động ${change > 0 ? '+' : ''}${formatNumber(change)} ${config.unit} trong kỳ',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF3B5F8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 160,
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
                                p.readings[metric]!.toDouble(),
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  points.isEmpty
                      ? '—'
                      : measurementTimeLabel(points.first.measuredAt, range),
                  style: const TextStyle(
                    color: Color(0xFF8390A4),
                    fontSize: 11,
                  ),
                ),
                Text(
                  points.isEmpty
                      ? '—'
                      : measurementTimeLabel(points.last.measuredAt, range),
                  style: const TextStyle(
                    color: Color(0xFF8390A4),
                    fontSize: 11,
                  ),
                ),
              ],
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
  HistoryChartPainter(this.samples);
  final List<(DateTime, double)> samples;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 8.0, right = 8.0, top = 12.0, bottom = 12.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final values = samples.map((sample) => sample.$2);
    var minValue = values.reduce((a, b) => a < b ? a : b);
    var maxValue = values.reduce((a, b) => a > b ? a : b);
    if (minValue == maxValue) {
      minValue -= 1;
      maxValue += 1;
    }
    final gridPaint = Paint()
      ..color = const Color(0xFFE5EBF4)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = plot.top + plot.height * i / 3;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
    }
    final start = samples.first.$1.millisecondsSinceEpoch.toDouble();
    final duration = samples.last.$1.millisecondsSinceEpoch - start;
    final offsets = <Offset>[];
    for (var i = 0; i < samples.length; i++) {
      final x =
          plot.left +
          (duration == 0
                  ? i / (samples.length - 1)
                  : (samples[i].$1.millisecondsSinceEpoch - start) / duration) *
              plot.width;
      final y =
          plot.bottom -
          (samples[i].$2 - minValue) / (maxValue - minValue) * plot.height;
      offsets.add(Offset(x, y));
    }
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
    final fill = Path.from(path)
      ..lineTo(plot.right, plot.bottom)
      ..lineTo(plot.left, plot.bottom)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x551769D2), Color(0x081769D2)],
        ).createShader(plot),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1769D2)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(offsets.last, 4, Paint()..color = Colors.white);
    canvas.drawCircle(
      offsets.last,
      3,
      Paint()..color = const Color(0xFF1769D2),
    );
  }

  @override
  bool shouldRepaint(covariant HistoryChartPainter oldDelegate) =>
      oldDelegate.samples != samples;
}

