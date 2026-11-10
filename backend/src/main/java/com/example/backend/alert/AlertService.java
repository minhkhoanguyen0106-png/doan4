package com.example.backend.alert;

import com.example.backend.monitor.IotDevice;
import com.example.backend.monitor.MeasurementDtos;
import com.example.backend.monitor.MonitoringService;
import com.example.backend.monitor.MonitoringSite;
import com.example.backend.monitor.WaterAssessmentService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;

@Service
public class AlertService {
    private final WaterAlertRepository alerts;
    private final MonitoringService monitoring;

    public AlertService(WaterAlertRepository alerts, MonitoringService monitoring) {
        this.alerts = alerts;
        this.monitoring = monitoring;
    }

    @Transactional(readOnly = true)
    public List<AlertDtos.AlertResponse> listAlerts(String email, Long siteId, String status) {
        monitoring.ownedSite(email, siteId);
        List<WaterAlert> list = (status != null && !status.isBlank())
                ? alerts.findAllBySite_IdAndSite_Owner_EmailAndStatusOrderByTriggeredAtDesc(siteId, email, status.toUpperCase())
                : alerts.findAllBySite_IdAndSite_Owner_EmailOrderByTriggeredAtDesc(siteId, email);
        return list.stream().map(AlertDtos.AlertResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public AlertDtos.AlertStatsResponse getStats(String email, Long siteId) {
        monitoring.ownedSite(email, siteId);
        long active = alerts.countBySite_IdAndSite_Owner_EmailAndStatus(siteId, email, "ACTIVE");
        long critical = alerts.countBySite_IdAndSite_Owner_EmailAndStatusAndSeverity(siteId, email, "ACTIVE", "CRITICAL");
        long high = alerts.countBySite_IdAndSite_Owner_EmailAndStatusAndSeverity(siteId, email, "ACTIVE", "HIGH");
        long watch = alerts.countBySite_IdAndSite_Owner_EmailAndStatusAndSeverity(siteId, email, "ACTIVE", "WATCH");
        return new AlertDtos.AlertStatsResponse(active, critical, high, watch);
    }

    @Transactional
    public AlertDtos.AlertResponse resolveAlert(String email, Long siteId, Long alertId) {
        monitoring.ownedSite(email, siteId);
        WaterAlert alert = alerts.findByIdAndSite_Owner_Email(alertId, email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Alert not found"));
        if (!alert.getSite().getId().equals(siteId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Alert does not belong to site");
        }
        alert.resolve(Instant.now());
        return AlertDtos.AlertResponse.from(alerts.save(alert));
    }

    @Transactional
    public void recordQualityAlert(MonitoringSite site, IotDevice device, String assessmentLevel,
                                   MeasurementDtos.Readings readings, Instant measuredAt) {
        if ("GOOD".equals(assessmentLevel)) {
            // Auto resolve active quality alert if readings returned to normal
            List<WaterAlert> activeAlerts = alerts.findAllByDevice_IdAndAlertTypeAndStatus(device.getId(), "WATER_QUALITY", "ACTIVE");
            for (WaterAlert a : activeAlerts) {
                a.resolve(Instant.now());
            }
            if (!activeAlerts.isEmpty()) {
                alerts.saveAll(activeAlerts);
            }
            return;
        }

        String title;
        StringBuilder detail = new StringBuilder();

        double temp = readings.temperatureC() != null ? readings.temperatureC().doubleValue() : 28.0;
        double nh3Pct = readings.ph() != null ? WaterAssessmentService.calculateToxicNH3Percent(readings.ph().doubleValue(), temp) : 0.0;
        Double salinity = readings.tdsMgL() != null ? WaterAssessmentService.calculateSalinityPpt(readings.tdsMgL().doubleValue()) : null;

        // Custom domain logic for aquaculture parameters
        if (nh3Pct >= 5.0) {
            // Ammonia Toxicity Alarm
            if (nh3Pct >= 20.0) {
                title = "Nguy cấp: Khí độc NH3 bộc phát cực độ (" + String.format(java.util.Locale.US, "%.1f", nh3Pct) + "%)!";
            } else if (nh3Pct >= 10.0) {
                title = "Cảnh báo cao: Khí độc Amonia (NH3) nguy hại (" + String.format(java.util.Locale.US, "%.1f", nh3Pct) + "%)!";
            } else {
                title = "Lưu ý: Tỷ lệ khí độc NH3 đang tăng (" + String.format(java.util.Locale.US, "%.1f", nh3Pct) + "%)";
            }
            detail.append("Chỉ số khí độc NH3 tự do: ").append(String.format(java.util.Locale.US, "%.2f", nh3Pct)).append("% (Ngưỡng an toàn ao nuôi: < 5%).\n")
                  .append("• Rủi ro sinh học: Khí NH3 tự do khuếch tán qua màng mang tôm gây hoại tử biểu mô hô hấp, tổn thương gan tụy và ngạt thở.\n")
                  .append("• Phác đồ xử lý tức thời:\n")
                  .append("  1. Tạt EDTA liều 2-3 kg/1000m³ để khử độc tố nước, lắng bọt váng và giảm độ nhớt.\n")
                  .append("  2. Đánh mật rỉ đường (3-5 kg/1000m³) kết hợp vi sinh Probiotics (Bacillus) vào 9-10h sáng để hạ pH và khống chế tảo.\n")
                  .append("  3. Giảm 30-50% lượng thức ăn, bật tối đa quạt nước để giải phóng khí độc.");
        } else if (salinity != null && (salinity < 8.0 || salinity > 28.0)) {
            // Salinity Alarm
            if (salinity < 5.0) {
                title = "Cảnh báo: Độ mặn ao tụt thấp (" + String.format(java.util.Locale.US, "%.1f", salinity) + " ‰) - Nguy cơ sốc nước ngọt!";
                detail.append("Chỉ số độ mặn đo được: ").append(String.format(java.util.Locale.US, "%.1f", salinity)).append(" ‰ (Ngưỡng tối ưu: 10 – 25 ‰).\n")
                      .append("• Rủi ro: Nước bị ngọt hóa khiến tôm mất cân bằng áp suất thẩm thấu, mềm vỏ, cong thân đục cơ.\n")
                      .append("• Phác đồ xử lý: Bổ sung khoáng tạt chuyên dụng (CaCl2, MgSO4), cấp thêm nước mặn hoặc bón vôi Dolomite.");
            } else {
                title = "Cảnh báo: Độ mặn ao tăng cao (" + String.format(java.util.Locale.US, "%.1f", salinity) + " ‰)!";
                detail.append("Chỉ số độ mặn đo được: ").append(String.format(java.util.Locale.US, "%.1f", salinity)).append(" ‰ (Ngưỡng tối ưu: 10 – 25 ‰).\n")
                      .append("• Rủi ro: Tôm bị mất nước tế bào, chậm lớn, vỏ dày cứng khó lột xác.\n")
                      .append("• Phác đồ xử lý: Cấp bổ sung nước ngọt lắng sạch để hạ dần độ mặn từ từ 1-2 ‰ mỗi ngày.");
            }
        } else if (readings.ph() != null && readings.ph().compareTo(new java.math.BigDecimal("7.5")) < 0) {
            if ("CRITICAL".equals(assessmentLevel)) {
                title = "Nguy cấp: pH ao chạm đáy (" + readings.ph() + ") - Sốc axit/nhiễm phèn!";
            } else if ("HIGH".equals(assessmentLevel)) {
                title = "Cảnh báo cao: pH tụt thấp (" + readings.ph() + ") - Dưới ngưỡng an toàn 7.5!";
            } else {
                title = "Lưu ý: pH ao nuôi giảm (" + readings.ph() + ") - Cần theo dõi";
            }
            detail.append("Chỉ số pH thực tế: ").append(readings.ph()).append(" (Ngưỡng tối ưu ao nuôi: 7.5 - 8.5).\n")
                  .append("• Rủi ro sinh học: Nước mang tính axit làm gia tăng độc tính khí H2S từ bùn đáy ao, ức chế hấp thụ khoáng khiến tôm khó lột xác, mềm vỏ và bỏ ăn.\n")
                  .append("• Phác đồ xử lý tức thời:\n")
                  .append("  1. Bón vôi nông nghiệp CaCO3 hoặc Dolomite (10-15 kg/1000m³) để nâng pH và ổn định kiềm.\n")
                  .append("  2. Bật tối đa quạt nước và sục khí oxy đáy ao giải phóng khí độc.\n")
                  .append("  3. Sử dụng EDTA (2-3 kg/1000m³) để khử phèn, khử kim loại nặng, làm mềm nước hỗ trợ tôm lột xác an toàn.");
        } else if (readings.ph() != null && readings.ph().compareTo(new java.math.BigDecimal("8.5")) > 0) {
            if ("CRITICAL".equals(assessmentLevel)) {
                title = "Nguy cấp: pH kiềm hóa cực đại (" + readings.ph() + ") - Khí độc NH3 bộc phát!";
            } else if ("HIGH".equals(assessmentLevel)) {
                title = "Cảnh báo cao: pH quá cao (" + readings.ph() + ") - Nguy cơ ngộ độc Amonia!";
            } else {
                title = "Lưu ý: pH ao nuôi tăng cao (" + readings.ph() + ")";
            }
            detail.append("Chỉ số pH thực tế: ").append(readings.ph()).append(" (Ngưỡng tối ưu ao nuôi: 7.5 - 8.5).\n")
                  .append("• Rủi ro sinh học: Theo mô hình Soft Sensor cân bằng NH4+ <-> NH3, pH cao chuyển hóa ion Amoni thành khí độc Amonia (NH3) tự do cực độc gây tổn thương mang tôm và hoại tử gan tụy.\n")
                  .append("• Phác đồ xử lý tức thời:\n")
                  .append("  1. Đánh mật rỉ đường (3-5 kg/1000m³) kết hợp ủ men vi sinh Probiotics (Bacillus) vào 9-10h sáng để hạ pH tự nhiên.\n")
                  .append("  2. Sử dụng EDTA giải độc nước ao, giảm nhớt và lắng bọt váng.\n")
                  .append("  3. Cắt giảm 30-50% lượng thức ăn, cấp thêm nước sạch.");
        } else {
            title = switch (assessmentLevel) {
                case "CRITICAL" -> "Nguy cấp: Chất lượng nước vượt ngưỡng an toàn nghiêm trọng!";
                case "HIGH" -> "Cảnh báo cao: Chỉ số nước ao bất thường!";
                case "WATCH" -> "Lưu ý: Chỉ số nước cần theo dõi";
                default -> "Chỉ số nước bất thường";
            };
            detail.append("Chỉ số đo được: ");
            if (readings.ph() != null) detail.append("pH=").append(readings.ph()).append("; ");
            if (readings.dissolvedOxygenMgL() != null) detail.append("DO=").append(readings.dissolvedOxygenMgL()).append(" mg/L; ");
            if (readings.turbidityNtu() != null) detail.append("Độ đục=").append(readings.turbidityNtu()).append(" NTU; ");
            if (readings.tdsMgL() != null) detail.append("TDS=").append(readings.tdsMgL()).append(" mg/L; ");
            if (readings.temperatureC() != null) detail.append("Nhiệt độ=").append(readings.temperatureC()).append("°C; ");
        }

        // Only create or update if WATCH, HIGH, or CRITICAL
        var existing = alerts.findFirstBySite_IdAndDevice_IdAndAlertTypeAndStatus(site.getId(), device.getId(), "WATER_QUALITY", "ACTIVE");
        if (existing.isPresent()) {
            WaterAlert alert = existing.get();
            alert.updateDetails(assessmentLevel, title, detail.toString().trim(), measuredAt);
            alerts.save(alert);
            return;
        }

        WaterAlert alert = new WaterAlert(site, device, "WATER_QUALITY", assessmentLevel, title, detail.toString().trim(), measuredAt);
        alerts.save(alert);
    }

    @Transactional
    public void recordDeviceOffline(IotDevice device, Instant at) {
        var existing = alerts.findFirstBySite_IdAndDevice_IdAndAlertTypeAndStatus(device.getSite().getId(), device.getId(), "DEVICE_OFFLINE", "ACTIVE");
        if (existing.isPresent()) return;

        String title = "Mất kết nối: Thiết bị " + device.getName() + " ngừng gửi tín hiệu";
        String message = "Thiết bị " + device.getDeviceCode() + " không gửi dữ liệu quá thời gian quy định.";
        WaterAlert alert = new WaterAlert(device.getSite(), device, "DEVICE_OFFLINE", "HIGH", title, message, at);
        alerts.save(alert);
    }

    @Transactional
    public void resolveDeviceOffline(IotDevice device) {
        List<WaterAlert> activeOffline = alerts.findAllByDevice_IdAndAlertTypeAndStatus(device.getId(), "DEVICE_OFFLINE", "ACTIVE");
        if (!activeOffline.isEmpty()) {
            Instant now = Instant.now();
            for (WaterAlert a : activeOffline) {
                a.resolve(now);
            }
            alerts.saveAll(activeOffline);
        }
    }
}

