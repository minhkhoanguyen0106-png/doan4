import 'package:flutter/material.dart';
import '../../models/water_models.dart';
import '../../utils/formatters.dart';
import '../../widgets/alert_banner.dart';
import '../../widgets/common_views.dart';
import '../../widgets/history_chart.dart';
import '../../widgets/stat_cards.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.sites,
    required this.selectedSite,
    required this.devices,
    required this.latest,
    required this.summary,
    required this.history,
    required this.chartMetric,
    required this.historyRange,
    required this.day,
    required this.alerts,
    required this.species,
    this.allSpecies = const [],
    this.onAddCustomSpecies,
    this.onDeleteSpecies,
    required this.onRefresh,
    required this.onSelectSite,
    required this.onCreateSite,
    required this.onChooseDay,
    required this.onSelectMetric,
    required this.onSelectRange,
    required this.onViewAllAlerts,
    required this.onResolveAlert,
    required this.onSelectSpecies,
    required this.onViewActionPlan,
  });

  final List<MonitoringSite> sites;
  final MonitoringSite? selectedSite;
  final List<IotDevice> devices;
  final WaterMeasurement? latest;
  final DailySummary? summary;
  final List<WaterMeasurement> history;
  final String chartMetric;
  final Duration historyRange;
  final DateTime day;
  final List<WaterAlert> alerts;
  final AquacultureSpecies species;
  final List<AquacultureSpecies> allSpecies;
  final VoidCallback? onAddCustomSpecies;
  final ValueChanged<AquacultureSpecies>? onDeleteSpecies;

  final Future<void> Function() onRefresh;
  final ValueChanged<MonitoringSite> onSelectSite;
  final VoidCallback onCreateSite;
  final VoidCallback onChooseDay;
  final ValueChanged<String> onSelectMetric;
  final ValueChanged<Duration> onSelectRange;
  final VoidCallback onViewAllAlerts;
  final ValueChanged<WaterAlert> onResolveAlert;
  final ValueChanged<AquacultureSpecies> onSelectSpecies;
  final VoidCallback onViewActionPlan;

  @override
  Widget build(BuildContext context) {
    if (sites.isEmpty) {
      return EmptyState(
        icon: Icons.water_drop_outlined,
        title: 'Chưa có điểm quan trắc',
        subtitle: 'Tạo một điểm để bắt đầu theo dõi chất lượng nước.',
        action: FilledButton.icon(
          onPressed: onCreateSite,
          icon: const Icon(Icons.add),
          label: const Text('Tạo điểm quan trắc'),
        ),
      );
    }

    final site = selectedSite!;
    final onlineCount = devices.where((d) => d.online).length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PONDORA · SMART AQUACULTURE SYSTEM',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        color: const Color(0xFF0284C7),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bảng điều khiển giám sát ao nuôi',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: onlineCount > 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '$onlineCount/${devices.length} cảm biến hoạt động · Hôm nay, ${dateLabel(DateTime.now())}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Color(0xFF1769D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SitePicker(
            sites: sites,
            selected: site,
            onChanged: onSelectSite,
            onAdd: onCreateSite,
          ),
          const SizedBox(height: 14),

          // Aquaculture Model & Species Selector
          Builder(
            builder: (context) {
              final displayedList = allSpecies.isNotEmpty ? allSpecies : AquacultureSpecies.presets;
              final hasAddButton = onAddCustomSpecies != null;
              final itemCount = displayedList.length + (hasAddButton ? 1 : 0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_rounded, size: 16, color: Color(0xFF0284C7)),
                      const SizedBox(width: 6),
                      const Text(
                        'MÔ HÌNH THỦY SẢN ĐANG NUÔI (ADAPTIVE THRESHOLDS):',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Text(
                          '${displayedList.length} loài',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        species.scientificName.isNotEmpty
                            ? species.scientificName
                            : (species.isCustom ? 'Mô hình tùy chỉnh' : ''),
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: itemCount,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        // The last slot is the "+ Thêm loài / Tùy chỉnh" button
                        if (hasAddButton && idx == displayedList.length) {
                          return ActionChip(
                            avatar: const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 16,
                              color: Color(0xFF0284C7),
                            ),
                            label: const Text('Thêm loài / Tùy chỉnh'),
                            onPressed: onAddCustomSpecies,
                            backgroundColor: const Color(0xFFF0FDF4),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E),
                            ),
                            side: const BorderSide(
                              color: Color(0xFF99F6E4),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }

                        final item = displayedList[idx];
                        final isSelected = item.id == species.id;
                        return ChoiceChip(
                          avatar: Text(item.icon, style: const TextStyle(fontSize: 16)),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.name),
                              if (item.isCustom) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: const Text(
                                    'Tùy chỉnh',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                                if (onDeleteSpecies != null) ...[
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () => onDeleteSpecies!(item),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(Icons.close_rounded, size: 14, color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (_) => onSelectSpecies(item),
                          selectedColor: const Color(0xFFE0F2FE),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF475569),
                          ),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          AlertBanner(
            alerts: alerts,
            onViewAll: onViewAllAlerts,
            onResolve: onResolveAlert,
          ),
          AssessmentCard(
            level: summary?.screeningLevel ?? 'INSUFFICIENT_DATA',
            sampleCount: summary?.sampleCount ?? 0,
            deviceCount: devices.length,
            day: day,
            onPickDay: onChooseDay,
            species: species,
            onViewActionPlan: onViewActionPlan,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số đo gần nhất',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton.icon(
                onPressed: onChooseDay,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: Text(dateLabel(day)),
              ),
            ],
          ),
          if (latest == null)
            const InlineMessage(
              icon: Icons.sensors_off_outlined,
              message: 'Chưa nhận được số đo nào từ thiết bị.',
            )
          else ...[
            Text(
              'Đo lúc ${timeLabel(latest!.measuredAt.toLocal())}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF77859A)),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) {
                final cross = c.maxWidth > 1120
                    ? 5
                    : c.maxWidth > 720
                    ? 4
                    : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cross,
                  childAspectRatio: cross >= 4 ? 1.35 : 1.28,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    MetricCard(
                      label: 'Độ pH',
                      value: latest!.readings['ph'],
                      unit: '',
                      icon: Icons.science_outlined,
                      stat: summary?.ph,
                      accent: const Color(0xFF7C3AED),
                      selected: chartMetric == 'ph',
                      onTap: () => onSelectMetric('ph'),
                      safeMin: species.optimalPhMin,
                      safeMax: species.optimalPhMax,
                      safeLabel: 'Tối ưu: ${species.optimalPhMin} – ${species.optimalPhMax}',
                    ),
                    MetricCard(
                      label: 'Oxy hòa tan',
                      value: latest!.readings['dissolvedOxygenMgL'],
                      unit: 'mg/L',
                      icon: Icons.air_rounded,
                      stat: summary?.oxygen,
                      accent: const Color(0xFF059669),
                      selected: chartMetric == 'dissolvedOxygenMgL',
                      onTap: () => onSelectMetric('dissolvedOxygenMgL'),
                      safeMin: species.optimalDoMin,
                      safeMax: 9.0,
                      safeLabel: 'Tối ưu: ≥ ${species.optimalDoMin} mg/L',
                    ),
                    MetricCard(
                      label: 'Độ đục',
                      value: latest!.readings['turbidityNtu'],
                      unit: 'NTU',
                      icon: Icons.blur_on_rounded,
                      stat: summary?.turbidity,
                      accent: const Color(0xFFD97706),
                      selected: chartMetric == 'turbidityNtu',
                      onTap: () => onSelectMetric('turbidityNtu'),
                      safeMin: 0.0,
                      safeMax: species.maxTurbidity,
                      safeLabel: 'Tối ưu: ≤ ${species.maxTurbidity} NTU',
                    ),
                    MetricCard(
                      label: 'Nhiệt độ',
                      value: latest!.readings['temperatureC'],
                      unit: '°C',
                      icon: Icons.thermostat_rounded,
                      stat: summary?.temperature,
                      accent: const Color(0xFFE11D48),
                      selected: chartMetric == 'temperatureC',
                      onTap: () => onSelectMetric('temperatureC'),
                      safeMin: species.optimalTempMin,
                      safeMax: species.optimalTempMax,
                      safeLabel: 'Tối ưu: ${species.optimalTempMin} – ${species.optimalTempMax} °C',
                    ),
                    MetricCard(
                      label: 'Chỉ số TDS',
                      value: latest!.readings['tdsMgL'],
                      unit: 'mg/L',
                      icon: Icons.grain_rounded,
                      stat: summary?.tds,
                      accent: const Color(0xFF0284C7),
                      selected: chartMetric == 'tdsMgL',
                      onTap: () => onSelectMetric('tdsMgL'),
                      safeMin: 0.0,
                      safeMax: 800.0,
                      safeLabel: 'Tối ưu: ≤ 800 mg/L',
                    ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          HistoryChart(
            measurements: history,
            metric: chartMetric,
            range: historyRange,
            onRangeChanged: onSelectRange,
            onMetricChanged: onSelectMetric,
          ),
          const SizedBox(height: 18),
          const DisclaimerWidget(),
        ],
      ),
    );
  }
}

