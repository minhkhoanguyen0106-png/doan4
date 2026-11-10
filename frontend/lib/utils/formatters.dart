import 'package:flutter/material.dart';

Color levelColor(String level) => switch (level) {
  'GOOD' => const Color(0xFF54D6A0),
  'WATCH' => const Color(0xFFFFD166),
  'HIGH' => const Color(0xFFFF9F68),
  'CRITICAL' => const Color(0xFFFF6B6B),
  _ => const Color(0xFFB6C4D7),
};

String levelTitle(String level) => switch (level) {
  'GOOD' => 'Chất lượng tốt',
  'WATCH' => 'Cần theo dõi',
  'HIGH' => 'Cảnh báo cao',
  'CRITICAL' => 'Mức nghiêm trọng',
  _ => 'Chưa đủ dữ liệu',
};

IconData levelIcon(String level) => switch (level) {
  'GOOD' => Icons.verified_outlined,
  'WATCH' => Icons.visibility_outlined,
  'HIGH' => Icons.warning_amber_rounded,
  'CRITICAL' => Icons.error_outline_rounded,
  _ => Icons.hourglass_empty_rounded,
};

String formatNumber(num value) => value.toStringAsFixed(value % 1 == 0 ? 0 : 1);

String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String timeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

String rangeLabel(Duration range) =>
    range.inDays >= 1 ? '${range.inDays} ngày' : '${range.inHours} giờ';

String measurementTimeLabel(DateTime value, Duration range) {
  final local = value.toLocal();
  return range.inDays >= 1
      ? '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} ${timeLabel(local)}'
      : timeLabel(local);
}

String metricLabel(String metric) => switch (metric) {
  'ph' => 'pH',
  'dissolvedOxygenMgL' => 'Oxy hòa tan',
  'turbidityNtu' => 'Độ đục',
  'temperatureC' => 'Nhiệt độ',
  'tdsMgL' => 'TDS',
  _ => metric,
};


