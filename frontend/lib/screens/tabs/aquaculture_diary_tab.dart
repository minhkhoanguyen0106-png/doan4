import 'package:flutter/material.dart';
import '../../data/api_client.dart';
import '../../dialogs/add_feeding_dialog.dart';
import '../../dialogs/add_health_dialog.dart';
import '../../dialogs/add_treatment_dialog.dart';
import '../../dialogs/add_water_op_dialog.dart';
import '../../dialogs/pond_profile_edit_dialog.dart';
import '../../models/diary_models.dart';
import '../../models/water_models.dart';
import '../../utils/csv_exporter.dart';
import '../../utils/formatters.dart';

class AquacultureDiaryTab extends StatefulWidget {
  const AquacultureDiaryTab({
    super.key,
    required this.api,
    required this.sites,
    required this.selectedSite,
    required this.onSelectSite,
  });

  final ApiClient api;
  final List<MonitoringSite> sites;
  final MonitoringSite? selectedSite;
  final ValueChanged<MonitoringSite> onSelectSite;

  @override
  State<AquacultureDiaryTab> createState() => _AquacultureDiaryTabState();
}

class _AquacultureDiaryTabState extends State<AquacultureDiaryTab> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  bool _loading = false;
  String? _error;

  ShrimpProfile? _profile;
  DiaryAnalytics? _analytics;
  List<PondFeedingLog> _feedings = [];
  List<ShrimpHealthLog> _healthLogs = [];
  List<PondTreatmentLog> _treatments = [];
  List<PondWaterOperation> _waterOps = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void didUpdateWidget(covariant AquacultureDiaryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSite?.id != widget.selectedSite?.id) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final site = widget.selectedSite;
    if (site == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await widget.api.getShrimpProfile(site.id);
      final analytics = await widget.api.getDiaryAnalytics(site.id);
      final feedings = await widget.api.getFeedings(site.id);
      final healthLogs = await widget.api.getHealthLogs(site.id);
      final treatments = await widget.api.getTreatments(site.id);
      final waterOps = await widget.api.getWaterOps(site.id);

      if (mounted) {
        setState(() {
          _profile = profile;
          _analytics = analytics;
          _feedings = feedings;
          _healthLogs = healthLogs;
          _treatments = treatments;
          _waterOps = waterOps;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _openEditProfile() async {
    final profile = _profile;
    if (profile == null) return;
    showDialog(
      context: context,
      builder: (ctx) => PondProfileEditDialog(
        profile: profile,
        onSave: (data) async {
          try {
            await widget.api.updateShrimpProfile(profile.siteId, data);
            _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã cập nhật cấu hình số hóa ao nuôi thành công!'),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            _showSnackError(e.toString());
          }
        },
      ),
    );
  }

  Future<void> _openAddFeeding() async {
    final site = widget.selectedSite;
    if (site == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AddFeedingDialog(
        onAdd: (data) async {
          try {
            await widget.api.addFeeding(site.id, data);
            _loadData();
            _showSuccess('Đã thêm cữ cho ăn mới!');
          } catch (e) {
            _showSnackError(e.toString());
          }
        },
      ),
    );
  }

  Future<void> _openAddHealth() async {
    final site = widget.selectedSite;
    if (site == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AddHealthDialog(
        currentDoc: _profile?.currentDoc,
        onAdd: (data) async {
          try {
            await widget.api.addHealthLog(site.id, data);
            _loadData();
            _showSuccess('Đã ghi nhận số liệu mẫu tôm!');
          } catch (e) {
            _showSnackError(e.toString());
          }
        },
      ),
    );
  }

  Future<void> _openAddTreatment() async {
    final site = widget.selectedSite;
    if (site == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AddTreatmentDialog(
        onAdd: (data) async {
          try {
            await widget.api.addTreatment(site.id, data);
            _loadData();
            _showSuccess('Đã lưu nhật ký xử lý thuốc / vi sinh!');
          } catch (e) {
            _showSnackError(e.toString());
          }
        },
      ),
    );
  }

  Future<void> _openAddWaterOp() async {
    final site = widget.selectedSite;
    if (site == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AddWaterOpDialog(
        onAdd: (data) async {
          try {
            await widget.api.addWaterOp(site.id, data);
            _loadData();
            _showSuccess('Đã lưu nhật ký thay nước / xifong đáy!');
          } catch (e) {
            _showSnackError(e.toString());
          }
        },
      ),
    );
  }

  void _showSuccess(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSnackError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _cleanSpecies(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Tôm thẻ chân trắng';
    if (raw.contains('├') || raw.contains('ß') || raw.contains('?') || (raw.startsWith('T') && raw.length > 15 && !raw.contains(' '))) {
      return 'Tôm thẻ chân trắng';
    }
    return raw;
  }

  String _formatMeal(String raw) {
    if (raw.contains('1') && (raw.contains('?') || raw.contains('C?'))) return 'Cữ 1 (06:00)';
    if (raw.contains('2') && (raw.contains('?') || raw.contains('C?'))) return 'Cữ 2 (10:30)';
    if (raw.contains('3') && (raw.contains('?') || raw.contains('C?'))) return 'Cữ 3 (14:30)';
    if (raw.contains('4') && (raw.contains('?') || raw.contains('C?'))) return 'Cữ 4 (18:30)';
    return raw;
  }

  String _formatTrayStatus(String raw) {
    if (raw == 'HẾT' || (raw.contains('H') && raw.length <= 4)) return 'HẾT';
    if (raw == 'DƯ_DƯỚI_10%' || raw.contains('DƯ_DƯỚI') || (raw.contains('D?') && raw.contains('10%'))) return 'Dư nhẹ (<10%)';
    if (raw == 'DƯ_TRÊN_10%' || raw.contains('DƯ_TRÊN')) return 'Dư nhiều (>10%)';
    if (raw == 'BỎ_ĂN' || raw.contains('B?')) return 'Bỏ ăn';
    return raw;
  }

  String _formatHealth(String raw) {
    if (raw == 'KHỎE_MẠNH' || (raw.contains('KH') && raw.contains('M'))) return 'Khỏe mạnh';
    if (raw == 'TỐT' || raw.contains('T?') || raw == 'T?T') return 'Tốt';
    if (raw == 'THEO_DÕI' || raw.contains('THEO')) return 'Cần theo dõi';
    if (raw == 'BẤT_THƯỜNG' || raw.contains('B?T')) return 'Bất thường';
    return raw;
  }

  String _formatTreatment(String type) {
    return switch (type) {
      'MEN_VI_SINH' => 'Men vi sinh',
      'KHOANG_CHAT' => 'Khoáng tạt',
      'VOI_NONG_NGHIEP' => 'Vôi tạt',
      'DIET_KHUAN' => 'Diệt khuẩn',
      'OXY_VIEN' => 'Oxy viên',
      'TRI_BENH' => 'Thuốc / Giải độc',
      'KHAC' => 'Chế phẩm khác',
      _ => type,
    };
  }

  String _formatWaterOp(String type, double? volume) {
    final volStr = (volume != null && volume > 0) ? ' (${formatNumber(volume)} m³)' : '';
    return switch (type) {
      'XIFONG_DAY' => 'Xifong hút mùn bã đáy ao',
      'THAY_NUOC' => 'Thay nước ao$volStr',
      'CAP_NUOC_MOI' => 'Cấp bù nước mới$volStr',
      'TACH_CHAT_THAI' => 'Tách phân tôm & Vỏ lột',
      'KHAC' => 'Hoạt động nước khác',
      _ => '$type$volStr',
    };
  }

  void _exportCsv() {
    final site = widget.selectedSite;
    if (site == null) return;
    final safeSiteName = site.name.replaceAll(RegExp(r'[^\w\s]+'), '_');
    final dateSuffix = DateTime.now().toIso8601String().substring(0, 10);
    final fileName = 'PONDORA_NhatKyNuoiTom_${safeSiteName}_$dateSuffix.csv';

    final buffer = StringBuffer();
    // UTF-8 BOM
    buffer.write('\uFEFF');
    buffer.writeln('BÁO CÁO NHẬT KÝ CHĂM SÓC VÀ QUẢN LÝ AO TÔM PONDORA');
    buffer.writeln('Ao nuôi:,"${site.name}"');
    buffer.writeln('Ngày xuất báo cáo:,"${dateLabel(DateTime.now())}"');
    buffer.writeln('Giống nuôi:,"${_profile?.shrimpSpecies ?? 'Tôm thẻ chân trắng'}"');
    buffer.writeln('Ngày tuổi tôm (DOC):,"${_profile?.currentDoc ?? 0} ngày"');
    buffer.writeln('Tổng lượng thức ăn:,"${_analytics?.totalFeedKg ?? 0} kg"');
    buffer.writeln('Sinh khối ước tính:,"${_analytics?.estimatedBiomassKg ?? 0} kg"');
    buffer.writeln('Hệ số FCR ước tính:,"${_analytics?.fcr ?? 0}"');
    buffer.writeln('');

    buffer.writeln('--- 1. NHẬT KÝ CHO ĂN ---');
    buffer.writeln('Thời gian,Cữ ăn,Hãng thức ăn,Lượng thức ăn (kg),Tình trạng nhá,Ghi chú');
    for (final f in _feedings) {
      buffer.writeln(
        '"${dateLabel(f.fedAt.toLocal())} ${timeLabel(f.fedAt.toLocal())}",'
        '"${f.feedMeal}",'
        '"${f.feedBrand ?? ''}",'
        '${f.amountKg},'
        '"${f.feedTrayStatus}",'
        '"${f.notes ?? ''}"',
      );
    }
    buffer.writeln('');

    buffer.writeln('--- 2. THEO DÕI TĂNG TRƯỞNG & SỨC KHỎE TÔM ---');
    buffer.writeln('Thời gian,DOC (Ngày),Trọng lượng (g/con),Size (con/kg),Tỷ lệ sống (%),Đánh giá,Đường ruột,Gan tụy,Vỏ tôm,Ghi chú');
    for (final h in _healthLogs) {
      buffer.writeln(
        '"${dateLabel(h.loggedAt.toLocal())}",'
        '${h.ageDays ?? 0},'
        '${h.averageWeightG},'
        '${h.sizeCountPerKg ?? 0},'
        '${h.estimatedSurvivalRate ?? 0},'
        '"${h.healthStatus}",'
        '"${h.gutCondition ?? ''}",'
        '"${h.hepatopancreas ?? ''}",'
        '"${h.shellCondition ?? ''}",'
        '"${h.notes ?? ''}"',
      );
    }
    buffer.writeln('');

    buffer.writeln('--- 3. XỬ LÝ THUỐC & CHẾ PHẨM SINH HỌC ---');
    buffer.writeln('Thời gian,Phân loại,Tên chế phẩm,Liều lượng,Đơn vị,Mục đích xử lý,Ghi chú');
    for (final t in _treatments) {
      buffer.writeln(
        '"${dateLabel(t.treatedAt.toLocal())}",'
        '"${t.treatmentType}",'
        '"${t.productName}",'
        '${t.dosage},'
        '"${t.unit}",'
        '"${t.purpose ?? ''}",'
        '"${t.notes ?? ''}"',
      );
    }
    buffer.writeln('');

    buffer.writeln('--- 4. THAY NƯỚC & XIFONG ĐÁY ---');
    buffer.writeln('Thời gian,Hình thức tác động,Thể tích (m3),Nguồn nước,Ghi chú');
    for (final w in _waterOps) {
      buffer.writeln(
        '"${dateLabel(w.operatedAt.toLocal())}",'
        '"${w.operationType}",'
        '${w.volumeM3 ?? 0},'
        '"${w.waterSource ?? ''}",'
        '"${w.notes ?? ''}"',
      );
    }

    CsvExporter.exportRawCsv(buffer.toString(), fileName);
    _showSuccess('Đã xuất báo cáo nhật ký Excel/CSV ($fileName) thành công!');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sites.isEmpty) {
      return const Center(child: Text('Vui lòng tạo điểm quan trắc / ao nuôi trước.'));
    }

    final site = widget.selectedSite ?? widget.sites.first;
    final profile = _profile;
    final analytics = _analytics;

    final isMobile = MediaQuery.of(context).size.width < 768;
    final hPadding = isMobile ? 12.0 : 24.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 36),
      children: [
        // Subheader & Site Selector Strip
        if (isMobile) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PONDORA · AQUACULTURE DIARY',
                style: TextStyle(
                  color: Color(0xFF0284C7),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Số hóa Ao nuôi & Nhật ký',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildSiteDropdown(site),
                  OutlinedButton.icon(
                    onPressed: _openEditProfile,
                    icon: const Icon(Icons.tune_rounded, size: 15),
                    label: const Text('Cấu hình'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _exportCsv,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    icon: const Icon(Icons.file_download_outlined, size: 15),
                    label: const Text('Xuất CSV'),
                  ),
                ],
              ),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PONDORA · AQUACULTURE DIARY & SHRIMP MANAGEMENT',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số hóa Ao nuôi & Nhật ký chăm sóc',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Quản lý thức ăn, theo dõi đường cong tăng trưởng tôm, xử lý thuốc và xifong đáy ao.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSiteDropdown(site),
                  OutlinedButton.icon(
                    onPressed: _openEditProfile,
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('Cấu hình ao'),
                  ),
                  FilledButton.icon(
                    onPressed: _exportCsv,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Xuất Excel / CSV'),
                  ),
                ],
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        if (_loading && profile == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null && profile == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                const SizedBox(width: 12),
                Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFF991B1B)))),
                FilledButton(onPressed: _loadData, child: const Text('Thử lại')),
              ],
            ),
          )
        else ...[
          // SECTION 1: Digital Pond Profile Card
          _buildPondProfileCard(profile, analytics),

          const SizedBox(height: 14),

          // SECTION 2: Key Operational Metrics Strip (KPIs)
          _buildKpiMetricsStrip(analytics, isMobile),

          const SizedBox(height: 16),

          // SECTION 3: Visual Analytics & Growth Curves
          _buildAnalyticsCharts(analytics, isMobile),

          const SizedBox(height: 20),

          // SECTION 4: Interactive Activity Diary (Tabs)
          _buildDiaryActivitiesPanel(),
        ],
      ],
    );
  }

  Widget _buildSiteDropdown(MonitoringSite site) {
    return Container(
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
        child: DropdownButton<MonitoringSite>(
          value: widget.sites.firstWhere(
            (s) => s.id == site.id,
            orElse: () => widget.sites.first,
          ),
          borderRadius: BorderRadius.circular(16),
          elevation: 8,
          dropdownColor: Colors.white,
          icon: const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.unfold_more_rounded, color: Color(0xFF0284C7), size: 18),
          ),
          selectedItemBuilder: (context) {
            return widget.sites.map((s) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.water_rounded, size: 14, color: Color(0xFF0284C7)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: widget.sites.map((s) {
            final isSelected = s.id == site.id;
            return DropdownMenuItem(
              value: s,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
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
                        size: 15,
                        color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
                          ),
                        ),
                        if (s.location != null && s.location!.isNotEmpty)
                          Text(
                            s.location!,
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF0284C7)),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) widget.onSelectSite(val);
          },
        ),
      ),
    );
  }

  Widget _buildPondProfileCard(ShrimpProfile? p, DiaryAnalytics? a) {
    if (p == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F62FE), Color(0xFF0284C7)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'HỒ SƠ SỐ HÓA AO NUÔI: ${p.siteName.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p.farmingStage == 'UOM_GIONG'
                        ? 'Ươm giống'
                        : p.farmingStage == 'GIAI_DOAN_1'
                            ? 'Giai đoạn 1 (20-45d)'
                            : p.farmingStage == 'GIAI_DOAN_2'
                                ? 'Giai đoạn 2 (45-70d)'
                                : 'Về đích (>70d)',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _specItem(
                  'NGÀY TUỔI TÔM (DOC)',
                  p.currentDoc != null ? '${p.currentDoc} ngày' : 'Chưa thả giống',
                  Icons.calendar_today_rounded,
                  const Color(0xFF0284C7),
                ),
                _specItem(
                  'DIỆN TÍCH / THỂ TÍCH',
                  '${formatNumber(p.areaM2)} m² · ${formatNumber(p.waterVolumeM3)} m³',
                  Icons.crop_square_rounded,
                  const Color(0xFF10B981),
                ),
                _specItem(
                  'MẬT ĐỘ THẢ GIỐNG',
                  '${formatNumber(p.stockingDensityPerM2 ?? 100)} con/m²',
                  Icons.grain_rounded,
                  const Color(0xFF8B5CF6),
                ),
                _specItem(
                  'SỐ LƯỢNG GIỐNG THẢ',
                  '${p.stockedCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} con',
                  Icons.groups_rounded,
                  const Color(0xFFF59E0B),
                ),
                _specItem(
                  'GIỐNG TÔM NUÔI',
                  _cleanSpecies(p.shrimpSpecies),
                  Icons.bubble_chart_rounded,
                  const Color(0xFF06B6D4),
                ),
                _specItem(
                  'MỤC TIÊU THU HOẠCH',
                  '${formatNumber(p.targetHarvestWeightG ?? 25)} g/con',
                  Icons.flag_rounded,
                  const Color(0xFFEC4899),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specItem(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiMetricsStrip(DiaryAnalytics? a, bool isMobile) {
    if (a == null) return const SizedBox.shrink();

    final card1 = _kpiCard(
      title: 'TỔNG THỨC ĂN',
      value: '${formatNumber(a.totalFeedKg)} kg',
      sub: 'Lũy kế cả vụ',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFD97706),
      bg: const Color(0xFFFEF3C7),
    );
    final card2 = _kpiCard(
      title: 'SINH KHỐI',
      value: a.estimatedBiomassKg != null ? '${formatNumber(a.estimatedBiomassKg!)} kg' : '---',
      sub: 'Sống ~${a.survivalRatePercent ?? 85}%',
      icon: Icons.pets_rounded,
      color: const Color(0xFF059669),
      bg: const Color(0xFFD1FAE5),
    );
    final card3 = _kpiCard(
      title: 'HỆ SỐ FCR',
      value: a.fcr != null ? a.fcr!.toStringAsFixed(2) : '---',
      sub: a.fcr != null && a.fcr! < 1.3 ? 'Tối ưu' : 'Bình thường',
      icon: Icons.trending_up_rounded,
      color: const Color(0xFF2563EB),
      bg: const Color(0xFFDBEAFE),
    );
    final card4 = _kpiCard(
      title: 'SIZE TÔM',
      value: a.currentAvgWeightG != null
          ? '${a.currentAvgWeightG!.toStringAsFixed(1)} g/con'
          : '---',
      sub: a.currentSizeCountPerKg != null
          ? '~${a.currentSizeCountPerKg} con/kg'
          : 'Chưa có số đo',
      icon: Icons.scale_rounded,
      color: const Color(0xFF7C3AED),
      bg: const Color(0xFFEDE9FE),
    );

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 8),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 8),
              Expanded(child: card4),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: card1),
        const SizedBox(width: 12),
        Expanded(child: card2),
        const SizedBox(width: 12),
        Expanded(child: card3),
        const SizedBox(width: 12),
        Expanded(child: card4),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCharts(DiaryAnalytics? a, bool isMobile) {
    if (a == null) return const SizedBox.shrink();

    final feedChart = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Color(0xFFD97706), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'LƯỢNG THỨC ĂN TIÊU THỤ (KG/NGÀY)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                    letterSpacing: 0.6,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (a.dailyFeedTrend.isEmpty)
            const SizedBox(
              height: 130,
              child: Center(child: Text('Chưa có số liệu cho ăn gần đây.')),
            )
          else
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: a.dailyFeedTrend.map((p) {
                  final maxVal = a.dailyFeedTrend.map((e) => e.amountKg).reduce((x, y) => x > y ? x : y);
                  final heightFactor = maxVal > 0 ? (p.amountKg / maxVal) : 0.5;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${p.amountKg.toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: 80 * heightFactor,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        p.dateLabel,
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );

    final growthChart = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, color: Color(0xFF059669), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ĐƯỜNG CONG TĂNG TRƯỞNG (G/CON THEO DOC)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF059669),
                    letterSpacing: 0.6,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (a.growthCurve.isEmpty)
            const SizedBox(
              height: 130,
              child: Center(child: Text('Chưa có mẫu cân đo trọng lượng.')),
            )
          else
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: a.growthCurve.map((c) {
                  final maxW = a.growthCurve.map((e) => e.actualWeightG).reduce((x, y) => x > y ? x : y);
                  final hFactor = maxW > 0 ? (c.actualWeightG / maxW) : 0.5;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${c.actualWeightG.toStringAsFixed(1)}g',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 26,
                        height: 80 * hFactor,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF10B981), Color(0xFF34D399)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'D${c.doc}',
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          feedChart,
          const SizedBox(height: 12),
          growthChart,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: feedChart),
        const SizedBox(width: 14),
        Expanded(child: growthChart),
      ],
    );
  }

  Widget _buildDiaryActivitiesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: const Color(0xFF0F62FE),
            unselectedLabelColor: const Color(0xFF64748B),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorColor: const Color(0xFF0F62FE),
            tabs: [
              Tab(text: 'Cữ cho ăn (${_feedings.length})', icon: const Icon(Icons.restaurant_rounded, size: 16)),
              Tab(text: 'Cân đo & Khám tôm (${_healthLogs.length})', icon: const Icon(Icons.monitor_heart_rounded, size: 16)),
              Tab(text: 'Thuốc & Vi sinh (${_treatments.length})', icon: const Icon(Icons.science_rounded, size: 16)),
              Tab(text: 'Thay nước & Xifong (${_waterOps.length})', icon: const Icon(Icons.waves_rounded, size: 16)),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          SizedBox(
            height: 420,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildFeedingTab(),
                _buildHealthTab(),
                _buildTreatmentTab(),
                _buildWaterOpTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Nhật ký cữ ăn & kiểm tra nhá',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _openAddFeeding,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm cữ ăn'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _feedings.isEmpty
                ? const Center(child: Text('Chưa có cữ ăn nào được ghi nhận.'))
                : ListView.separated(
                    itemCount: _feedings.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (ctx, i) {
                      final f = _feedings[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFEF3C7),
                          child: const Icon(Icons.restaurant, color: Color(0xFFD97706), size: 18),
                        ),
                        title: Row(
                          children: [
                            Text(_formatMeal(f.feedMeal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (f.feedTrayStatus == 'HẾT' || f.feedTrayStatus.contains('H'))
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatTrayStatus(f.feedTrayStatus),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: (f.feedTrayStatus == 'HẾT' || f.feedTrayStatus.contains('H'))
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${f.feedBrand ?? 'Thức ăn chuẩn'} · ${f.notes ?? 'Không có ghi chú'} · ${dateLabel(f.fedAt.toLocal())} ${timeLabel(f.fedAt.toLocal())}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${formatNumber(f.amountKg)} kg',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF94A3B8)),
                              onPressed: () async {
                                final site = widget.selectedSite;
                                if (site != null) {
                                  await widget.api.deleteFeeding(site.id, f.id);
                                  _loadData();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Cân mẫu & chẩn đoán sức khỏe',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _openAddHealth,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Cân mẫu'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _healthLogs.isEmpty
                ? const Center(child: Text('Chưa có số liệu cân mẫu nào.'))
                : ListView.separated(
                    itemCount: _healthLogs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (ctx, i) {
                      final h = _healthLogs[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFDCFCE7),
                          child: const Icon(Icons.monitor_heart, color: Color(0xFF16A34A), size: 18),
                        ),
                        title: Row(
                          children: [
                            Text('Ngày nuôi DOC: ${h.ageDays ?? 0} ngày', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatHealth(h.healthStatus),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Ruột: ${h.gutCondition ?? 'Bình thường'} | Gan: ${h.hepatopancreas ?? 'Bình thường'} | Vỏ: ${h.shellCondition ?? 'Sáng bóng'}\n${dateLabel(h.loggedAt.toLocal())}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${h.averageWeightG} g/con', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                                Text('~${h.sizeCountPerKg ?? 0} con/kg', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF94A3B8)),
                              onPressed: () async {
                                final site = widget.selectedSite;
                                if (site != null) {
                                  await widget.api.deleteHealthLog(site.id, h.id);
                                  _loadData();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Xử lý men vi sinh, vôi & thuốc',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _openAddTreatment,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Xử lý ao'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _treatments.isEmpty
                ? const Center(child: Text('Chưa có lần xử lý thuốc/vi sinh nào.'))
                : ListView.separated(
                    itemCount: _treatments.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (ctx, i) {
                      final t = _treatments[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF3E8FF),
                          child: const Icon(Icons.science, color: Color(0xFF9333EA), size: 18),
                        ),
                        title: Row(
                          children: [
                            Text(t.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE9D5FF)),
                              ),
                              child: Text(
                                _formatTreatment(t.treatmentType),
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE)),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Mục đích: ${t.purpose ?? 'Xử lý định kỳ'} · ${t.notes ?? ''} · ${dateLabel(t.treatedAt.toLocal())}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${formatNumber(t.dosage)} ${t.unit}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF9333EA)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF94A3B8)),
                              onPressed: () async {
                                final site = widget.selectedSite;
                                if (site != null) {
                                  await widget.api.deleteTreatment(site.id, t.id);
                                  _loadData();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterOpTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Xifong đáy & thay nước ao',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _openAddWaterOp,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thay nước'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _waterOps.isEmpty
                ? const Center(child: Text('Chưa có hoạt động thay nước/xifong nào.'))
                : ListView.separated(
                    itemCount: _waterOps.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (ctx, i) {
                      final w = _waterOps[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFCFFAFE),
                          child: const Icon(Icons.waves, color: Color(0xFF0891B2), size: 18),
                        ),
                        title: Text(
                          _formatWaterOp(w.operationType, w.volumeM3),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        subtitle: Text(
                          'Nguồn: ${w.waterSource ?? 'Ao lắng'} · ${w.notes ?? ''} · ${dateLabel(w.operatedAt.toLocal())}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () async {
                            final site = widget.selectedSite;
                            if (site != null) {
                              await widget.api.deleteWaterOp(site.id, w.id);
                              _loadData();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
