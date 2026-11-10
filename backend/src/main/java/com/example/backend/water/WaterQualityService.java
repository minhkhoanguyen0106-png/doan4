package com.example.backend.water;

import com.example.backend.batch.FishBatch;
import com.example.backend.batch.FishBatchRepository;
import com.example.backend.pond.Pond;
import com.example.backend.pond.PondRepository;
import com.example.backend.user.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.time.Instant;

@Service
public class WaterQualityService {
    private final WaterQualityRepository records;
    private final PondRepository ponds;
    private final FishBatchRepository batches;
    private final UserRepository users;
    public WaterQualityService(WaterQualityRepository records, PondRepository ponds,
                               FishBatchRepository batches, UserRepository users) {
        this.records = records; this.ponds = ponds; this.batches = batches; this.users = users;
    }
    @Transactional
    public WaterDtos.Response create(String email, Long pondId, WaterDtos.CreateRequest request) {
        Long ownerId = ownerId(email);
        Pond pond = ponds.findByIdAndOwnerId(pondId, ownerId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Pond not found"));
        if (request.batchId() != null && !batches.findByIdAndPond_Owner_Id(request.batchId(), ownerId)
                .filter(batch -> batch.getPond().getId().equals(pondId)).isPresent())
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Batch not found for this pond");
        FishBatch batch = request.batchId() == null ? null : batches.findById(request.batchId()).orElseThrow();
        if (request.temperatureC() == null && request.ph() == null && request.dissolvedOxygenMgL() == null
                && request.waterLevelM() == null && request.turbidityNtu() == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "At least one measurement is required");
        return WaterDtos.Response.from(records.save(new WaterQualityRecord(pond, batch, request)));
    }
    @Transactional(readOnly = true)
    public Page<WaterDtos.Response> history(String email, Long pondId, Instant from, Instant to, Pageable pageable) {
        Long ownerId = ownerId(email);
        if (!ponds.findByIdAndOwnerId(pondId, ownerId).isPresent())
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Pond not found");
        if (from != null && to != null && from.isAfter(to))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "from must be before to");
        return records.findHistory(pondId, ownerId, from, to, pageable).map(WaterDtos.Response::from);
    }
    private Long ownerId(String email) {
        return users.findByEmail(email).orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED)).getId();
    }
}
