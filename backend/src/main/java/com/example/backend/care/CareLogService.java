package com.example.backend.care;

import com.example.backend.batch.BatchStatus;
import com.example.backend.batch.FishBatch;
import com.example.backend.batch.FishBatchRepository;
import com.example.backend.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;

@Service
public class CareLogService {
    private final FishBatchRepository batches;
    private final FeedingLogRepository feeding;
    private final WaterChangeLogRepository waterChanges;
    private final UserRepository users;
    public CareLogService(FishBatchRepository batches, FeedingLogRepository feeding,
                          WaterChangeLogRepository waterChanges, UserRepository users) {
        this.batches = batches; this.feeding = feeding; this.waterChanges = waterChanges; this.users = users;
    }
    @Transactional
    public CareDtos.FeedingResponse addFeeding(String email, Long batchId, CareDtos.FeedingRequest request) {
        FishBatch batch = activeOwnedBatch(email, batchId);
        return CareDtos.FeedingResponse.from(feeding.save(new FeedingLog(batch, request)));
    }
    @Transactional(readOnly = true)
    public List<CareDtos.FeedingResponse> feedings(String email, Long batchId) {
        Long ownerId = ownerId(email); ensureOwnedBatch(batchId, ownerId);
        return feeding.findAllByBatch_IdAndBatch_Pond_Owner_IdOrderByFedAtDesc(batchId, ownerId)
                .stream().map(CareDtos.FeedingResponse::from).toList();
    }
    @Transactional
    public CareDtos.WaterChangeResponse addWaterChange(String email, Long batchId, CareDtos.WaterChangeRequest request) {
        FishBatch batch = activeOwnedBatch(email, batchId);
        return CareDtos.WaterChangeResponse.from(waterChanges.save(new WaterChangeLog(batch, request)));
    }
    @Transactional(readOnly = true)
    public List<CareDtos.WaterChangeResponse> waterChanges(String email, Long batchId) {
        Long ownerId = ownerId(email); ensureOwnedBatch(batchId, ownerId);
        return waterChanges.findAllByBatch_IdAndBatch_Pond_Owner_IdOrderByChangedAtDesc(batchId, ownerId)
                .stream().map(CareDtos.WaterChangeResponse::from).toList();
    }
    private FishBatch activeOwnedBatch(String email, Long batchId) {
        FishBatch batch = ensureOwnedBatch(batchId, ownerId(email));
        if (batch.getStatus() != BatchStatus.ACTIVE)
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Cannot add a log to a completed batch");
        return batch;
    }
    private FishBatch ensureOwnedBatch(Long batchId, Long ownerId) {
        return batches.findByIdAndPond_Owner_Id(batchId, ownerId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Batch not found"));
    }
    private Long ownerId(String email) {
        return users.findByEmail(email).orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED)).getId();
    }
}
