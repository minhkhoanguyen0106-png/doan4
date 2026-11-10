package com.example.backend.batch;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface FishBatchRepository extends JpaRepository<FishBatch, Long> {
    List<FishBatch> findAllByPond_IdAndPond_Owner_IdOrderByStockedOnDesc(Long pondId, Long ownerId);
    Optional<FishBatch> findByIdAndPond_Owner_Id(Long id, Long ownerId);
    boolean existsByPond_IdAndStatus(Long pondId, BatchStatus status);
}
