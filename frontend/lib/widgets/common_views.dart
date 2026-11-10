import 'package:flutter/material.dart';
import '../models/water_models.dart';

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.cloud_off_outlined,
    title: 'Không tải được dữ liệu',
    subtitle: message,
    action: FilledButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: const Text('Thử lại'),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
  });
  final IconData icon;
  final String title, subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 50, color: const Color(0xFF9AA9BE)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF647779)),
          ),
          const SizedBox(height: 18),
          action,
        ],
      ),
    ),
  );
}

class InlineMessage extends StatelessWidget {
  const InlineMessage({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8390A4)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF647779)),
            ),
          ),
        ],
      ),
    ),
  );
}

class DisclaimerWidget extends StatelessWidget {
  const DisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F5FD),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, color: Color(0xFF536B89), size: 19),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Mức đánh giá là sàng lọc từ chỉ số cảm biến và ngưỡng thử nghiệm. Không thay thế kết quả kiểm nghiệm nước.',
            style: TextStyle(
              color: Color(0xFF536B89),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

class SitePicker extends StatelessWidget {
  const SitePicker({
    super.key,
    required this.sites,
    required this.selected,
    required this.onChanged,
    required this.onAdd,
  });
  final List<MonitoringSite> sites;
  final MonitoringSite selected;
  final ValueChanged<MonitoringSite> onChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
          blurRadius: 14,
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
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on_rounded, color: Color(0xFF0284C7), size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: selected.id,
              borderRadius: BorderRadius.circular(16),
              elevation: 8,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7), size: 20),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              selectedItemBuilder: (context) {
                return sites.map((s) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      s.name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              items: sites
                  .map(
                    (s) {
                      final isSelected = s.id == selected.id;
                      return DropdownMenuItem(
                        value: s.id,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0284C7).withValues(alpha: 0.12)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.water_rounded,
                                  size: 16,
                                  color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      s.name,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (s.location != null && s.location!.isNotEmpty)
                                      Text(
                                        s.location!,
                                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF0284C7)),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                  .toList(),
              onChanged: (id) {
                final site = sites.where((s) => s.id == id).firstOrNull;
                if (site != null) onChanged(site);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Thêm điểm'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0284C7),
            side: const BorderSide(color: Color(0xFFBAE6FD)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    ),
  );
}

