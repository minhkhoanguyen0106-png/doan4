import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/diary_models.dart';
import '../models/water_models.dart';

class ApiClient {
  ApiClient({http.Client? client, FlutterSecureStorage? storage})
    : _http = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  final http.Client _http;
  final FlutterSecureStorage _storage;
  static const _emailKey = 'auth.email';
  static const _passwordKey = 'auth.password';
  static const _configuredUrl = String.fromEnvironment('API_BASE_URL');

  String get baseUrl {
    if (_configuredUrl.isNotEmpty) {
      return _configuredUrl.replaceAll(RegExp(r'/$'), '');
    }
    if (kIsWeb) {
      return Uri.base.origin;
    }
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'http://localhost:8080';
    }
    return 'http://10.0.2.2:8080';
  }

  Future<bool> get hasSavedCredentials async =>
      await _storage.read(key: _emailKey) != null &&
      await _storage.read(key: _passwordKey) != null;

  Future<void> register(String name, String email, String password) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'displayName': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );
    if (response.statusCode != 201) _throwApiError(response);
    await login(email, password);
  }

  Future<void> login(String email, String password) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );
    if (response.statusCode != 200) _throwApiError(response);
    await _storage.write(key: _emailKey, value: email.trim());
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<void> sendOtp(String email, {String? purpose}) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/api/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'purpose': purpose ?? '',
      }),
    );
    if (response.statusCode != 200) _throwApiError(response);
  }

  Future<void> verifyOtpAndLogin({
    required String email,
    required String code,
    String? displayName,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'code': code.trim(),
        if (displayName != null && displayName.trim().isNotEmpty)
          'displayName': displayName.trim(),
      }),
    );
    if (response.statusCode != 200) _throwApiError(response);
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final sessionToken = data['sessionToken'] as String;
    await _storage.write(key: _emailKey, value: email.trim());
    await _storage.write(key: _passwordKey, value: sessionToken);
  }

  Future<void> loginWithGoogle({
    required String email,
    String? displayName,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/api/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        if (displayName != null && displayName.trim().isNotEmpty)
          'displayName': displayName.trim(),
      }),
    );
    if (response.statusCode != 200) _throwApiError(response);
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final sessionToken = data['sessionToken'] as String;
    await _storage.write(key: _emailKey, value: email.trim());
    await _storage.write(key: _passwordKey, value: sessionToken);
  }

  Future<void> logout() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }

  Future<AccountUser> me() async =>
      AccountUser.fromJson(await _get('/api/auth/me'));

  Future<List<AccountUser>> adminUsers() async {
    final data = await _get('/api/admin/users');
    return (data as List).map((item) => AccountUser.fromJson(item)).toList();
  }

  Future<AccountUser> setUserStatus(int id, String status) async =>
      AccountUser.fromJson(
        await _request(
          'PATCH',
          '/api/admin/users/$id/status',
          body: {'status': status},
        ),
      );

  Future<AccountUser> setUserRole(int id, String role) async =>
      AccountUser.fromJson(
        await _request(
          'PATCH',
          '/api/admin/users/$id/role',
          body: {'role': role},
        ),
      );

  Future<List<MonitoringSite>> sites() async {
    final data = await _get('/api/sites');
    return (data as List).map((item) => MonitoringSite.fromJson(item)).toList();
  }

  Future<MonitoringSite> createSite({
    required String name,
    String? location,
    required String timezone,
    String? notes,
  }) async {
    final data = await _request(
      'POST',
      '/api/sites',
      body: {
        'name': name,
        'location': location,
        'timezone': timezone,
        'notes': notes,
      },
    );
    return MonitoringSite.fromJson(data);
  }

  Future<List<IotDevice>> devices(int siteId) async {
    final data = await _get('/api/sites/$siteId/devices');
    return (data as List).map((item) => IotDevice.fromJson(item)).toList();
  }

  Future<CreatedDevice> createDevice(int siteId, String name) async {
    final data = await _request(
      'POST',
      '/api/sites/$siteId/devices',
      body: {'name': name},
    );
    return CreatedDevice.fromJson(data);
  }

  Future<WaterMeasurement?> latest(int siteId) async {
    final data = await _get('/api/sites/$siteId/measurements/latest');
    if (data == null) return null;
    return WaterMeasurement.fromJson(data);
  }

  Future<List<WaterMeasurement>> history(
    int siteId, {
    required DateTime from,
    required DateTime to,
    int limit = 500,
  }) async {
    final query = Uri(
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
        'limit': '$limit',
      },
    ).query;
    final data = await _get('/api/sites/$siteId/measurements?$query');
    return (data as List)
        .map((item) => WaterMeasurement.fromJson(item))
        .toList();
  }

  Future<DailySummary> dailySummary(int siteId, DateTime day) async {
    final date =
        '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
    final data = await _get('/api/sites/$siteId/daily-summary?date=$date');
    return DailySummary.fromJson(data);
  }

  Future<List<WaterAlert>> alerts(int siteId, {String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final data = await _get('/api/sites/$siteId/alerts$query');
    return (data as List).map((item) => WaterAlert.fromJson(item)).toList();
  }

  Future<AlertStats> alertStats(int siteId) async {
    final data = await _get('/api/sites/$siteId/alerts/stats');
    return AlertStats.fromJson(data);
  }

  Future<WaterAlert> resolveAlert(int siteId, int alertId) async {
    final data = await _request('PATCH', '/api/sites/$siteId/alerts/$alertId/resolve');
    return WaterAlert.fromJson(data);
  }

  // ================= AQUACULTURE DIARY & SHRIMP OPERATIONS =================
  Future<ShrimpProfile> getShrimpProfile(int siteId) async {
    final data = await _get('/api/sites/$siteId/diary/profile');
    return ShrimpProfile.fromJson(data);
  }

  Future<ShrimpProfile> updateShrimpProfile(int siteId, Map<String, dynamic> data) async {
    final res = await _request('PUT', '/api/sites/$siteId/diary/profile', body: data);
    return ShrimpProfile.fromJson(res);
  }

  Future<List<PondFeedingLog>> getFeedings(int siteId) async {
    final data = await _get('/api/sites/$siteId/diary/feedings');
    return (data as List).map((i) => PondFeedingLog.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<PondFeedingLog> addFeeding(int siteId, Map<String, dynamic> data) async {
    final res = await _request('POST', '/api/sites/$siteId/diary/feedings', body: data);
    return PondFeedingLog.fromJson(res);
  }

  Future<void> deleteFeeding(int siteId, int logId) async {
    await _request('DELETE', '/api/sites/$siteId/diary/feedings/$logId');
  }

  Future<List<ShrimpHealthLog>> getHealthLogs(int siteId) async {
    final data = await _get('/api/sites/$siteId/diary/health-logs');
    return (data as List).map((i) => ShrimpHealthLog.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<ShrimpHealthLog> addHealthLog(int siteId, Map<String, dynamic> data) async {
    final res = await _request('POST', '/api/sites/$siteId/diary/health-logs', body: data);
    return ShrimpHealthLog.fromJson(res);
  }

  Future<void> deleteHealthLog(int siteId, int logId) async {
    await _request('DELETE', '/api/sites/$siteId/diary/health-logs/$logId');
  }

  Future<List<PondTreatmentLog>> getTreatments(int siteId) async {
    final data = await _get('/api/sites/$siteId/diary/treatments');
    return (data as List).map((i) => PondTreatmentLog.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<PondTreatmentLog> addTreatment(int siteId, Map<String, dynamic> data) async {
    final res = await _request('POST', '/api/sites/$siteId/diary/treatments', body: data);
    return PondTreatmentLog.fromJson(res);
  }

  Future<void> deleteTreatment(int siteId, int logId) async {
    await _request('DELETE', '/api/sites/$siteId/diary/treatments/$logId');
  }

  Future<List<PondWaterOperation>> getWaterOps(int siteId) async {
    final data = await _get('/api/sites/$siteId/diary/water-operations');
    return (data as List).map((i) => PondWaterOperation.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<PondWaterOperation> addWaterOp(int siteId, Map<String, dynamic> data) async {
    final res = await _request('POST', '/api/sites/$siteId/diary/water-operations', body: data);
    return PondWaterOperation.fromJson(res);
  }

  Future<void> deleteWaterOp(int siteId, int logId) async {
    await _request('DELETE', '/api/sites/$siteId/diary/water-operations/$logId');
  }

  Future<DiaryAnalytics> getDiaryAnalytics(int siteId) async {
    final data = await _get('/api/sites/$siteId/diary/analytics');
    return DiaryAnalytics.fromJson(data);
  }

  Future<dynamic> _get(String path) => _request('GET', path);

  Future<dynamic> _request(String method, String path, {Object? body}) async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    if (email == null || password == null) {
      throw const ApiException('Vui lòng đăng nhập lại.');
    }
    final auth = base64Encode(utf8.encode('$email:$password'));
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Authorization': 'Basic $auth',
      'Accept': 'application/json',
    };
    if (body != null) headers['Content-Type'] = 'application/json';
    final response = switch (method) {
      'POST' => await _http.post(uri, headers: headers, body: jsonEncode(body)),
      'PUT' => await _http.put(uri, headers: headers, body: jsonEncode(body)),
      'DELETE' => await _http.delete(uri, headers: headers),
      'PATCH' => await _http.patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ),
      _ => await _http.get(uri, headers: headers),
    };
    if (response.statusCode == 401) {
      await logout();
      throw const ApiException(
        'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwApiError(response);
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Never _throwApiError(http.Response response) {
    String message = 'Máy chủ trả về lỗi ${response.statusCode}.';
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is Map<String, dynamic>) {
        message =
            (payload['detail'] ??
                    payload['message'] ??
                    payload['error'] ??
                    message)
                .toString();
      }
    } catch (_) {
      if (response.statusCode == 401) {
        message = 'Email hoặc mật khẩu không đúng.';
      }
    }
    throw ApiException(message);
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
