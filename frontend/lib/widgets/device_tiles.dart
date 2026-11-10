import 'package:flutter/material.dart';
import '../models/water_models.dart';
import '../utils/formatters.dart';
import 'stat_cards.dart';

class DeviceSummaryTile extends StatelessWidget {
  const DeviceSummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1769D2), size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8290A4),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF17243A),
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class MeasurementHistoryTile extends StatelessWidget {
  const MeasurementHistoryTile({super.key, required this.measurement});
  final WaterMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final local = measurement.measuredAt.toLocal();
    final invalid = measurement.qualityStatus != 'VALID';
    final level = levelColor(measurement.assessmentLevel);
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Color(0xFF1769D2),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dateLabel(local)} · ${timeLabel(local)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Color(0xFF1B2D49),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        invalid
                            ? 'Cần kiểm tra chất lượng mẫu'
                            : 'Phép đo đã được lưu',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8290A4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: level.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    invalid
                        ? 'Mẫu lỗi'
                        : levelTitle(measurement.assessmentLevel),
                    style: TextStyle(
                      color: invalid
                          ? const Color(0xFF9A5A4E)
                          : const Color(0xFF40546D),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                ReadingPill(
                  label: 'pH',
                  value: measurement.readings['ph'],
                  unit: '',
                ),
                ReadingPill(
                  label: 'DO',
                  value: measurement.readings['dissolvedOxygenMgL'],
                  unit: 'mg/L',
                ),
                ReadingPill(
                  label: 'Đục',
                  value: measurement.readings['turbidityNtu'],
                  unit: 'NTU',
                ),
                ReadingPill(
                  label: 'Nhiệt độ',
                  value: measurement.readings['temperatureC'],
                  unit: '°C',
                ),
                ReadingPill(
                  label: 'TDS',
                  value: measurement.readings['tdsMgL'],
                  unit: 'mg/L',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

