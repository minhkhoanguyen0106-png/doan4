package com.example.backend.batch;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;

public final class BatchDtos {
    private BatchDtos() { }
    public record CreateRequest(@NotBlank @Size(max = 120) String fishSpecies,
                                @NotNull @Positive Integer stockedCount,
                                @NotNull LocalDate stockedOn,
                                @Size(max = 255) String source,
                                @Size(max = 5000) String notes) { }
    public record CompleteRequest(@NotNull LocalDate endedOn,
                                  @PositiveOrZero Integer harvestedCount,
                                  @DecimalMin("0.0") BigDecimal harvestWeightKg,
                                  @Size(max = 5000) String notes) { }
    public record Response(Long id, Long pondId, String fishSpecies, Integer stockedCount,
                           LocalDate stockedOn, String source, String notes, BatchStatus status,
                           LocalDate endedOn, Integer harvestedCount, BigDecimal harvestWeightKg) {
        public static Response from(FishBatch batch) {
            return new Response(batch.getId(), batch.getPond().getId(), batch.getFishSpecies(),
                    batch.getStockedCount(), batch.getStockedOn(), batch.getSource(), batch.getNotes(),
                    batch.getStatus(), batch.getEndedOn(), batch.getHarvestedCount(), batch.getHarvestWeightKg());
        }
    }
}
