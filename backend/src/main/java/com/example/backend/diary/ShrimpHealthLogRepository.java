package com.example.backend.diary;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ShrimpHealthLogRepository extends JpaRepository<ShrimpHealthLog, Long> {
    List<ShrimpHealthLog> findAllBySite_IdOrderByLoggedAtDesc(Long siteId);
    List<ShrimpHealthLog> findAllBySite_IdOrderByLoggedAtAsc(Long siteId);
    Optional<ShrimpHealthLog> findFirstBySite_IdOrderByLoggedAtDesc(Long siteId);
    long countBySite_Id(Long siteId);
}

