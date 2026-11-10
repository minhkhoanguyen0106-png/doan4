package com.example.backend.alert;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface WaterAlertRepository extends JpaRepository<WaterAlert, Long> {
    List<WaterAlert> findAllBySite_IdAndSite_Owner_EmailOrderByTriggeredAtDesc(Long siteId, String email);
    List<WaterAlert> findAllBySite_IdAndSite_Owner_EmailAndStatusOrderByTriggeredAtDesc(Long siteId, String email, String status);
    long countBySite_IdAndSite_Owner_EmailAndStatus(Long siteId, String email, String status);
    long countBySite_IdAndSite_Owner_EmailAndStatusAndSeverity(Long siteId, String email, String status, String severity);
    Optional<WaterAlert> findByIdAndSite_Owner_Email(Long id, String email);
    Optional<WaterAlert> findFirstBySite_IdAndDevice_IdAndAlertTypeAndStatus(Long siteId, Long deviceId, String alertType, String status);
    List<WaterAlert> findAllByDevice_IdAndAlertTypeAndStatus(Long deviceId, String alertType, String status);
    List<WaterAlert> findAllBySite_IdAndAlertTypeAndStatus(Long siteId, String alertType, String status);
}

