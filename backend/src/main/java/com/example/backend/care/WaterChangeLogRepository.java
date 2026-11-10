package com.example.backend.care;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface WaterChangeLogRepository extends JpaRepository<WaterChangeLog, Long> {
    List<WaterChangeLog> findAllByBatch_IdAndBatch_Pond_Owner_IdOrderByChangedAtDesc(Long batchId, Long ownerId);
}
