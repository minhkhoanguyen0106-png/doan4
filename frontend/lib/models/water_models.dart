export 'species_models.dart';
import 'species_models.dart';

class MonitoringSite {
  const MonitoringSite({
    required this.id,
    required this.name,
    this.location,
    required this.timezone,
    required this.status,
  });
  final int id;
  final String name;
  final String? location;
  final String timezone;
  final String status;
  factory MonitoringSite.fromJson(Map<String, dynamic> json) => MonitoringSite(
    id: json['id'] as int,
    name: json['name'] as String,
    location: json['location'] as String?,
    timezone: json['timezone'] as String? ?? 'Asia/Ho_Chi_Minh',
    status: json['status'] as String? ?? 'ACTIVE',
  );
}

class AccountUser {
  const AccountUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    this.createdAt,
  });
  final int id;
  final String email;
  final String displayName;
  final String role;
  final String status;
  final DateTime? createdAt;
  bool get isAdmin => role == 'ADMIN';
  bool get isActive => status == 'ACTIVE';
  factory AccountUser.fromJson(Map<String, dynamic> json) => AccountUser(
    id: (json['id'] as num).toInt(),
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    role: json['role'] as String? ?? 'USER',
    status: json['status'] as String? ?? 'ACTIVE',
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
  );
}

class IotDevice {
  const IotDevice({
    required this.id,
    required this.deviceCode,
    required this.name,
    required this.status,
    this.lastSeenAt,
    this.online = false,
  });
  final int id;
  final String deviceCode;
  final String name;
  final String status;
  final DateTime? lastSeenAt;
  final bool online;
  factory IotDevice.fromJson(Map<String, dynamic> json) => IotDevice(
    id: json['id'] as int,
    deviceCode: json['deviceCode'] as String,
    name: json['name'] as String,
    status: json['status'] as String? ?? 'ACTIVE',
    online: json['online'] as bool? ?? false,
    lastSeenAt: json['lastSeenAt'] == null
        ? null
        : DateTime.parse(json['lastSeenAt'] as String),
  );
}

class CreatedDevice {
  const CreatedDevice({
    required this.deviceCode,
    required this.name,
    required this.deviceToken,
  });
  final String deviceCode;
  final String name;
  final String deviceToken;
  factory CreatedDevice.fromJson(Map<String, dynamic> json) => CreatedDevice(
    deviceCode: json['deviceCode'] as String,
    name: json['name'] as String,
    deviceToken: json['deviceToken'] as String,
  );
}

class WaterMeasurement {
  const WaterMeasurement({
    required this.measuredAt,
    required this.assessmentLevel,
    required this.readings,
    this.qualityStatus = 'VALID',
  });
  final DateTime measuredAt;
  final String assessmentLevel;
  final Map<String, num?> readings;
  final String qualityStatus;
  factory WaterMeasurement.fromJson(Map<String, dynamic> json) {
    final values = Map<String, dynamic>.from(json['readings'] as Map);
    return WaterMeasurement(
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      assessmentLevel:
          json['assessmentLevel'] as String? ?? 'INSUFFICIENT_DATA',
      qualityStatus: json['qualityStatus'] as String? ?? 'VALID',
      readings: values.map((key, value) {
        if (value is num) return MapEntry(key, value);
        return MapEntry(key, null);
      }),
    );
  }
}

class MetricStats {
  const MetricStats({required this.count, this.min, this.average, this.max});
  final int count;
  final num? min;
  final num? average;
  final num? max;
  factory MetricStats.fromJson(dynamic json) {
    if (json is! Map) return const MetricStats(count: 0);
    return MetricStats(
      count: (json['count'] as num?)?.toInt() ?? 0,
      min: json['min'] as num?,
      average: json['average'] as num?,
      max: json['max'] as num?,
    );
  }
}

class DailySummary {
  const DailySummary({
    required this.date,
    required this.sampleCount,
    required this.screeningLevel,
    required this.temperature,
    required this.ph,
    required this.oxygen,
    required this.turbidity,
    required this.tds,
  });
  final String date;
  final int sampleCount;
  final String screeningLevel;
  final MetricStats temperature;
  final MetricStats ph;
  final MetricStats oxygen;
  final MetricStats turbidity;
  final MetricStats tds;
  factory DailySummary.fromJson(Map<String, dynamic> json) => DailySummary(
    date: json['date'] as String,
    sampleCount: (json['sampleCount'] as num?)?.toInt() ?? 0,
    screeningLevel: json['screeningLevel'] as String? ?? 'INSUFFICIENT_DATA',
    temperature: MetricStats.fromJson(json['temperatureC']),
    ph: MetricStats.fromJson(json['ph']),
    oxygen: MetricStats.fromJson(json['dissolvedOxygenMgL']),
    turbidity: MetricStats.fromJson(json['turbidityNtu']),
    tds: MetricStats.fromJson(json['tdsMgL']),
  );
}

class WaterAlert {
  const WaterAlert({
    required this.id,
    required this.siteId,
    required this.siteName,
    this.deviceId,
    this.deviceCode,
    this.deviceName,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    required this.status,
    required this.triggeredAt,
    this.resolvedAt,
  });

  final int id;
  final int siteId;
  final String siteName;
  final int? deviceId;
  final String? deviceCode;
  final String? deviceName;
  final String alertType;
  final String severity;
  final String title;
  final String message;
  final String status;
  final DateTime triggeredAt;
  final DateTime? resolvedAt;

  bool get isActive => status == 'ACTIVE';
  bool get isCritical => severity == 'CRITICAL';
  bool get isHigh => severity == 'HIGH';
  bool get isWatch => severity == 'WATCH';

  factory WaterAlert.fromJson(Map<String, dynamic> json) => WaterAlert(
    id: (json['id'] as num).toInt(),
    siteId: (json['siteId'] as num).toInt(),
    siteName: json['siteName'] as String? ?? '',
    deviceId: (json['deviceId'] as num?)?.toInt(),
    deviceCode: json['deviceCode'] as String?,
    deviceName: json['deviceName'] as String?,
    alertType: json['alertType'] as String? ?? 'WATER_QUALITY',
    severity: json['severity'] as String? ?? 'WATCH',
    title: json['title'] as String? ?? '',
    message: json['message'] as String? ?? '',
    status: json['status'] as String? ?? 'ACTIVE',
    triggeredAt: DateTime.parse(json['triggeredAt'] as String),
    resolvedAt: json['resolvedAt'] == null
        ? null
        : DateTime.parse(json['resolvedAt'] as String),
  );
}

class AlertStats {
  const AlertStats({
    required this.activeCount,
    required this.criticalCount,
    required this.highCount,
    required this.watchCount,
  });

  final int activeCount;
  final int criticalCount;
  final int highCount;
  final int watchCount;

  factory AlertStats.fromJson(Map<String, dynamic> json) => AlertStats(
    activeCount: (json['activeCount'] as num?)?.toInt() ?? 0,
    criticalCount: (json['criticalCount'] as num?)?.toInt() ?? 0,
    highCount: (json['highCount'] as num?)?.toInt() ?? 0,
    watchCount: (json['watchCount'] as num?)?.toInt() ?? 0,
  );
}

class AquacultureIntervention {
  const AquacultureIntervention({
    required this.title,
    required this.severityLabel,
    required this.diagnosis,
    required this.immediateStep,
    required this.chemicalTreatment,
    required this.feedingGuidance,
    required this.preventiveMeasure,
  });

  final String title;
  final String severityLabel;
  final String diagnosis;
  final String immediateStep;
  final String chemicalTreatment;
  final String feedingGuidance;
  final String preventiveMeasure;

  static AquacultureIntervention diagnose(WaterMeasurement? m, AquacultureSpecies species) {
    if (m == null) {
      return const AquacultureIntervention(
        title: 'Chưa có dữ liệu cảm biến',
        severityLabel: 'CHỜ DỮ LIỆU',
        diagnosis: 'Hệ thống đang sẵn sàng tiếp nhận số đo từ trạm IoT ESP32 hoặc ThingSpeak.',
        immediateStep: 'Kiểm tra nguồn điện ESP32 và đảm bảo cảm biến đã cắm đúng kết nối.',
        chemicalTreatment: 'Duy trì chế độ quạt nước thông thường theo chu kỳ sinh học ao.',
        feedingGuidance: 'Cho ăn theo biểu đồ thông thường của trang trại.',
        preventiveMeasure: 'Định kỳ vệ sinh đầu que đo pH và kiểm tra dây dẫn tín hiệu.',
      );
    }

    final ph = m.readings['ph'];
    final doVal = m.readings['dissolvedOxygenMgL'];

    if (ph != null && ph > species.optimalPhMax) {
      return AquacultureIntervention(
        title: 'Nước có tính Kiềm cao (pH = ${ph.toStringAsFixed(1)}) — Nguy cơ độc tính NH₃',
        severityLabel: 'NGUY CẤP',
        diagnosis: 'Tảo nở hoa quang hợp mạnh lúc trưa chiều làm pH vọt cao, chuyển hóa ion NH₄⁺ thành khí độc tự do NH₃ gây bỏng mang, ngạt khí và tổn thương thần kinh ${species.name.toLowerCase()}.',
        immediateStep: 'Bật 100% hệ thống quạt nước để tăng lưu chuyển nước tầng mặt, đẩy khí độc tích tụ thoát ra không khí.',
        chemicalTreatment: '1. Giải độc & giảm sốc cấp bách: Dùng EDTA (2–3 kg/1000m³) hòa nước tạt đều ao để khử kim loại, làm mềm nước và giảm độc tính khí độc.\n2. Hạ pH & cắt tảo sinh học: Tạt men vi sinh ủ mật rỉ đường (chế phẩm sinh học EM / Bacillus subtilis) liều 3–5 kg/1000m³ lúc 8–10h sáng để hạ pH an toàn về 7.8–8.2. Trường hợp kiềm quá cao có thể bổ sung Acid Citric 1–2 kg/1000m³.',
        feedingGuidance: 'Cắt giảm ngay 50% lượng thức ăn trong ngày, tuyệt đối không cho ăn các cữ trưa và chiều gắt.',
        preventiveMeasure: 'Thay 15–20% lượng nước tầng đáy nếu ao có hố xi-phông, kiểm soát màu nước trà nhạt (theo khuyến cáo Tạp chí Thủy sản Việt Nam).',
      );
    }

    if (ph != null && ph < species.optimalPhMin) {
      return AquacultureIntervention(
        title: 'Nước nhiễm Axit / Phèn (pH = ${ph.toStringAsFixed(1)}) — Dưới ngưỡng sinh trưởng',
        severityLabel: 'CẢNH BÁO CAO',
        diagnosis: 'Nước chua, xì phèn sau mưa hoặc đáy ao tích tụ hữu cơ phân hủy sinh acid, làm ${species.name.toLowerCase()} mềm vỏ, giảm bắt mồi và dễ nhiễm nấm ký sinh.',
        immediateStep: 'Sục khí tăng cường để hỗ trợ hô hấp, rải vôi nông nghiệp quanh bờ ao tránh nước mưa rửa trôi phèn vào ao.',
        chemicalTreatment: '1. Khử phèn & kết tủa kim loại: Tạt EDTA liều 2–3 kg/1000m³ để khử phèn sắt/nhôm, chống nhớt nước.\n2. Nâng kiềm & ổn định pH: Sau 2 tiếng tạt vôi CaCO₃ hoặc Dolomite liều 15–20 kg/1000m³ hòa nước tạt đều ao lúc chiều mát.',
        feedingGuidance: 'Giảm 30% thức ăn, trộn thêm Vitamin C và Beta-Glucan để tăng đề kháng chống sốc phèn.',
        preventiveMeasure: 'Bón vôi định kỳ dọc bờ ao trước các cơn mưa dông lớn.',
      );
    }

    if (doVal != null && doVal < species.optimalDoMin) {
      return AquacultureIntervention(
        title: 'Sụt giảm Oxy hòa tan cấp (DO = ${doVal.toStringAsFixed(1)} mg/L)',
        severityLabel: 'NGUY HIỂM',
        diagnosis: 'Nồng độ oxy dưới ${species.optimalDoMin} mg/L khiến ${species.name.toLowerCase()} nổi đầu, stress ngạt khí, ngưng tiêu hóa và nguy cơ hao hụt hàng loạt rạng sáng.',
        immediateStep: 'Kích hoạt ngay 100% dàn quạt nước và thiết bị sục khí đáy nano-tube.',
        chemicalTreatment: 'Tạt oxy viên cấp cứu (Sodium Percarbonate) 1–2 kg/1000m³ ngay khu vực tập trung nuôi.',
        feedingGuidance: 'Ngưng hoàn toàn việc cho ăn cho đến khi nồng độ DO ổn định trở lại trên 4.0 mg/L.',
        preventiveMeasure: 'Thường xuyên xi-phông loại bỏ bùn đáy và thức ăn thối rữa làm tiêu hao dưỡng khí.',
      );
    }

    return AquacultureIntervention(
      title: 'Chất lượng nước tối ưu cho ${species.name}',
      severityLabel: 'AN TOÀN',
      diagnosis: 'Các chỉ số pH, Oxy và nhiệt độ nằm hoàn toàn trong ngưỡng sinh trưởng lý tưởng theo QCVN 02-19:2014.',
      immediateStep: 'Duy trì vận hành hệ thống quạt nước và cảm biến quan trắc định kỳ.',
      chemicalTreatment: 'Định kỳ 7–10 ngày bổ sung vi sinh có lợi (Bacillus subtilis) để duy trì chất lượng nước.',
      feedingGuidance: 'Cho ăn đúng định lượng theo bảng khẩu phần thể trọng.',
      preventiveMeasure: 'Theo dõi thường xuyên các biến động thời tiết chuyển mùa.',
    );
  }
}
