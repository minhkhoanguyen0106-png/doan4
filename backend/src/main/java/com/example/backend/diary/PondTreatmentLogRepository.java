package com.example.backend.diary;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PondTreatmentLogRepository extends JpaRepository<PondTreatmentLog, Long> {
    List<PondTreatmentLog> findAllBySite_IdOrderByTreatedAtDesc(Long siteId);
    long countBySite_Id(Long siteId);
}

