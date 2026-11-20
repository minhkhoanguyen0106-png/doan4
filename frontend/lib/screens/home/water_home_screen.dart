import 'dart:async';
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
import '../../services/alarm_sound_service.dart';
import '../../widgets/common_views.dart';
import '../../widgets/sidebar.dart';
import '../tabs/admin_tab.dart';
import '../tabs/alerts_tab.dart';
import '../tabs/aquaculture_diary_tab.dart';
import '../tabs/devices_tab.dart';
import '../tabs/history_tab.dart';
import '../tabs/landing_tab.dart';
import '../tabs/overview_tab.dart';
import '../tabs/sites_tab.dart';
import '../../widgets/underwater_ambient_canvas.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  OceanLightingMode _lightingMode = OceanLightingMode.abyssal;
  int _tab = 7;
  bool _loading = true;
  bool _isSimulating = false;
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
  Timer? _realtimeTimer;
  DateTime? _lastAlarmSoundTime;
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
    // Real-time automatic streaming: silently poll every 3 seconds without spinner blinking
    _realtimeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && !_loading) {
        _load(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({int? siteId, bool silent = false}) async {
    if (!silent) {
      _isSimulating = false;
      ScaffoldMessenger.of(context).clearSnackBars();
      setState(() {
        _loading = true;
        _error = null;
      });
    }
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

        final activeAlerts = alerts.where((a) => a.isActive).toList();
        if (activeAlerts.isNotEmpty) {
          final now = DateTime.now();
          if (_lastAlarmSoundTime == null || now.difference(_lastAlarmSoundTime!).inSeconds >= 20) {
            _lastAlarmSoundTime = now;
            final highestSeverity = activeAlerts.any((a) => a.isCritical)
                ? 'CRITICAL'
                : (activeAlerts.any((a) => a.isHigh) ? 'HIGH' : 'WATCH');
            AlarmSoundService.playAlarm(severity: highestSeverity);
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _sites = sites;
        _selected = chosen;
        _devices = devices;
        if (!_isSimulating) {
          _latest = latest;
          _summary = summary;
          _history = history;
          _alerts = alerts;
        }
        _loading = false;
      });
    } catch (e) {
      if (mounted && !silent) {
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
      7 => 'Trang chủ',
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
          key: _scaffoldKey,
          appBar: desktop || _tab == 7
              ? null
              : AppBar(
                  titleSpacing: 8,
                  backgroundColor: _lightingMode == OceanLightingMode.abyssal
                      ? Colors.white
                      : const Color(0xFF081226),
                  foregroundColor: _lightingMode == OceanLightingMode.abyssal
                      ? const Color(0xFF0F172A)
                      : Colors.white,
                  elevation: 0,
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
                      tooltip: _isSimulating ? 'Đang mô phỏng IoT (Bấm để đổi kịch bản / Tắt)' : 'Mô phỏng AI & Cảm biến IoT',
                      onPressed: _openSimulationDialog,
                      icon: Icon(
                        _isSimulating ? Icons.science_rounded : Icons.science_outlined,
                        color: _isSimulating ? const Color(0xFFF59E0B) : const Color(0xFF0F62FE),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Làm mới dữ liệu',
                      onPressed: _loading ? null : _load,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    _accountMenu(),
                    const SizedBox(width: 8),
                  ],
                ),
          drawer: Drawer(
            width: 280,
            backgroundColor: const Color(0xFF081226),
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
                isAbyss: _lightingMode == OceanLightingMode.abyssal,
                onToggleLighting: () => setState(() => _lightingMode = _lightingMode == OceanLightingMode.abyssal ? OceanLightingMode.sunlit : OceanLightingMode.abyssal),
                lightingMode: _lightingMode,
                onRefresh: _load,
                onSimulate: _openSimulationDialog,
                isSimulating: _isSimulating,
              ),
            ),
          ),
          body: _tab == 7
              ? LandingTab(
                  latest: _latest,
                  lightingMode: _lightingMode,
                  onToggleLighting: () => setState(() => _lightingMode = _lightingMode == OceanLightingMode.abyssal ? OceanLightingMode.sunlit : OceanLightingMode.abyssal),
                  onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onNavigateToOverview: () => _selectTab(0),
                  onNavigateToDiary: () => _selectTab(6),
                  onNavigateToSites: () => _selectTab(1),
                  onViewActionPlan: _showActionPlan,
                  onSimulate: _openSimulationDialog,
                )
              : UnderwaterAmbientBackground(
                  lightingMode: _lightingMode,
                  onToggleLighting: () => setState(() => _lightingMode = _lightingMode == OceanLightingMode.abyssal ? OceanLightingMode.sunlit : OceanLightingMode.abyssal),
                  child: desktop
                      ? Row(
                          children: [
                            WaterSidebar(
                              selectedIndex: _tab,
                              onSelect: _selectTab,
                              isAdmin: widget.account.isAdmin,
                              account: widget.account,
                              onCreateSite: _createSite,
                              isAbyss: _lightingMode == OceanLightingMode.abyssal,
                              onLogout: widget.onLogout,
                              activeAlertCount: activeAlertCount,
                              onToggleLighting: () => setState(() => _lightingMode = _lightingMode == OceanLightingMode.abyssal ? OceanLightingMode.sunlit : OceanLightingMode.abyssal),
                              lightingMode: _lightingMode,
                              onRefresh: _load,
                              onSimulate: _openSimulationDialog,
                              isSimulating: _isSimulating,
                            ),
                            Expanded(child: _pageContent()),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(child: _pageContent()),
                          ],
                        ),
                ),
          floatingActionButton: desktop || _tab == 7
              ? null
              : _tab == 1
              ? FloatingActionButton.extended(
                  onPressed: _createSite,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Thêm điểm'),
                )
              : _tab == 2 && _selected != null
              ? FloatingActionButton.extended(
                  onPressed: _createDevice,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thiết bị'),
                )
              : null,
          bottomNavigationBar: desktop || _tab == 7
              ? null
              : NavigationBarTheme(
                  data: NavigationBarThemeData(
                    height: 64,
                    backgroundColor: const Color(0xFF081226),
                    indicatorColor: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontSize: 9.5,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF94A3B8),
                      );
                    }),
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        size: 21,
                        color: selected
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF94A3B8),
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
      : _tab == 7
      ? LandingTab(
          latest: _latest,
          lightingMode: _lightingMode,
          onToggleLighting: () => setState(() => _lightingMode = _lightingMode == OceanLightingMode.abyssal ? OceanLightingMode.sunlit : OceanLightingMode.abyssal),
          onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
          onNavigateToOverview: () => _selectTab(0),
          onNavigateToDiary: () => _selectTab(6),
          onNavigateToSites: () => _selectTab(1),
          onViewActionPlan: _showActionPlan,
          onSimulate: _openSimulationDialog,
        )
      : Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: _tab == 5
                ? AdminTab(
                    lightingMode: _lightingMode,
                    account: widget.account,
                    users: _adminUsers,
                    loading: _adminLoading,
                    onRefresh: _loadAdminUsers,
                    onToggleUserStatus: _toggleUser,
                    onToggleUserRole: _toggleUserRole,
                    onSimulate: _openSimulationDialog,
                  )
                : _tab == 6
                ? AquacultureDiaryTab(
                    lightingMode: _lightingMode,
                    api: widget.api,
                    sites: _sites,
                    selectedSite: _selected,
                    onSelectSite: (s) => _load(siteId: s.id),
                  )
                : _tab == 1
                ? SitesTab(
                    lightingMode: _lightingMode,
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
                    lightingMode: _lightingMode,
                    sites: _sites,
                    selectedSite: _selected,
                    devices: _devices,
                    onCreateSite: _createSite,
                    onCreateDevice: _createDevice,
                    onSelectSite: (s) => _load(siteId: s.id),
                  )
                : _tab == 3
                ? HistoryTab(
                    lightingMode: _lightingMode,
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
                    lightingMode: _lightingMode,
                    sites: _sites,
                    selectedSite: _selected,
                    alerts: _alerts,
                    onRefresh: _load,
                    onSelectSite: (s) => _load(siteId: s.id),
                    onCreateSite: _createSite,
                    onResolveAlert: _resolveAlert,
                  )
                : OverviewTab(
                    lightingMode: _lightingMode,
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
                    onSimulate: _openSimulationDialog,
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
          if (_isSimulating) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đang bật chế độ mô phỏng số liệu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Các chỉ số đang được AI kiểm thử theo kịch bản.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _stopSimulation();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC2626),
                    ),
                    child: const Text('Tắt mô phỏng'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
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

  void _stopSimulation() {
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _isSimulating = false;
    });
    _load();
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
    // Xóa triệt để mọi thanh thông báo snackbar (yêu cầu: "chỉnh cho cái này mất")
    ScaffoldMessenger.of(context).clearSnackBars();

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

    final simulatedSummary = DailySummary(
      date: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      sampleCount: (_summary?.sampleCount ?? 0) + 1,
      screeningLevel: assessmentLevel,
      temperature: MetricStats(count: 1, min: temp, average: temp, max: temp),
      ph: MetricStats(count: 1, min: ph, average: ph, max: ph),
      oxygen: MetricStats(count: 1, min: doVal, average: doVal, max: doVal),
      turbidity: MetricStats(count: 1, min: turb, average: turb, max: turb),
      tds: MetricStats(count: 1, min: tds, average: tds, max: tds),
    );

    // Sinh các cảnh báo mẫu tương ứng để giao diện cảnh báo hoạt động chuẩn xác
    final currentSiteId = _selected?.id ?? 1;
    final currentSiteName = _selected?.name ?? 'Ao nuôi mô phỏng';
    List<WaterAlert> simulatedAlerts = [];
    if (doVal < 3.0) {
      simulatedAlerts.add(WaterAlert(
        id: 991,
        siteId: currentSiteId,
        siteName: currentSiteName,
        alertType: 'WATER_QUALITY',
        title: 'Thiếu oxy khẩn cấp (${doVal.toStringAsFixed(1)} mg/L)',
        message: 'Oxy hòa tan giảm sâu dưới ngưỡng sống của tôm. Bật quạt nước & rải oxy viên ngay!',
        severity: 'CRITICAL',
        status: 'ACTIVE',
        triggeredAt: now,
      ));
    }
    if (ph < 6.5) {
      simulatedAlerts.add(WaterAlert(
        id: 992,
        siteId: currentSiteId,
        siteName: currentSiteName,
        alertType: 'WATER_QUALITY',
        title: 'Nước bị axit hóa (pH ${ph.toStringAsFixed(1)})',
        message: 'Độ pH thấp do nước mưa xả phèn bờ ao. Cần tạt vôi CaCO3 để nâng pH lên 7.5 - 8.2.',
        severity: 'HIGH',
        status: 'ACTIVE',
        triggeredAt: now,
      ));
    } else if (ph > 8.8) {
      simulatedAlerts.add(WaterAlert(
        id: 993,
        siteId: currentSiteId,
        siteName: currentSiteName,
        alertType: 'WATER_QUALITY',
        title: 'Kiềm hóa cực đại (pH ${ph.toStringAsFixed(1)})',
        message: 'Tảo nở hoa mạnh làm pH tăng vọt. Cần thay nước tầng mặt hoặc dùng mật đường hạ pH.',
        severity: 'HIGH',
        status: 'ACTIVE',
        triggeredAt: now,
      ));
    }

    setState(() {
      _isSimulating = true;
      _latest = simulated;
      _summary = simulatedSummary;
      _history = [simulated, ..._history];
      if (simulatedAlerts.isNotEmpty) {
        _alerts = simulatedAlerts;
      }
      _tab = 0; // Chuyển về tab Tổng quan để cập nhật giao diện đo
    });
  }
}

