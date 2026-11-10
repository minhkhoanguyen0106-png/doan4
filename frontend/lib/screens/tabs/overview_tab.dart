import 'dart:math' as math;
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
                final cross = c.maxWidth > 1200
                    ? 4
                    : c.maxWidth > 700
                    ? 3
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
                      label: 'Khí độc NH3 (AI)',
                      value: latest!.nh3Percentage,
                      unit: '%',
                      icon: Icons.warning_amber_rounded,
                      stat: null,
                      accent: const Color(0xFFDC2626),
                      selected: chartMetric == 'nh3Pct',
                      onTap: () => onSelectMetric('nh3Pct'),
                      safeMin: 0.0,
                      safeMax: 5.0,
                      safeLabel: 'Tối ưu: < 5% (Độc hại: > 10%)',
                    ),
                    MetricCard(
                      label: 'Độ mặn ao nuôi',
                      value: latest!.salinityPpt ?? (latest!.readings['ph'] != null ? 15.0 : null),
                      unit: '‰',
                      icon: Icons.water_drop_rounded,
                      stat: null,
                      accent: const Color(0xFF0D9488),
                      selected: chartMetric == 'salinityPpt',
                      onTap: () => onSelectMetric('salinityPpt'),
                      safeMin: 10.0,
                      safeMax: 25.0,
                      safeLabel: 'Tối ưu: 10 – 25 ‰',
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
          _buildSoftSensorCard(context, latest, species),
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

  Widget _buildSoftSensorCard(
    BuildContext context,
    WaterMeasurement? latest,
    AquacultureSpecies species,
  ) {
    final ph = latest?.readings['ph']?.toDouble() ?? 6.9;
    final temp = latest?.readings['temperatureC']?.toDouble() ?? 28.0;
    final nh3Pct = latest?.nh3Percentage ?? (100.0 / (1.0 + math.pow(10.0, (0.09018 + 2729.92 / (273.15 + temp)) - ph)));
    final salinity = latest?.salinityPpt ?? (latest?.readings['tdsMgL'] != null ? (latest!.readings['tdsMgL']!.toDouble() / 1000.0 * 1.05) : 15.0);

    final isNh3Safe = nh3Pct < 5.0;
    final isNh3Critical = nh3Pct > 10.0;
    final nh3Color = isNh3Critical ? const Color(0xFFDC2626) : (isNh3Safe ? const Color(0xFF059669) : const Color(0xFFD97706));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_rounded, color: Color(0xFF0284C7), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mô hình Cảm biến mềm (Soft Sensor) & Độ mặn',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Ứng dụng mô hình hóa lý Emerson suy diễn độc tố NH3 tự do & Độ mặn từ pH, Nhiệt độ và TDS',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Text(
                  'Soft Sensor v2.4',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              final isWide = box.maxWidth > 650;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NH3 Column
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: nh3Color.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: nh3Color.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 18, color: nh3Color),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Khí độc Amonia (NH3)',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: nh3Color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isNh3Critical ? 'Nguy hại' : (isNh3Safe ? 'An toàn' : 'Cảnh giác'),
                                  style: TextStyle(color: nh3Color, fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${nh3Pct.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: nh3Color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'tỷ lệ NH3 tự do',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Công thức: %NH3 = 100 / (1 + 10^(pKa - pH))\n• Đánh giá: Tại pH $ph, phần lớn Amonia ở dạng NH4+ không độc. Nếu pH tăng lên 8.5, NH3 sẽ vọt lên ~15% gây ngộ độc tôm.\n• Xử lý khi độc tố tăng: Tạt EDTA (2-3 kg/1000m³) khử độc nước, ủ men vi sinh Bacillus + rỉ mật đường hạ pH.',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isWide) const SizedBox(width: 14) else const SizedBox(height: 14),
                  // Salinity Column
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.water_drop_rounded, size: 18, color: Color(0xFF0284C7)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Độ mặn ao nuôi (Salinity)',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  species.name,
                                  style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${salinity.toStringAsFixed(1)} ‰',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '(ppt - phần nghìn)',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Công thức: S (‰) ≈ TDS / 1000 × 1.05\n• Ngưỡng tối ưu: 10 – 25 ‰ cho ${species.name}.\n• Vai trò: Giữ áp suất thẩm thấu ổn định, giúp tôm nhanh cứng vỏ sau lột và giảm thiểu sốc môi trường.',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

