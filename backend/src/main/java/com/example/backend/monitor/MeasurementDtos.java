package com.example.backend.monitor;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.Instant;

public final class MeasurementDtos {
    private MeasurementDtos() { }
    public record Readings(@DecimalMin("-5") @DecimalMax("60") BigDecimal temperatureC,
                           @DecimalMin("0") @DecimalMax("14") BigDecimal ph,
                           @DecimalMin("0") @DecimalMax("50") BigDecimal dissolvedOxygenMgL,
                           @DecimalMin("0") BigDecimal turbidityNtu,
                           @DecimalMin("0") BigDecimal tdsMgL) {
        public static boolean isAllEmpty(Readings r) {
            return r == null || (r.temperatureC == null && r.ph == null && r.dissolvedOxygenMgL == null && r.turbidityNtu == null && r.tdsMgL == null);
        }
    }
    public record IngestRequest(@NotBlank @Size(max = 100) String messageId, @NotNull Instant measuredAt,
                                @NotNull @Valid Readings readings) { }
    public record MeasurementResponse(Long id, String deviceCode, String siteName, String messageId,
            Instant measuredAt, Instant receivedAt, Readings readings, String qualityStatus,
            String assessmentLevel, int thresholdVersion) {
        static MeasurementResponse from(WaterMeasurement m) {
            return new MeasurementResponse(m.getId(), m.getDevice().getDeviceCode(), m.getDevice().getSite().getName(), m.getMessageId(),
                    m.getMeasuredAt(), m.getReceivedAt(), new Readings(m.getTemperatureC(), m.getPh(), m.getDissolvedOxygenMgL(), m.getTurbidityNtu(), m.getTdsMgL()),
                    m.getQualityStatus(), m.getAssessmentLevel(), m.getThresholdVersion());
        }
    }
    public record MetricStats(long count, BigDecimal min, BigDecimal average, BigDecimal max) { }
    public record DailySummary(Long siteId, String siteName, String date, String timezone, long sampleCount,
                               String screeningLevel, int thresholdVersion, MetricStats temperatureC, MetricStats ph,
                               MetricStats dissolvedOxygenMgL, MetricStats turbidityNtu, MetricStats tdsMgL) { }
}
