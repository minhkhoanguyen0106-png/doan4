package com.example.backend.monitor;

import com.example.backend.alert.AlertService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class ThingSpeakSyncService {
    private static final Logger log = LoggerFactory.getLogger(ThingSpeakSyncService.class);

    private static final Pattern ENTRY_ID_PATTERN = Pattern.compile("\"entry_id\":\\s*(\\d+)");
    private static final Pattern FIELD1_PATTERN = Pattern.compile("\"field1\":\\s*\"?([0-9.]+)\"?");
    private static final Pattern FIELD2_PATTERN = Pattern.compile("\"field2\":\\s*\"?([0-9.]+)\"?");
    private static final Pattern CREATED_AT_PATTERN = Pattern.compile("\"created_at\":\\s*\"([^\"]+)\"");

    private final MonitoringSiteRepository sites;
    private final IotDeviceRepository devices;
    private final WaterMeasurementRepository measurements;
    private final WaterAssessmentService assessment;
    private final AlertService alertService;
    private final HttpClient httpClient;

    @Value("${thingspeak.enabled:true}")
    private boolean enabled;

    @Value("${thingspeak.channel-id:3565054}")
    private long channelId;

    @Value("${thingspeak.read-api-key:Q7FZ4N89G0037O1I}")
    private String readApiKey;

    private long lastSyncedEntryId = -1;

    public ThingSpeakSyncService(
            MonitoringSiteRepository sites,
            IotDeviceRepository devices,
            WaterMeasurementRepository measurements,
            WaterAssessmentService assessment,
            AlertService alertService) {
        this.sites = sites;
        this.devices = devices;
        this.measurements = measurements;
        this.assessment = assessment;
        this.alertService = alertService;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();
    }

    /**
     * Poll ThingSpeak every 15 seconds to pull fresh sensor telemetry
     */
    @Scheduled(fixedRateString = "${thingspeak.poll-interval-ms:15000}")
    @Transactional
    public void syncFromThingSpeak() {
        if (!enabled) return;

        try {
            String url = String.format("https://api.thingspeak.com/channels/%d/feeds.json?api_key=%s&results=1", channelId, readApiKey);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(8))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                log.warn("[ThingSpeak Sync] Received HTTP status {} from ThingSpeak API", response.statusCode());
                return;
            }

            String body = response.body();
            if (body == null || body.isBlank() || body.contains("\"feeds\":[]")) {
                return;
            }

            // Extract entry_id
            Matcher entryMatcher = ENTRY_ID_PATTERN.matcher(body);
            long entryId = -1;
            while (entryMatcher.find()) {
                entryId = Long.parseLong(entryMatcher.group(1));
            }
            if (entryId <= 0 || entryId <= lastSyncedEntryId) {
                return;
            }

            // Extract field1 (pH)
            Matcher field1Matcher = FIELD1_PATTERN.matcher(body);
            String phStr = null;
            while (field1Matcher.find()) {
                phStr = field1Matcher.group(1);
            }
            if (phStr == null || phStr.isBlank()) {
                return;
            }

            BigDecimal ph = new BigDecimal(phStr.trim());

            // Extract field2 (Temperature from To pin)
            Matcher field2Matcher = FIELD2_PATTERN.matcher(body);
            BigDecimal temperatureC = null;
            while (field2Matcher.find()) {
                String tempStr = field2Matcher.group(1);
                if (tempStr != null && !tempStr.isBlank()) {
                    try {
                        temperatureC = new BigDecimal(tempStr.trim());
                    } catch (Exception ignored) {
                    }
                }
            }

            // Extract created_at
            Matcher createdMatcher = CREATED_AT_PATTERN.matcher(body);
            Instant measuredAt = Instant.now();
            while (createdMatcher.find()) {
                try {
                    measuredAt = Instant.parse(createdMatcher.group(1));
                } catch (Exception ignored) {
                }
            }

            // Find or associate with active IoT devices so telemetry displays on all monitored sites
            List<IotDevice> targetDevices = devices.findAllByStatus("ACTIVE");
            if (targetDevices.isEmpty()) {
                IotDevice defaultDevice = getOrCreateThingSpeakDevice();
                if (defaultDevice != null) {
                    targetDevices = List.of(defaultDevice);
                }
            }

            var readings = new MeasurementDtos.Readings(temperatureC, ph, null, null, null);
            String level = assessment.assess(readings);

            for (IotDevice dev : targetDevices) {
                String messageId = "TS-" + channelId + "-" + entryId + "-" + dev.getId();
                if (measurements.existsByDevice_IdAndMessageId(dev.getId(), messageId)) {
                    continue;
                }

                var ingestRequest = new MeasurementDtos.IngestRequest(messageId, measuredAt, readings);
                WaterMeasurement measurement = new WaterMeasurement(
                        dev,
                        ingestRequest,
                        "VALID",
                        level,
                        WaterAssessmentService.THRESHOLD_VERSION
                );

                measurements.save(measurement);
                dev.markSeen(Instant.now());
                devices.save(dev);

                alertService.resolveDeviceOffline(dev);
                alertService.recordQualityAlert(dev.getSite(), dev, level, readings, measuredAt);

                log.info("[ThingSpeak Sync] >> SUCCESS: Entry #{} -> pH: {} (Level: {}) for device [{}] at site [{}]",
                        entryId, ph, level, dev.getName(), dev.getSite().getName());
            }

            lastSyncedEntryId = entryId;

        } catch (Exception e) {
            log.error("[ThingSpeak Sync] Failed to poll ThingSpeak: {}", e.getMessage());
        }
    }

    private IotDevice getOrCreateThingSpeakDevice() {
        String deviceCode = "TS-ESP32-" + channelId;
        return devices.findByDeviceCode(deviceCode).orElseGet(() -> {
            List<MonitoringSite> activeSites = sites.findAllByStatus("ACTIVE");
            if (activeSites.isEmpty()) {
                activeSites = sites.findAll();
            }
            if (activeSites.isEmpty()) {
                return null;
            }
            MonitoringSite site = activeSites.get(0);
            IotDevice newDevice = new IotDevice(
                    site,
                    deviceCode,
                    "Trạm đo ThingSpeak (" + channelId + ")",
                    "$2a$10$thingspeak.auto.provisioned.device"
            );
            newDevice.markSeen(Instant.now());
            return devices.save(newDevice);
        });
    }
}
