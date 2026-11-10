import 'package:flutter/material.dart';
import '../../models/water_models.dart';
import '../../widgets/common_views.dart';
import '../../widgets/stat_cards.dart';

class AdminTab extends StatefulWidget {
  const AdminTab({
    super.key,
    required this.account,
    required this.users,
    required this.loading,
    required this.onRefresh,
    required this.onToggleUserStatus,
    required this.onToggleUserRole,
  });

  final AccountUser account;
  final List<AccountUser> users;
  final bool loading;
  final Future<void> Function() onRefresh;
  final ValueChanged<AccountUser> onToggleUserStatus;
  final ValueChanged<AccountUser> onToggleUserRole;

  @override
  State<AdminTab> createState() => _AdminTabState();
}

class _AdminTabState extends State<AdminTab> {
  String _query = '';
  String _filter = 'ALL'; // 'ALL', 'ADMIN', 'ACTIVE', 'LOCKED'

  String _userInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.users.where((user) => user.isActive).length;
    final admins = widget.users.where((user) => user.isAdmin).length;
    final locked = widget.users.length - active;

    final query = _query.trim().toLowerCase();
    final filtered = widget.users.where((user) {
      // Text query match
      final matchQuery = query.isEmpty ||
          user.email.toLowerCase().contains(query) ||
          user.displayName.toLowerCase().contains(query);
      if (!matchQuery) return false;

      // Filter category match
      if (_filter == 'ADMIN') return user.isAdmin;
      if (_filter == 'ACTIVE') return user.isActive;
      if (_filter == 'LOCKED') return !user.isActive;
      return true;
    }).toList();

    if (widget.loading && widget.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        children: [
          // Subheader & System Identity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PONDORA · ACCESS CONTROL & SECURITY',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trung tâm quản trị người dùng',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Theo dõi và phân bổ quyền truy cập cho ${widget.users.length} tài khoản trong hệ thống.',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Làm mới'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stat Cards Grid (Equal Width, Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 860;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: AdminStat(
                        label: 'Tổng tài khoản',
                        value: '${widget.users.length}',
                        icon: Icons.groups_2_rounded,
                        color: const Color(0xFF0F62FE),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AdminStat(
                        label: 'Đang hoạt động',
                        value: '$active',
                        icon: Icons.verified_user_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AdminStat(
                        label: 'Quản trị viên',
                        value: '$admins',
                        icon: Icons.shield_rounded,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AdminStat(
                        label: 'Đã tạm khóa',
                        value: '$locked',
                        icon: Icons.lock_person_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                );
              } else {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: constraints.maxWidth > 480 ? 2 : 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children: [
                    AdminStat(
                      label: 'Tổng tài khoản',
                      value: '${widget.users.length}',
                      icon: Icons.groups_2_rounded,
                      color: const Color(0xFF0F62FE),
                    ),
                    AdminStat(
                      label: 'Đang hoạt động',
                      value: '$active',
                      icon: Icons.verified_user_rounded,
                      color: const Color(0xFF10B981),
                    ),
                    AdminStat(
                      label: 'Quản trị viên',
                      value: '$admins',
                      icon: Icons.shield_rounded,
                      color: const Color(0xFF8B5CF6),
                    ),
                    AdminStat(
                      label: 'Đã tạm khóa',
                      value: '$locked',
                      icon: Icons.lock_person_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 22),

          // Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                final searchField = TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    hintText: 'Tìm kiếm theo tên hoặc email...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0284C7), size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => setState(() => _query = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                    ),
                  ),
                );

                final filterChips = SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterTab('Tất cả', '${widget.users.length}', 'ALL'),
                      const SizedBox(width: 8),
                      _filterTab('Quản trị viên', '$admins', 'ADMIN'),
                      const SizedBox(width: 8),
                      _filterTab('Hoạt động', '$active', 'ACTIVE'),
                      const SizedBox(width: 8),
                      _filterTab('Đã khóa', '$locked', 'LOCKED'),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(flex: 5, child: searchField),
                      const SizedBox(width: 16),
                      filterChips,
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      searchField,
                      const SizedBox(height: 12),
                      filterChips,
                    ],
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 18),

          // Master Enterprise User List Table
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.person_search_outlined,
              title: 'Không tìm thấy tài khoản phù hợp',
              subtitle: 'Thử kiểm tra lại từ khóa tìm kiếm hoặc đổi bộ lọc trạng thái.',
              action: SizedBox.shrink(),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideTable = constraints.maxWidth > 820;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Table Column Headers (For Wide Screens)
                      if (isWideTable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  'THÀNH VIÊN / EMAIL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'VAI TRÒ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'TRẠNG THÁI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  'THAO TÁC',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // User Rows
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final isSelf = user.email == widget.account.email;

                          if (isWideTable) {
                            return _buildWideTableRow(user, isSelf);
                          } else {
                            return _buildCompactCardRow(user, isSelf);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _filterTab(String label, String count, String key) {
    final active = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0F62FE) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF475569),
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: active ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideTableRow(AccountUser user, bool isSelf) {
    final initials = _userInitials(user.displayName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: isSelf ? const Color(0xFFF8FAFC) : Colors.white,
      child: Row(
        children: [
          // User Avatar + Name + Email
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: user.isAdmin
                          ? const [Color(0xFF8B5CF6), Color(0xFF6D28D9)]
                          : const [Color(0xFF0F62FE), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: (user.isAdmin ? const Color(0xFF8B5CF6) : const Color(0xFF0F62FE))
                            .withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: const Text(
                                'Bạn',
                                style: TextStyle(
                                  color: Color(0xFF0284C7),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Role Badge
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _roleBadge(user.isAdmin),
            ),
          ),

          // Status Badge
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusBadge(user.isActive),
            ),
          ),

          // Actions
          SizedBox(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isSelf)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Đang đăng nhập',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else ...[
                  // Toggle Role Button
                  OutlinedButton.icon(
                    onPressed: () => widget.onToggleUserRole(user),
                    icon: Icon(
                      user.isAdmin ? Icons.remove_moderator_outlined : Icons.shield_outlined,
                      size: 15,
                    ),
                    label: Text(user.isAdmin ? 'Hạ cấp' : 'Cấp Admin'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7C3AED),
                      side: const BorderSide(color: Color(0xFFDDD6FE)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Toggle Status Button
                  OutlinedButton.icon(
                    onPressed: () => widget.onToggleUserStatus(user),
                    icon: Icon(
                      user.isActive ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                      size: 15,
                    ),
                    label: Text(user.isActive ? 'Khóa' : 'Mở'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user.isActive ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      side: BorderSide(
                        color: user.isActive ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCardRow(AccountUser user, bool isSelf) {
    final initials = _userInitials(user.displayName);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: user.isAdmin
                        ? const [Color(0xFF8B5CF6), Color(0xFF6D28D9)]
                        : const [Color(0xFF0F62FE), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Text(user.email, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
              if (isSelf)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Bạn', style: TextStyle(color: Color(0xFF0284C7), fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _roleBadge(user.isAdmin),
              const SizedBox(width: 8),
              _statusBadge(user.isActive),
              const Spacer(),
              if (!isSelf) ...[
                IconButton(
                  icon: Icon(user.isAdmin ? Icons.remove_moderator_outlined : Icons.shield_outlined, size: 18),
                  color: const Color(0xFF7C3AED),
                  onPressed: () => widget.onToggleUserRole(user),
                ),
                IconButton(
                  icon: Icon(user.isActive ? Icons.lock_outline_rounded : Icons.lock_open_rounded, size: 18),
                  color: user.isActive ? const Color(0xFFDC2626) : const Color(0xFF059669),
                  onPressed: () => widget.onToggleUserStatus(user),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(bool isAdmin) {
    if (isAdmin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDD6FE)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_rounded, size: 13, color: Color(0xFF7C3AED)),
            SizedBox(width: 5),
            Text(
              'Quản trị viên',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_rounded, size: 13, color: Color(0xFF64748B)),
          SizedBox(width: 5),
          Text(
            'Người dùng',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Đang hoạt động',
              style: TextStyle(
                color: Color(0xFF059669),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Đã tạm khóa',
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

