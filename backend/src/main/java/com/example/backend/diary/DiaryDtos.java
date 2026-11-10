package com.example.backend.diary;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

public final class DiaryDtos {
    private DiaryDtos() { }

    public record ShrimpProfileRequest(
            @NotNull @DecimalMin("1") BigDecimal areaM2,
            @NotNull @DecimalMin("0.1") BigDecimal depthM,
            @NotBlank @Size(max = 120) String shrimpSpecies,
            @NotNull Integer stockedCount,
            @NotNull LocalDate stockedOn,
            @Size(max = 64) String farmingStage,
            BigDecimal targetHarvestWeightG
    ) { }

    public record ShrimpProfileResponse(
            Long siteId,
            String siteName,
            BigDecimal areaM2,
            BigDecimal depthM,
            BigDecimal waterVolumeM3,
            String shrimpSpecies,
            Integer stockedCount,
            LocalDate stockedOn,
            Integer currentDoc,
            String farmingStage,
            BigDecimal targetHarvestWeightG,
            Double stockingDensityPerM2
    ) { }

    public record FeedingRequest(
            @NotNull Instant fedAt,
            @NotBlank @Size(max = 64) String feedMeal,
            @Size(max = 120) String feedBrand,
            @NotNull @DecimalMin("0.1") BigDecimal amountKg,
            @NotBlank @Size(max = 64) String feedTrayStatus,
            @Size(max = 2000) String notes
    ) { }

    public record FeedingResponse(
            Long id,
            Long siteId,
            Instant fedAt,
            String feedMeal,
            String feedBrand,
            BigDecimal amountKg,
            String feedTrayStatus,
            String notes
    ) {
        static FeedingResponse from(PondFeedingLog log) {
            return new FeedingResponse(
                    log.getId(),
                    log.getSite().getId(),
                    log.getFedAt(),
                    log.getFeedMeal(),
                    log.getFeedBrand(),
                    log.getAmountKg(),
                    log.getFeedTrayStatus(),
                    log.getNotes()
            );
        }
    }

    public record HealthRequest(
            @NotNull Instant loggedAt,
            Integer ageDays,
            @NotNull @DecimalMin("0.01") BigDecimal averageWeightG,
            BigDecimal estimatedSurvivalRate,
            @NotBlank @Size(max = 64) String healthStatus,
            @Size(max = 120) String gutCondition,
            @Size(max = 120) String hepatopancreas,
            @Size(max = 120) String shellCondition,
            @Size(max = 2000) String notes
    ) { }

    public record HealthResponse(
            Long id,
            Long siteId,
            Instant loggedAt,
            Integer ageDays,
            BigDecimal averageWeightG,
            Integer sizeCountPerKg,
            BigDecimal estimatedSurvivalRate,
            String healthStatus,
            String gutCondition,
            String hepatopancreas,
            String shellCondition,
            String notes
    ) {
        static HealthResponse from(ShrimpHealthLog log) {
            Integer sizeCount = null;
            if (log.getAverageWeightG() != null && log.getAverageWeightG().doubleValue() > 0) {
                sizeCount = (int) Math.round(1000.0 / log.getAverageWeightG().doubleValue());
            }
            return new HealthResponse(
                    log.getId(),
                    log.getSite().getId(),
                    log.getLoggedAt(),
                    log.getAgeDays(),
                    log.getAverageWeightG(),
                    sizeCount,
                    log.getEstimatedSurvivalRate(),
                    log.getHealthStatus(),
                    log.getGutCondition(),
                    log.getHepatopancreas(),
                    log.getShellCondition(),
                    log.getNotes()
            );
        }
    }

    public record TreatmentRequest(
            @NotNull Instant treatedAt,
            @NotBlank @Size(max = 64) String treatmentType,
            @NotBlank @Size(max = 150) String productName,
            @NotNull @DecimalMin("0.01") BigDecimal dosage,
            @NotBlank @Size(max = 32) String unit,
            @Size(max = 255) String purpose,
            @Size(max = 2000) String notes
    ) { }

    public record TreatmentResponse(
            Long id,
            Long siteId,
            Instant treatedAt,
            String treatmentType,
            String productName,
            BigDecimal dosage,
            String unit,
            String purpose,
            String notes
    ) {
        static TreatmentResponse from(PondTreatmentLog log) {
            return new TreatmentResponse(
                    log.getId(),
                    log.getSite().getId(),
                    log.getTreatedAt(),
                    log.getTreatmentType(),
                    log.getProductName(),
                    log.getDosage(),
                    log.getUnit(),
                    log.getPurpose(),
                    log.getNotes()
            );
        }
    }

    public record WaterOpRequest(
            @NotNull Instant operatedAt,
            @NotBlank @Size(max = 64) String operationType,
            BigDecimal volumeM3,
            @Size(max = 120) String waterSource,
            @Size(max = 2000) String notes
    ) { }

    public record WaterOpResponse(
            Long id,
            Long siteId,
            Instant operatedAt,
            String operationType,
            BigDecimal volumeM3,
            String waterSource,
            String notes
    ) {
        static WaterOpResponse from(PondWaterOperation log) {
            return new WaterOpResponse(
                    log.getId(),
                    log.getSite().getId(),
                    log.getOperatedAt(),
                    log.getOperationType(),
                    log.getVolumeM3(),
                    log.getWaterSource(),
                    log.getNotes()
            );
        }
    }

    public record DailyFeedPoint(
            String dateLabel,
            double amountKg,
            int mealsCount
    ) { }

    public record GrowthCurvePoint(
            int doc,
            double actualWeightG,
            double standardWeightG
    ) { }

    public record DiaryAnalyticsResponse(
            BigDecimal totalFeedKg,
            Double estimatedBiomassKg,
            Double fcr,
            Integer currentDoc,
            Double survivalRatePercent,
            Double currentAvgWeightG,
            Integer currentSizeCountPerKg,
            Long treatmentCount,
            Long waterOpCount,
            List<DailyFeedPoint> dailyFeedTrend,
            List<GrowthCurvePoint> growthCurve
    ) { }
}

