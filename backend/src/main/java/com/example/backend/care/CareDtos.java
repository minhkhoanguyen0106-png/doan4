package com.example.backend.care;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.Instant;

public final class CareDtos {
    private CareDtos() { }
    public record FeedingRequest(@NotNull Instant fedAt, @NotBlank @Size(max = 120) String feedType,
                                @NotNull @DecimalMin(value = "0", inclusive = false) BigDecimal amountKg,
                                @NotNull @Positive Integer feedingsCount, @Size(max = 5000) String notes) { }
    public record WaterChangeRequest(@NotNull Instant changedAt,
                                     @DecimalMin(value = "0", inclusive = false) @DecimalMax("100") BigDecimal changedPercent,
                                     @Size(max = 120) String method, @Size(max = 255) String reason,
                                     @Size(max = 5000) String notes) { }
    public record FeedingResponse(Long id, Long batchId, Instant fedAt, String feedType,
                                  BigDecimal amountKg, Integer feedingsCount, String notes) {
        static FeedingResponse from(FeedingLog log) { return new FeedingResponse(log.getId(), log.getBatchId(),
                log.getFedAt(), log.getFeedType(), log.getAmountKg(), log.getFeedingsCount(), log.getNotes()); }
    }
    public record WaterChangeResponse(Long id, Long batchId, Instant changedAt, BigDecimal changedPercent,
                                      String method, String reason, String notes) {
        static WaterChangeResponse from(WaterChangeLog log) { return new WaterChangeResponse(log.getId(), log.getBatchId(),
                log.getChangedAt(), log.getChangedPercent(), log.getMethod(), log.getReason(), log.getNotes()); }
    }
}
