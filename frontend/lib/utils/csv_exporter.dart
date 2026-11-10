import '../models/water_models.dart';
import 'exporter_stub.dart' if (dart.library.html) 'exporter_web.dart' as platform;

class CsvExporter {
  static void exportMeasurements(List<WaterMeasurement> rows, String siteName) {
    final buffer = StringBuffer();
    // UTF-8 BOM for Microsoft Excel Vietnamese character compatibility
    buffer.write('\uFEFF');
    buffer.writeln(
      'Thời gian đo,Điểm quan trắc,Độ pH,Oxy hòa tan (mg/L),Độ đục (NTU),Nhiệt độ (°C),TDS (mg/L),Đánh giá an toàn,Trạng thái dữ liệu',
    );

    for (final m in rows) {
      final ph = m.readings['ph']?.toString() ?? '';
      final doVal = m.readings['dissolvedOxygenMgL']?.toString() ?? '';
      final turb = m.readings['turbidityNtu']?.toString() ?? '';
      final temp = m.readings['temperatureC']?.toString() ?? '';
      final tds = m.readings['tdsMgL']?.toString() ?? '';
      
      final safeSite = siteName.replaceAll('"', '""');
      final timeStr = m.measuredAt.toLocal().toString().split('.').first;

      buffer.writeln(
        '"$timeStr","$safeSite",$ph,$doVal,$turb,$temp,$tds,${m.assessmentLevel},${m.qualityStatus}',
      );
    }

    final safeName = siteName.replaceAll(RegExp(r'[^a-zA-Z0-9_\u00C0-\u024F\u1E00-\u1EFF]'), '_');
    final dateSuffix = DateTime.now().toIso8601String().substring(0, 10);
    final fileName = 'PONDORA_BaoCaoQuanTrac_${safeName}_$dateSuffix.csv';

    platform.downloadCsvFile(buffer.toString(), fileName);
  }

  static void exportRawCsv(String content, String fileName) {
    platform.downloadCsvFile(content, fileName);
  }
}

