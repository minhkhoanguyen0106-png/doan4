package com.example.backend.monitor;

import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.Optional;

public interface DailyWaterSummaryRepository extends JpaRepository<DailyWaterSummary, Long> {
    Optional<DailyWaterSummary> findBySite_IdAndLocalDateAndThresholdVersion(Long siteId, LocalDate localDate, int thresholdVersion);
}
