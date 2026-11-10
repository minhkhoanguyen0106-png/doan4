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

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: textColor, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            first.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeLabel(first.triggeredAt.toLocal()),
                            style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: .75)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  first.message,
                  style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: .9), height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (activeAlerts.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilledButton.tonal(
                          onPressed: onViewAll,
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          child: Text('+${activeAlerts.length - 1} cảnh báo', style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: () => onResolve(first),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                      label: const Text('Đã xử lý', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: textColor.withValues(alpha: 0.15),
                        foregroundColor: textColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
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
                          Expanded(
                            child: Text(
                              first.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
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

