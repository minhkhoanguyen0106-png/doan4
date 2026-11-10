package com.example.backend.monitor;

import com.example.backend.alert.AlertService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

@Component
public class DailyAggregationScheduler {
    private static final Logger log = LoggerFactory.getLogger(DailyAggregationScheduler.class);

    private final MonitoringSiteRepository sites;
    private final IotDeviceRepository devices;
    private final MeasurementService measurementService;
    private final AlertService alertService;
    private final Duration offlineTimeout;

    public DailyAggregationScheduler(
            MonitoringSiteRepository sites,
            IotDeviceRepository devices,
            MeasurementService measurementService,
            AlertService alertService,
            @Value("${monitoring.device-offline-timeout:300s}") Duration offlineTimeout) {
        this.sites = sites;
        this.devices = devices;
        this.measurementService = measurementService;
        this.alertService = alertService;
        this.offlineTimeout = offlineTimeout;
    }

    /**
     * Run at 00:05 every day to finalize yesterday's daily summary for all active monitoring sites.
     */
    @Scheduled(cron = "0 5 0 * * *")
    public void aggregateYesterdayForAllSites() {
        log.info("Starting daily midnight aggregation for yesterday's measurements...");
        List<MonitoringSite> activeSites = sites.findAllByStatus("ACTIVE");
        for (MonitoringSite site : activeSites) {
            try {
                ZoneId zone = ZoneId.of(site.getTimezone());
                LocalDate yesterday = LocalDate.now(zone).minusDays(1);
                measurementService.summarizeSiteDate(site, yesterday);
                log.info("Aggregated yesterday summary for site [{}] date [{}]", site.getName(), yesterday);
            } catch (Exception e) {
                log.error("Failed to aggregate daily summary for site id {}: {}", site.getId(), e.getMessage());
            }
        }
    }

    /**
     * Run every 30 minutes to keep today's real-time summary refreshed in database.
     */
    @Scheduled(fixedRate = 1800000, initialDelay = 10000)
    public void aggregateTodayForAllSites() {
        List<MonitoringSite> activeSites = sites.findAllByStatus("ACTIVE");
        for (MonitoringSite site : activeSites) {
            try {
                ZoneId zone = ZoneId.of(site.getTimezone());
                LocalDate today = LocalDate.now(zone);
                measurementService.summarizeSiteDate(site, today);
            } catch (Exception e) {
                log.error("Failed to refresh today's summary for site id {}: {}", site.getId(), e.getMessage());
            }
        }
    }

    /**
     * Run every 60 seconds to detect devices that stopped sending data and trigger offline alerts.
     */
    @Scheduled(fixedRate = 60000, initialDelay = 15000)
    public void monitorDeviceHealth() {
        List<IotDevice> activeDevices = devices.findAllByStatus("ACTIVE");
        Instant threshold = Instant.now().minus(offlineTimeout);
        for (IotDevice device : activeDevices) {
            try {
                if (device.getLastSeenAt() != null && device.getLastSeenAt().isBefore(threshold)) {
                    alertService.recordDeviceOffline(device, Instant.now());
                }
            } catch (Exception e) {
                log.error("Error checking device health for device {}: {}", device.getDeviceCode(), e.getMessage());
            }
        }
    }
}

