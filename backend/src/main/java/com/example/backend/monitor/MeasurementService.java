package com.example.backend.monitor;

import com.example.backend.alert.AlertService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;

@Service
public class MeasurementService {
    private final WaterMeasurementRepository measurements;
    private final DailyWaterSummaryRepository summaries;
    private final MonitoringService monitoring;
    private final PasswordEncoder encoder;
    private final WaterAssessmentService assessment;
    private final AlertService alertService;
    private final int minimumDailySamples;

    public MeasurementService(WaterMeasurementRepository measurements, DailyWaterSummaryRepository summaries,
                              MonitoringService monitoring, PasswordEncoder encoder, WaterAssessmentService assessment,
                              AlertService alertService,
                              @Value("${monitoring.minimum-daily-samples:24}") int minimumDailySamples) {
        this.measurements = measurements;
        this.summaries = summaries;
        this.monitoring = monitoring;
        this.encoder = encoder;
        this.assessment = assessment;
        this.alertService = alertService;
        this.minimumDailySamples = Math.max(1, minimumDailySamples);
    }

    @Transactional
    public MeasurementDtos.MeasurementResponse ingest(String deviceCode, String token, MeasurementDtos.IngestRequest request) {
        IotDevice device = monitoring.activeDevice(deviceCode);
        if (token == null || !encoder.matches(token, device.getTokenHash()))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid device credentials");
        if (MeasurementDtos.Readings.isAllEmpty(request.readings()))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "At least one sensor reading is required");
        if (request.measuredAt().isAfter(Instant.now().plusSeconds(300)))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Measurement timestamp is too far in the future");
        if (measurements.existsByDevice_IdAndMessageId(device.getId(), request.messageId()))
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Duplicate messageId");

        String level = assessment.assess(request.readings());
        WaterMeasurement saved = measurements.save(new WaterMeasurement(device, request, "VALID", level, WaterAssessmentService.THRESHOLD_VERSION));
        device.markSeen(Instant.now());

        // Alert integration: auto-resolve offline alerts & trigger quality alerts if abnormal
        alertService.resolveDeviceOffline(device);
        alertService.recordQualityAlert(device.getSite(), device, level, request.readings(), request.measuredAt());

        return MeasurementDtos.MeasurementResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public Optional<MeasurementDtos.MeasurementResponse> latest(String email, Long siteId) {
        monitoring.ownedSite(email, siteId);
        return measurements.findFirstByDevice_Site_IdAndDevice_Site_Owner_EmailOrderByMeasuredAtDesc(siteId, email)
                .map(MeasurementDtos.MeasurementResponse::from);
    }

    @Transactional(readOnly = true)
    public List<MeasurementDtos.MeasurementResponse> history(String email, Long siteId, Instant from, Instant to, int limit) {
        monitoring.ownedSite(email, siteId);
        if (from == null || to == null || from.isAfter(to) || limit < 1 || limit > 1000)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Provide a valid from/to range and limit between 1 and 1000");
        return measurements.findAllByDevice_Site_IdAndDevice_Site_Owner_EmailAndMeasuredAtGreaterThanEqualAndMeasuredAtLessThanOrderByMeasuredAtDesc(
                siteId, email, from, to, org.springframework.data.domain.PageRequest.of(0, limit)).stream()
                .map(MeasurementDtos.MeasurementResponse::from).toList();
    }

    @Transactional
    public MeasurementDtos.DailySummary daily(String email, Long siteId, LocalDate date) {
        MonitoringSite site = monitoring.ownedSite(email, siteId);
        return summarizeSiteDate(site, date);
    }

    @Transactional
    public MeasurementDtos.DailySummary summarizeSiteDate(MonitoringSite site, LocalDate date) {
        Long siteId = site.getId();
        ZoneId zone = ZoneId.of(site.getTimezone());
        Instant from = date.atStartOfDay(zone).toInstant();
        Instant to = date.plusDays(1).atStartOfDay(zone).toInstant();
        List<WaterMeasurement> rows = measurements.findAllByDevice_Site_IdAndMeasuredAtGreaterThanEqualAndMeasuredAtLessThanOrderByMeasuredAtAsc(siteId, from, to);
        String level = rows.size() < minimumDailySamples ? "INSUFFICIENT_DATA" : rows.stream().map(WaterMeasurement::getAssessmentLevel)
                .reduce("GOOD", WaterAssessmentService::worst);
        var temp = stats(rows, WaterMeasurement::getTemperatureC);
        var ph = stats(rows, WaterMeasurement::getPh);
        var oxygen = stats(rows, WaterMeasurement::getDissolvedOxygenMgL);
        var turbidity = stats(rows, WaterMeasurement::getTurbidityNtu);
        var tds = stats(rows, WaterMeasurement::getTdsMgL);
        String json = "{" + "\"temperatureC\":" + metricJson(temp) + "," + "\"ph\":" + metricJson(ph) + "," +
                "\"dissolvedOxygenMgL\":" + metricJson(oxygen) + "," + "\"turbidityNtu\":" + metricJson(turbidity) + "," +
                "\"tdsMgL\":" + metricJson(tds) + "}";
        DailyWaterSummary summary = summaries.findBySite_IdAndLocalDateAndThresholdVersion(siteId, date, WaterAssessmentService.THRESHOLD_VERSION)
                .orElseGet(() -> new DailyWaterSummary(site, date, rows.size(), level, WaterAssessmentService.THRESHOLD_VERSION, json));
        summary.refresh(rows.size(), level, json);
        summaries.save(summary);
        return new MeasurementDtos.DailySummary(siteId, site.getName(), date.toString(), site.getTimezone(), rows.size(), level,
                WaterAssessmentService.THRESHOLD_VERSION, temp, ph, oxygen, turbidity, tds);
    }

    private String metricJson(MeasurementDtos.MetricStats s) {
        return "{\"count\":" + s.count() + ",\"min\":" + numberJson(s.min()) + ",\"average\":" + numberJson(s.average()) + ",\"max\":" + numberJson(s.max()) + "}";
    }

    private String numberJson(BigDecimal value) {
        return value == null ? "null" : value.toPlainString();
    }

    private MeasurementDtos.MetricStats stats(List<WaterMeasurement> rows, Function<WaterMeasurement, BigDecimal> value) {
        List<BigDecimal> values = rows.stream().filter(r -> "VALID".equals(r.getQualityStatus())).map(value).filter(Objects::nonNull).toList();
        if (values.isEmpty()) return new MeasurementDtos.MetricStats(0, null, null, null);
        BigDecimal sum = values.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        return new MeasurementDtos.MetricStats(values.size(), values.stream().min(BigDecimal::compareTo).orElseThrow(),
                sum.divide(BigDecimal.valueOf(values.size()), 3, RoundingMode.HALF_UP), values.stream().max(BigDecimal::compareTo).orElseThrow());
    }
}
