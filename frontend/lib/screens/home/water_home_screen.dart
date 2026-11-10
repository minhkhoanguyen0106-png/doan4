import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/api_client.dart';
import '../../dialogs/ai_action_plan_dialog.dart';
import '../../dialogs/custom_species_dialog.dart';
import '../../dialogs/device_token_dialog.dart';
import '../../dialogs/name_dialog.dart';
import '../../dialogs/site_form_dialog.dart';
import '../../models/water_models.dart';
import '../../widgets/common_views.dart';
import '../../widgets/desktop_header.dart';
import '../../widgets/sidebar.dart';
import '../tabs/admin_tab.dart';
import '../tabs/alerts_tab.dart';
import '../tabs/aquaculture_diary_tab.dart';
import '../tabs/devices_tab.dart';
import '../tabs/history_tab.dart';
import '../tabs/overview_tab.dart';
import '../tabs/sites_tab.dart';

class WaterHomeScreen extends StatefulWidget {
  const WaterHomeScreen({
    super.key,
    required this.api,
    required this.account,
    required this.onLogout,
  });

  final ApiClient api;
  final AccountUser account;
  final Future<void> Function() onLogout;

  @override
  State<WaterHomeScreen> createState() => _WaterHomeScreenState();
}

class _WaterHomeScreenState extends State<WaterHomeScreen> {
  int _tab = 0;
  bool _loading = true;
  String? _error;
  List<MonitoringSite> _sites = [];
  MonitoringSite? _selected;
  List<IotDevice> _devices = [];
  WaterMeasurement? _latest;
  List<WaterMeasurement> _history = [];
  String _chartMetric = 'ph';
  Duration _historyRange = const Duration(hours: 24);
  DailySummary? _summary;
  List<WaterAlert> _alerts = [];
  List<AccountUser> _adminUsers = [];
  bool _adminLoading = false;
  DateTime _day = DateTime.now();
  AquacultureSpecies _species = AquacultureSpecies.presets.first;
  List<AquacultureSpecies> _allSpecies = [...AquacultureSpecies.presets];
  static const _secureStorage = FlutterSecureStorage();
  static const _customSpeciesStorageKey = 'pondora_custom_species_list';

  Future<void> _loadCustomSpecies() async {
    try {
      final raw = await _secureStorage.read(key: _customSpeciesStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        final customList = list
            .map((e) => AquacultureSpecies.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted && customList.isNotEmpty) {
          setState(() {
            _allSpecies = [...AquacultureSpecies.presets, ...customList];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveCustomSpecies(AquacultureSpecies newSpecies) async {
    try {
      final customOnly = _allSpecies.where((s) => s.isCustom).toList()..add(newSpecies);
      final jsonStr = jsonEncode(customOnly.map((e) => e.toJson()).toList());
      await _secureStorage.write(key: _customSpeciesStorageKey, value: jsonStr);
      setState(() {
        _allSpecies = [...AquacultureSpecies.presets, ...customOnly];
        _species = newSpecies;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm loài nuôi "${newSpecies.name}" và kích hoạt ngưỡng sinh thái!'),
            backgroundColor: const Color(0xFF0284C7),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deleteCustomSpecies(AquacultureSpecies sp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa loài "${sp.name}"?'),
        content: const Text('Loài này sẽ bị xóa khỏi danh sách đối tượng nuôi của bạn.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final customOnly = _allSpecies.where((s) => s.isCustom && s.id != sp.id).toList();
      final jsonStr = jsonEncode(customOnly.map((e) => e.toJson()).toList());
      await _secureStorage.write(key: _customSpeciesStorageKey, value: jsonStr);
      setState(() {
        _allSpecies = [...AquacultureSpecies.presets, ...customOnly];
        if (_species.id == sp.id) {
          _species = AquacultureSpecies.presets.first;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa đối tượng nuôi "${sp.name}".'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError(e);
    }
  }

  void _openAddCustomSpeciesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomSpeciesDialog(
        onSave: (species) => _saveCustomSpecies(species),
      ),
    );
  }

  // Chuyển đổi index BottomNav (mobile) <-> tab index thực
  // Mobile destinations: 0=Tổng quan, 1=Điểm đo, 2=Thiết bị, 3=Lịch sử,
  //   4=Cảnh báo, 5=Nhật ký, 6=Quản trị (nếu isAdmin)
  // Tab index thực: 0=TQ,1=Điểm,2=TB,3=LS,4=CB,5=Admin,6=NhậtKý
  int _tabToNavIndex(int tab) {
    if (tab == 6) return 5; // Nhật ký -> vị trí 5
    if (tab == 5) return widget.account.isAdmin ? 6 : 0; // Admin -> vị trí 6
    return tab; // 0-4 giữ nguyên
  }

  int _navIndexToTab(int navIndex) {
    if (navIndex == 5) return 6; // Nhật ký
    if (navIndex == 6) return 5; // Admin
    return navIndex;
  }

  void _selectTab(int value) {
    setState(() => _tab = value);
    if (value == 5) _loadAdminUsers();
  }

  void _selectNavDestination(int navIndex) {
    _selectTab(_navIndexToTab(navIndex));
  }

  Future<void> _loadAdminUsers() async {
    setState(() => _adminLoading = true);
    try {
      final users = await widget.api.adminUsers();
      if (mounted) setState(() => _adminUsers = users);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _adminLoading = false);
    }
  }

  Future<void> _toggleUser(AccountUser user) async {
    final nextStatus = user.isActive ? 'DISABLED' : 'ACTIVE';
    if (user.isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tạm khóa tài khoản?'),
          content: Text(
            'Tài khoản ${user.email} sẽ không thể đăng nhập cho đến khi được kích hoạt lại.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tạm khóa'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      await widget.api.setUserStatus(user.id, nextStatus);
      await _loadAdminUsers();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleUserRole(AccountUser user) async {
    final role = user.isAdmin ? 'USER' : 'ADMIN';
    final label = user.isAdmin ? 'người dùng thường' : 'quản trị viên';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          user.isAdmin ? 'Gỡ quyền quản trị?' : 'Cấp quyền quản trị?',
        ),
        content: Text('Tài khoản ${user.email} sẽ được chuyển thành $label.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.setUserRole(user.id, role);
      await _loadAdminUsers();
    } catch (e) {
      _showError(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCustomSpecies();
    _load();
  }

  Future<void> _load({int? siteId}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sites = await widget.api.sites();
      final chosen =
          sites.where((s) => s.id == (siteId ?? _selected?.id)).firstOrNull ??
          (sites.isEmpty ? null : sites.first);
      List<IotDevice> devices = [];
      WaterMeasurement? latest;
      DailySummary? summary;
      List<WaterMeasurement> history = [];
      List<WaterAlert> alerts = [];

      if (chosen != null) {
        final to = DateTime.now().toUtc();
        final results = await Future.wait<dynamic>([
          widget.api.devices(chosen.id),
          widget.api.latest(chosen.id),
          widget.api.dailySummary(chosen.id, _day),
          widget.api.history(
            chosen.id,
            from: to.subtract(_historyRange),
            to: to,
          ),
          widget.api.alerts(chosen.id),
        ]);
        devices = results[0] as List<IotDevice>;
        latest = results[1] as WaterMeasurement?;
        summary = results[2] as DailySummary;
        history = results[3] as List<WaterMeasurement>;
        alerts = results[4] as List<WaterAlert>;
      }
      if (!mounted) return;
      setState(() {
        _sites = sites;
        _selected = chosen;
        _devices = devices;
        _latest = latest;
        _summary = summary;
        _history = history;
        _alerts = alerts;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _createSite() async {
    final result = await showModalBottomSheet<SiteDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SiteFormDialog(),
    );
    if (result == null) return;
    try {
      final site = await widget.api.createSite(
        name: result.name,
        location: result.location,
        timezone: result.timezone,
        notes: result.notes,
      );
      if (!mounted) return;
      setState(() => _tab = 0);
      await _load(siteId: site.id);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _createDevice() async {
    final site = _selected;
    if (site == null) {
      _showError('Hãy tạo điểm quan trắc trước.');
      return;
    }
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          const NameDialog(title: 'Thêm thiết bị', hint: 'Tên thiết bị'),
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      final device = await widget.api.createDevice(site.id, name.trim());
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => DeviceTokenDialog(device: device),
      );
      await _load(siteId: site.id);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _resolveAlert(WaterAlert alert) async {
    try {
      await widget.api.resolveAlert(alert.siteId, alert.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái cảnh báo.')),
      );
      await _load(siteId: alert.siteId);
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object error) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(error.toString())));

  Future<void> _chooseDay() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (chosen != null) {
      setState(() => _day = chosen);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_tab) {
      1 => 'Điểm quan trắc',
      2 => 'Thiết bị',
      3 => 'Lịch sử phép đo',
      4 => 'Cảnh báo',
      5 => 'Quản trị tài khoản',
      6 => 'Nhật ký ao tôm',
      _ => 'Tổng quan',
    };
    final activeAlertCount = _alerts.where((a) => a.isActive).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1000;
        return Scaffold(
          appBar: desktop
              ? null
              : AppBar(
                  titleSpacing: 8,
                  title: Row(
                    children: [
                      const Icon(
                        Icons.water_drop_rounded,
                        color: Color(0xFF1769D2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Làm mới dữ liệu',
                      onPressed: _loading ? null : _load,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    _accountMenu(),
                    const SizedBox(width: 8),
                  ],
                ),
          drawer: desktop
              ? null
              : Drawer(
                  width: 280,
                  backgroundColor: const Color(0xFF060912),
                  child: SafeArea(
                    child: WaterSidebar(
                      selectedIndex: _tab,
                      onSelect: (idx) {
                        Navigator.of(context).pop();
                        _selectTab(idx);
                      },
                      isAdmin: widget.account.isAdmin,
                      account: widget.account,
                      onCreateSite: () {
                        Navigator.of(context).pop();
                        _createSite();
                      },
                      onLogout: () {
                        Navigator.of(context).pop();
                        widget.onLogout();
                      },
                      activeAlertCount: activeAlertCount,
                    ),
                  ),
                ),
          body: desktop
              ? Row(
                  children: [
                    WaterSidebar(
                      selectedIndex: _tab,
                      onSelect: _selectTab,
                      isAdmin: widget.account.isAdmin,
                      account: widget.account,
                      onCreateSite: _createSite,
                      onLogout: widget.onLogout,
                      activeAlertCount: activeAlertCount,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: _DashboardBackgroundAccents(),
                          ),
                          Column(
                            children: [
                              DesktopHeader(
                                title: title,
                                subtitle: _tab == 0
                                    ? 'Theo dõi các chỉ số và hoạt động của cảm biến.'
                                    : _tab == 6
                                    ? 'Số hóa thông tin ao nuôi, nhật ký chăm sóc, tôm và thức ăn.'
                                    : _tab == 5
                                    ? 'Quản lý quyền truy cập và trạng thái tài khoản.'
                                    : _tab == 1
                                    ? 'Quản lý các vị trí đang thu thập dữ liệu nước.'
                                    : _tab == 2
                                    ? 'Theo dõi kết nối và dữ liệu từ các thiết bị.'
                                    : _tab == 4
                                    ? 'Cảnh báo chất lượng nước và tình trạng thiết bị.'
                                    : 'Tra cứu và đối chiếu các mẫu nước đã ghi nhận.',
                                loading: _loading,
                                onRefresh: _load,
                                accountMenu: _accountMenu(),
                                onlineDeviceCount: _devices
                                    .where((device) => device.online)
                                    .length,
                                deviceCount: _devices.length,
                                activeAlertCount: activeAlertCount,
                                onAlertClick: () => _selectTab(4),
                                onSimulate: _openSimulationDialog,
                              ),
                              Expanded(child: _pageContent()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    const Positioned.fill(
                      child: _DashboardBackgroundAccents(),
                    ),
                    _pageContent(),
                  ],
                ),
          floatingActionButton: !desktop && _tab == 1
              ? FloatingActionButton.extended(
                  onPressed: _createSite,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Thêm điểm'),
                )
              : !desktop && _tab == 2 && _selected != null
              ? FloatingActionButton.extended(
                  onPressed: _createDevice,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thiết bị'),
                )
              : null,
          bottomNavigationBar: desktop
              ? null
              : NavigationBarTheme(
                  data: NavigationBarThemeData(
                    height: 64,
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontSize: 9.5,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                      );
                    }),
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        size: 21,
                        color: selected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                      );
                    }),
                  ),
                  child: NavigationBar(
                    selectedIndex: _tabToNavIndex(_tab).clamp(0, widget.account.isAdmin ? 6 : 5),
                    onDestinationSelected: _selectNavDestination,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      const NavigationDestination(
                        icon: Icon(Icons.grid_view_rounded),
                        label: 'Tổng quan',
                      ),
                      const NavigationDestination(
                        icon: Icon(Icons.place_outlined),
                        label: 'Điểm đo',
                      ),
                      const NavigationDestination(
                        icon: Icon(Icons.sensors_outlined),
                        label: 'Thiết bị',
                      ),
                      const NavigationDestination(
                        icon: Icon(Icons.history_rounded),
                        label: 'Lịch sử',
                      ),
                      NavigationDestination(
                        icon: Badge(
                          isLabelVisible: activeAlertCount > 0,
                          label: Text('$activeAlertCount'),
                          child: const Icon(Icons.warning_amber_rounded),
                        ),
                        label: 'Cảnh báo',
                      ),
                      const NavigationDestination(
                        icon: Icon(Icons.menu_book_rounded),
                        label: 'Nhật ký',
                      ),
                      if (widget.account.isAdmin)
                        const NavigationDestination(
                          icon: Icon(Icons.admin_panel_settings_outlined),
                          label: 'Quản trị',
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _accountMenu() => PopupMenuButton<String>(
    tooltip: 'Tài khoản',
    elevation: 8,
    shadowColor: Colors.black.withValues(alpha: 0.15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    offset: const Offset(0, 48),
    color: Colors.white,
    onSelected: (value) {
      if (value == 'logout') widget.onLogout();
    },
    itemBuilder: (_) => [
      PopupMenuItem(
        value: 'profile',
        enabled: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: DefaultTextStyle(
          style: const TextStyle(inherit: false),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: widget.account.isAdmin
                    ? const Color(0xFFF3E8FF)
                    : const Color(0xFFEFF6FF),
                child: Text(
                  widget.account.displayName.isNotEmpty
                      ? widget.account.displayName.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: widget.account.isAdmin
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF0F62FE),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.account.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.account.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.account.isAdmin
                            ? const Color(0xFFF3E8FF)
                            : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.account.isAdmin ? 'Quản trị viên' : 'Người vận hành',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.account.isAdmin
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const PopupMenuDivider(height: 1),
      const PopupMenuItem(
        value: 'logout',
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              size: 17,
              color: Color(0xFFEF4444),
            ),
            SizedBox(width: 10),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: widget.account.isAdmin
                ? const Color(0xFFF3E8FF)
                : const Color(0xFFEFF6FF),
            child: Text(
              widget.account.displayName.isNotEmpty
                  ? widget.account.displayName.substring(0, 1).toUpperCase()
                  : 'U',
              style: TextStyle(
                color: widget.account.isAdmin
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFF0F62FE),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.account.displayName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: Color(0xFF64748B),
          ),
        ],
      ),
    ),
  );

  Widget _pageContent() => _loading
      ? const Center(child: CircularProgressIndicator())
      : _error != null
      ? ErrorPanel(message: _error!, onRetry: _load)
      : Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: _tab == 5
                ? AdminTab(
                    account: widget.account,
                    users: _adminUsers,
                    loading: _adminLoading,
                    onRefresh: _loadAdminUsers,
                    onToggleUserStatus: _toggleUser,
                    onToggleUserRole: _toggleUserRole,
                  )
                : _tab == 6
                ? AquacultureDiaryTab(
                    api: widget.api,
                    sites: _sites,
                    selectedSite: _selected,
                    onSelectSite: (s) => _load(siteId: s.id),
                  )
                : _tab == 1
                ? SitesTab(
                    sites: _sites,
                    selectedSite: _selected,
                    onCreateSite: _createSite,
                    onSelectSite: (site) {
                      setState(() => _tab = 0);
                      _load(siteId: site.id);
                    },
                  )
                : _tab == 2
                ? DevicesTab(
                    sites: _sites,
                    selectedSite: _selected,
                    devices: _devices,
                    onCreateSite: _createSite,
                    onCreateDevice: _createDevice,
                    onSelectSite: (s) => _load(siteId: s.id),
                  )
                : _tab == 3
                ? HistoryTab(
                    sites: _sites,
                    selectedSite: _selected,
                    history: _history,
                    chartMetric: _chartMetric,
                    historyRange: _historyRange,
                    onCreateSite: _createSite,
                    onSelectSite: (s) => _load(siteId: s.id),
                    onSelectMetric: (m) => setState(() => _chartMetric = m),
                    onSelectRange: (r) {
                      setState(() => _historyRange = r);
                      _load();
                    },
                  )
                : _tab == 4
                ? AlertsTab(
                    sites: _sites,
                    selectedSite: _selected,
                    alerts: _alerts,
                    onRefresh: _load,
                    onSelectSite: (s) => _load(siteId: s.id),
                    onCreateSite: _createSite,
                    onResolveAlert: _resolveAlert,
                  )
                : OverviewTab(
                    sites: _sites,
                    selectedSite: _selected,
                    devices: _devices,
                    latest: _latest,
                    summary: _summary,
                    history: _history,
                    chartMetric: _chartMetric,
                    historyRange: _historyRange,
                    day: _day,
                    alerts: _alerts,
                    species: _species,
                    allSpecies: _allSpecies,
                    onAddCustomSpecies: _openAddCustomSpeciesDialog,
                    onDeleteSpecies: _deleteCustomSpecies,
                    onRefresh: _load,
                    onSelectSite: (s) => _load(siteId: s.id),
                    onCreateSite: _createSite,
                    onChooseDay: _chooseDay,
                    onSelectMetric: (m) => setState(() => _chartMetric = m),
                    onSelectRange: (r) {
                      setState(() => _historyRange = r);
                      _load();
                    },
                    onViewAllAlerts: () => _selectTab(4),
                    onResolveAlert: _resolveAlert,
                    onSelectSpecies: (sp) => setState(() => _species = sp),
                    onViewActionPlan: _showActionPlan,
                  ),
          ),
        );

  void _showActionPlan() {
    final latest = _latest;
    if (latest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có số đo để phân tích phác đồ xử lý kỹ thuật.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final intervention = AquacultureIntervention.diagnose(latest, _species);
    showDialog(
      context: context,
      builder: (ctx) => AiActionPlanDialog(
        intervention: intervention,
        species: _species,
        measurement: latest,
      ),
    );
  }

  void _openSimulationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Row(
          children: [
            Icon(Icons.science_outlined, color: Color(0xFF0F62FE)),
            SizedBox(width: 8),
            Text(
              'Mô phỏng AI & Cảm biến IoT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          const Text(
            'Chọn kịch bản kiểm thử lâm sàng hoặc bảo vệ đồ án để quan sát phản ứng tức thời của AI và các giải thuật cảnh báo:',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          _simTile(
            ctx,
            title: '1. Nước tối ưu chuẩn VietGAP',
            subtitle: 'pH: 7.8 | Oxy: 6.2 mg/L | Đục: 12 NTU | 28°C',
            badge: 'TỐT',
            color: const Color(0xFF10B981),
            onTap: () => _applySimulation(ph: 7.8, doVal: 6.2, turb: 12.0, temp: 28.0, tds: 220),
          ),
          const SizedBox(height: 8),
          _simTile(
            ctx,
            title: '2. Nước bị Axit hóa (Mưa rào cuốn trôi)',
            subtitle: 'pH: 5.6 | Oxy: 4.8 mg/L | Đục: 18 NTU | 26°C',
            badge: 'CẢNH BÁO CAO',
            color: const Color(0xFFF59E0B),
            onTap: () => _applySimulation(ph: 5.6, doVal: 4.8, turb: 18.0, temp: 26.0, tds: 180),
          ),
          const SizedBox(height: 8),
          _simTile(
            ctx,
            title: '3. Khủng hoảng Thiếu Oxy ban đêm (Tảo tàn)',
            subtitle: 'pH: 7.2 | Oxy: 1.8 mg/L (Ngạt thở) | Đục: 45 NTU',
            badge: 'NGUY HIỂM',
            color: const Color(0xFFEF4444),
            onTap: () => _applySimulation(ph: 7.2, doVal: 1.8, turb: 45.0, temp: 29.5, tds: 410),
          ),
          const SizedBox(height: 8),
          _simTile(
            ctx,
            title: '4. Kiềm hóa cực đại (Tảo nở hoa bùng phát)',
            subtitle: 'pH: 9.4 | Oxy: 8.5 mg/L | Đục: 38 NTU | 32°C',
            badge: 'CẢNH BÁO CAO',
            color: const Color(0xFFEC4899),
            onTap: () => _applySimulation(ph: 9.4, doVal: 8.5, turb: 38.0, temp: 32.0, tds: 350),
          ),
        ],
      ),
    );
  }

  Widget _simTile(
    BuildContext ctx, {
    required String title,
    required String subtitle,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applySimulation({
    required double ph,
    required double doVal,
    required double turb,
    required double temp,
    required double tds,
  }) {
    final now = DateTime.now();
    final assessmentLevel = (ph < 6.0 || ph > 9.0 || doVal < 3.0)
        ? 'CRITICAL'
        : (ph < 6.5 || ph > 8.5 || doVal < 4.5 || turb > 30)
            ? 'HIGH'
            : 'GOOD';

    final simulated = WaterMeasurement(
      measuredAt: now,
      assessmentLevel: assessmentLevel,
      qualityStatus: 'VALID',
      readings: {
        'ph': ph,
        'dissolvedOxygenMgL': doVal,
        'turbidityNtu': turb,
        'temperatureC': temp,
        'tdsMgL': tds,
      },
    );

    setState(() {
      _latest = simulated;
      _history = [simulated, ..._history];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã nạp số đo mô phỏng IoT thành công ($assessmentLevel)! Bấm "Phác đồ kỹ thuật AI" để xem khuyến nghị.'),
        backgroundColor: const Color(0xFF0F62FE),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _DashboardBackgroundAccents extends StatelessWidget {
  const _DashboardBackgroundAccents();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Base Canvas Gradient with subtle tech tone
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF1F6FD), // Soft blue-tinted clean canvas
                    Color(0xFFF8FAFC), // Slate clean canvas
                    Color(0xFFEDF5FF), // Subtle aqua tint at bottom right
                  ],
                ),
              ),
            ),
          ),

          // Geometric water ripples & tech dot matrix
          Positioned.fill(
            child: CustomPaint(
              painter: _TechWaterAccentPainter(),
            ),
          ),

          // Top-right prominent cyan/aqua ambient aura
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 620,
              height: 620,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D2FF).withValues(alpha: 0.18),
                    const Color(0xFF0284C7).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Center-left electric sapphire aura
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0F62FE).withValues(alpha: 0.11),
                    const Color(0xFF38BDF8).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Bottom-right soft emerald/aqua aura
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.09),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechWaterAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Water Ripple Concentric Rings in top-right
    final rippleCenter = Offset(size.width - 60, 120);
    final ripplePaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(rippleCenter, 120, ripplePaint);
    canvas.drawCircle(rippleCenter, 240, ripplePaint);
    canvas.drawCircle(rippleCenter, 380, ripplePaint);
    canvas.drawCircle(rippleCenter, 540, ripplePaint);

    // 2. High-Tech Dot Matrix Grid in upper canvas
    final dotPaint = Paint();
    const step = 26.0;
    final maxX = size.width;
    final maxY = size.height.clamp(0.0, 520.0);

    for (double x = 30; x < maxX; x += step) {
      for (double y = 15; y < maxY; y += step) {
        final opacityFactor = (1.0 - (y / maxY)).clamp(0.0, 1.0);
        if (opacityFactor > 0.08) {
          dotPaint.color = const Color(0xFF0284C7).withValues(
            alpha: 0.10 * opacityFactor,
          );
          canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

