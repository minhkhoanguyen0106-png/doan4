package com.example.backend.pond;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;

public final class PondDtos {
    private PondDtos() { }

    public record PondRequest(
            @NotBlank @Size(max = 120) String name,
            @NotNull @DecimalMin(value = "0.0", inclusive = false) BigDecimal areaM2,
            @NotNull @DecimalMin(value = "0.0", inclusive = false) BigDecimal depthM,
            @Size(max = 120) String fishSpecies,
            @PositiveOrZero Integer initialFishCount,
            LocalDate startedOn,
            @Size(max = 255) String location,
            @Size(max = 5000) String notes) { }

    public record PondResponse(Long id, String name, BigDecimal areaM2, BigDecimal depthM,
                               String fishSpecies, Integer initialFishCount, LocalDate startedOn,
                               String location, String notes, PondStatus status) {
        public static PondResponse from(Pond pond) {
            return new PondResponse(pond.getId(), pond.getName(), pond.getAreaM2(), pond.getDepthM(),
                    pond.getFishSpecies(), pond.getInitialFishCount(), pond.getStartedOn(),
                    pond.getLocation(), pond.getNotes(), pond.getStatus());
        }
    }
}
