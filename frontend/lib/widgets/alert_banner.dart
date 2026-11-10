import 'package:flutter/material.dart';
import '../models/water_models.dart';
import '../utils/formatters.dart';

class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.alerts,
    required this.onViewAll,
    required this.onResolve,
  });
  final List<WaterAlert> alerts;
  final VoidCallback onViewAll;
  final ValueChanged<WaterAlert> onResolve;

  @override
  Widget build(BuildContext context) {
    final activeAlerts = alerts.where((a) => a.isActive).toList();
    if (activeAlerts.isEmpty) return const SizedBox.shrink();

    final first = activeAlerts.first;
    final isCritical = first.isCritical;
    final bgColor = isCritical ? const Color(0xFFFFF0F0) : const Color(0xFFFFF8E7);
    final borderColor = isCritical ? const Color(0xFFFFCDD2) : const Color(0xFFFFE082);
    final textColor = isCritical ? const Color(0xFFC62828) : const Color(0xFFB78103);
    final icon = isCritical ? Icons.error_outline_rounded : Icons.warning_amber_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      first.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeLabel(first.triggeredAt.toLocal()),
                      style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: .75)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  first.message,
                  style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: .9)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => onResolve(first),
            style: TextButton.styleFrom(
              foregroundColor: textColor,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Đã xử lý'),
          ),
          if (activeAlerts.length > 1)
            FilledButton.tonal(
              onPressed: onViewAll,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text('+${activeAlerts.length - 1} cảnh báo'),
            ),
        ],
      ),
    );
  }
}

