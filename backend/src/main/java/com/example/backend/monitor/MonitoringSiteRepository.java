package com.example.backend.monitor;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface MonitoringSiteRepository extends JpaRepository<MonitoringSite, Long> {
    List<MonitoringSite> findAllByOwner_EmailOrderByIdDesc(String email);
    List<MonitoringSite> findAllByStatus(String status);
    Optional<MonitoringSite> findByIdAndOwner_Email(Long id, String email);
}
