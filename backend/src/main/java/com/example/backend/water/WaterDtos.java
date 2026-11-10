package com.example.backend.water;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.Instant;

public final class WaterDtos {
    private WaterDtos() { }
    public record CreateRequest(@NotNull Instant measuredAt, Long batchId,
                                BigDecimal temperatureC,
                                @DecimalMin("0") @DecimalMax("14") BigDecimal ph,
                                @DecimalMin("0") BigDecimal dissolvedOxygenMgL,
                                @DecimalMin("0") BigDecimal waterLevelM,
                                @DecimalMin("0") BigDecimal turbidityNtu,
                                @Size(max = 5000) String notes) { }
    public record Response(Long id, Long pondId, Long batchId, Instant measuredAt,
                           BigDecimal temperatureC, BigDecimal ph, BigDecimal dissolvedOxygenMgL,
                           BigDecimal waterLevelM, BigDecimal turbidityNtu, String source, String notes) {
        static Response from(WaterQualityRecord record) {
            return new Response(record.getId(), record.getPondId(), record.getBatchId(), record.getMeasuredAt(),
                    record.getTemperatureC(), record.getPh(), record.getDissolvedOxygenMgL(),
                    record.getWaterLevelM(), record.getTurbidityNtu(), record.getSource(), record.getNotes());
        }
    }
}
