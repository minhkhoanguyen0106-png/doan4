package com.example.backend.monitor;

import org.springframework.data.jpa.repository.JpaRepository;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

public interface WaterMeasurementRepository extends JpaRepository<WaterMeasurement, Long> {
    boolean existsByDevice_IdAndMessageId(Long deviceId, String messageId);
    List<WaterMeasurement> findAllByDevice_Site_IdAndDevice_Site_Owner_EmailAndMeasuredAtGreaterThanEqualAndMeasuredAtLessThanOrderByMeasuredAtAsc(
            Long siteId, String email, Instant from, Instant to);
    List<WaterMeasurement> findAllByDevice_Site_IdAndMeasuredAtGreaterThanEqualAndMeasuredAtLessThanOrderByMeasuredAtAsc(
            Long siteId, Instant from, Instant to);
    List<WaterMeasurement> findAllByDevice_Site_IdAndDevice_Site_Owner_EmailAndMeasuredAtGreaterThanEqualAndMeasuredAtLessThanOrderByMeasuredAtDesc(
            Long siteId, String email, Instant from, Instant to, org.springframework.data.domain.Pageable pageable);
    Optional<WaterMeasurement> findFirstByDevice_Site_IdAndDevice_Site_Owner_EmailOrderByMeasuredAtDesc(Long siteId, String email);
}
