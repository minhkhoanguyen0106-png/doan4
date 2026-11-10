import 'package:flutter/material.dart';
import '../../models/water_models.dart';
import '../../widgets/common_views.dart';
import '../../widgets/stat_cards.dart';

class SitesTab extends StatefulWidget {
  const SitesTab({
    super.key,
    required this.sites,
    required this.selectedSite,
    required this.onCreateSite,
    required this.onSelectSite,
  });

  final List<MonitoringSite> sites;
  final MonitoringSite? selectedSite;
  final VoidCallback onCreateSite;
  final ValueChanged<MonitoringSite> onSelectSite;

  @override
  State<SitesTab> createState() => _SitesTabState();
}

class _SitesTabState extends State<SitesTab> {
  String _query = '';
  String _filter = 'ALL'; // 'ALL', 'ACTIVE', 'INACTIVE'

  @override
  Widget build(BuildContext context) {
    if (widget.sites.isEmpty) {
      return EmptyState(
        icon: Icons.place_outlined,
        title: 'Chưa có điểm quan trắc',
        subtitle: 'Thêm nguồn nước hoặc vị trí ao nuôi bạn muốn theo dõi.',
        action: FilledButton.icon(
          onPressed: widget.onCreateSite,
          icon: const Icon(Icons.add),
          label: const Text('Thêm điểm mới'),
        ),
      );
    }

    final activeCount =
        widget.sites.where((s) => s.status == 'ACTIVE').length;
    final inactiveCount = widget.sites.length - activeCount;

    final query = _query.trim().toLowerCase();
    final filtered = widget.sites.where((site) {
      final matchQuery = query.isEmpty ||
          site.name.toLowerCase().contains(query) ||
          (site.location?.toLowerCase().contains(query) ?? false);
      if (!matchQuery) return false;

      if (_filter == 'ACTIVE') return site.status == 'ACTIVE';
      if (_filter == 'INACTIVE') return site.status != 'ACTIVE';
      return true;
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 650;

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, isMobile ? 96 : 36),
      children: [
        // Subheader & System Identity
        if (isMobile) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PONDORA · MONITORING SITES & PONDS',
                style: TextStyle(
                  color: Color(0xFF0284C7),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Điểm quan trắc & Nguồn nước',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                'Quản lý và giám sát dữ liệu ${widget.sites.length} vị trí ao nuôi trong hệ thống.',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onCreateSite,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Thêm điểm mới'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
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
                    'PONDORA · MONITORING SITES & PONDS',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Điểm quan trắc & Nguồn nước',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Quản lý và giám sát dữ liệu ${widget.sites.length} vị trí ao nuôi trong hệ thống.',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: widget.onCreateSite,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Thêm điểm mới'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 20),

        // Stat Cards Grid (Equal Width, Responsive)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 780;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: AdminStat(
                      label: 'Tổng điểm đo',
                      value: '${widget.sites.length}',
                      icon: Icons.location_on_rounded,
                      color: const Color(0xFF0F62FE),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AdminStat(
                      label: 'Đang hoạt động',
                      value: '$activeCount',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AdminStat(
                      label: 'Điểm đang chọn',
                      value: widget.selectedSite?.name ?? 'Chưa chọn',
                      icon: Icons.water_drop_rounded,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ],
              );
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: AdminStat(
                    label: 'Tổng điểm đo',
                    value: '${widget.sites.length}',
                    icon: Icons.location_on_rounded,
                    color: const Color(0xFF0F62FE),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: AdminStat(
                    label: 'Đang hoạt động',
                    value: '$activeCount',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth,
                  child: AdminStat(
                    label: 'Điểm đang chọn',
                    value: widget.selectedSite?.name ?? 'Chưa chọn',
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // Search & Filter Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 20, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _query = v),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm theo tên ao, vị trí...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.normal,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 10, color: Color(0xFFF1F5F9)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('Tất cả ${widget.sites.length}', 'ALL'),
                          const SizedBox(width: 6),
                          _filterChip('Hoạt động $activeCount', 'ACTIVE'),
                          const SizedBox(width: 6),
                          _filterChip('Tạm ngưng $inactiveCount', 'INACTIVE'),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 20, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm theo tên ao, vị trí...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.normal,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _filterChip('Tất cả ${widget.sites.length}', 'ALL'),
                    const SizedBox(width: 6),
                    _filterChip('Hoạt động $activeCount', 'ACTIVE'),
                    const SizedBox(width: 6),
                    _filterChip('Tạm ngưng $inactiveCount', 'INACTIVE'),
                  ],
                ),
        ),

        const SizedBox(height: 20),

        // Sites Grid / Cards
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
                  SizedBox(height: 12),
                  Text(
                    'Không tìm thấy điểm quan trắc phù hợp',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Thử thay đổi từ khóa hoặc bộ lọc trạng thái.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (isMobile)
          Column(
            children: filtered.map((site) {
              final isSelected = site.id == widget.selectedSite?.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF0284C7).withValues(alpha: 0.08)
                          : const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: isSelected ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => widget.onSelectSite(site),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE0F2FE)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.water_drop_rounded,
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF475569),
                                size: 22,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE0F2FE)
                                    : site.status == 'ACTIVE'
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isSelected
                                    ? '● Đang chọn'
                                    : site.status == 'ACTIVE'
                                        ? '● Hoạt động'
                                        : '● Tạm ngưng',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFF0369A1)
                                      : site.status == 'ACTIVE'
                                          ? const Color(0xFF059669)
                                          : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          site.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 15,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                site.location?.isNotEmpty == true
                                    ? site.location!
                                    : site.timezone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              isSelected
                                  ? 'Đang xem bảng quan trắc'
                                  : 'Mở bảng quan trắc',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF475569),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: isSelected
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 960 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.45,
                ),
                itemBuilder: (context, index) {
                  final site = filtered[index];
                  final isSelected = site.id == widget.selectedSite?.id;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF0284C7).withValues(alpha: 0.08)
                              : const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: isSelected ? 16 : 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => widget.onSelectSite(site),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE0F2FE)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.water_drop_rounded,
                                    color: isSelected
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF475569),
                                    size: 22,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE0F2FE)
                                        : site.status == 'ACTIVE'
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isSelected
                                        ? '● Đang chọn'
                                        : site.status == 'ACTIVE'
                                            ? '● Hoạt động'
                                            : '● Tạm ngưng',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? const Color(0xFF0369A1)
                                          : site.status == 'ACTIVE'
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              site.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  size: 15,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    site.location?.isNotEmpty == true
                                        ? site.location!
                                        : site.timezone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            Row(
                              children: [
                                Text(
                                  isSelected
                                      ? 'Đang xem bảng quan trắc'
                                      : 'Mở bảng quan trắc',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF475569),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: isSelected
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
