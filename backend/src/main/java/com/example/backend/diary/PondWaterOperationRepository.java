package com.example.backend.diary;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PondWaterOperationRepository extends JpaRepository<PondWaterOperation, Long> {
    List<PondWaterOperation> findAllBySite_IdOrderByOperatedAtDesc(Long siteId);
    long countBySite_Id(Long siteId);
}

