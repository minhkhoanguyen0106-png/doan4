package com.example.backend.water;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.Instant;

public interface WaterQualityRepository extends JpaRepository<WaterQualityRecord, Long> {
    @Query("select r from WaterQualityRecord r where r.pond.id = :pondId and r.pond.owner.id = :ownerId " +
            "and (:fromTime is null or r.measuredAt >= :fromTime) and (:toTime is null or r.measuredAt <= :toTime)")
    Page<WaterQualityRecord> findHistory(@Param("pondId") Long pondId, @Param("ownerId") Long ownerId,
                                        @Param("fromTime") Instant from, @Param("toTime") Instant to,
                                        Pageable pageable);
}
