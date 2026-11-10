package com.example.backend.alert;

import com.example.backend.monitor.IotDevice;
import com.example.backend.monitor.MeasurementDtos;
import com.example.backend.monitor.MonitoringService;
import com.example.backend.monitor.MonitoringSite;
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

        // Only create or update if WATCH, HIGH, or CRITICAL
        var existing = alerts.findFirstBySite_IdAndDevice_IdAndAlertTypeAndStatus(site.getId(), device.getId(), "WATER_QUALITY", "ACTIVE");
        if (existing.isPresent()) {
            return; // Already actively alerted for this device
        }

        StringBuilder detail = new StringBuilder("Phát hiện bất thường: ");
        if (readings.ph() != null) detail.append("pH=").append(readings.ph()).append("; ");
        if (readings.dissolvedOxygenMgL() != null) detail.append("DO=").append(readings.dissolvedOxygenMgL()).append(" mg/L; ");
        if (readings.turbidityNtu() != null) detail.append("Độ đục=").append(readings.turbidityNtu()).append(" NTU; ");
        if (readings.tdsMgL() != null) detail.append("TDS=").append(readings.tdsMgL()).append(" mg/L; ");
        if (readings.temperatureC() != null) detail.append("Nhiệt độ=").append(readings.temperatureC()).append("°C; ");

        String title = switch (assessmentLevel) {
            case "CRITICAL" -> "Nguy cấp: Chất lượng nước vượt ngưỡng nghiêm trọng!";
            case "HIGH" -> "Cảnh báo cao: Chỉ số nước ô nhiễm cao!";
            case "WATCH" -> "Lưu ý: Chỉ số nước cần theo dõi";
            default -> "Chỉ số nước bất thường";
        };

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

