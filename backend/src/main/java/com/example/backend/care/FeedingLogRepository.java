package com.example.backend.care;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface FeedingLogRepository extends JpaRepository<FeedingLog, Long> {
    List<FeedingLog> findAllByBatch_IdAndBatch_Pond_Owner_IdOrderByFedAtDesc(Long batchId, Long ownerId);
}
