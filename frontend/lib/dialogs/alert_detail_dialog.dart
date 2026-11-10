import 'package:flutter/material.dart';
import '../models/water_models.dart';
import '../utils/formatters.dart';

class AlertDetailDialog extends StatelessWidget {
  const AlertDetailDialog({
    super.key,
    required this.alert,
    required this.onResolve,
  });
  final WaterAlert alert;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final color = levelColor(alert.severity);
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            alert.isCritical ? Icons.error_outline : Icons.warning_amber_rounded,
            color: color,
          ),
          const SizedBox(width: 8),
          const Text('Chi tiết cảnh báo'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                levelTitle(alert.severity),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              alert.title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const Divider(height: 24),
            _infoRow('Điểm quan trắc:', alert.siteName),
            if (alert.deviceName != null)
              _infoRow('Thiết bị:', '${alert.deviceName} (${alert.deviceCode})'),
            _infoRow('Thời gian phát hiện:', '${dateLabel(alert.triggeredAt.toLocal())} ${timeLabel(alert.triggeredAt.toLocal())}'),
            _infoRow('Trạng thái:', alert.isActive ? 'Đang hoạt động' : 'Đã xử lý / bình thường'),
            if (alert.resolvedAt != null)
              _infoRow('Thời gian giải quyết:', '${dateLabel(alert.resolvedAt!.toLocal())} ${timeLabel(alert.resolvedAt!.toLocal())}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        if (alert.isActive)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onResolve();
            },
            child: const Text('Đánh dấu đã xử lý'),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

