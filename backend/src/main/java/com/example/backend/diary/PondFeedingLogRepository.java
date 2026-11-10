package com.example.backend.diary;

import org.springframework.data.jpa.repository.JpaRepository;
import java.time.Instant;
import java.util.List;

public interface PondFeedingLogRepository extends JpaRepository<PondFeedingLog, Long> {
    List<PondFeedingLog> findAllBySite_IdOrderByFedAtDesc(Long siteId);
    List<PondFeedingLog> findAllBySite_IdAndFedAtBetweenOrderByFedAtAsc(Long siteId, Instant start, Instant end);
    long countBySite_Id(Long siteId);
}

