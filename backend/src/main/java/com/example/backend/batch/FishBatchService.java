package com.example.backend.batch;

import com.example.backend.pond.Pond;
import com.example.backend.pond.PondRepository;
import com.example.backend.pond.PondStatus;
import com.example.backend.user.UserRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class FishBatchService {
    private final FishBatchRepository batches;
    private final PondRepository ponds;
    private final UserRepository users;
    public FishBatchService(FishBatchRepository batches, PondRepository ponds, UserRepository users) {
        this.batches = batches; this.ponds = ponds; this.users = users;
    }

    @Transactional
    public BatchDtos.Response create(String email, Long pondId, BatchDtos.CreateRequest request) {
        Long ownerId = ownerId(email);
        Pond pond = ponds.findByIdAndOwnerId(pondId, ownerId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Pond not found"));
        if (pond.getStatus() != PondStatus.ACTIVE) throw new ResponseStatusException(HttpStatus.CONFLICT, "Pond is inactive");
        if (batches.existsByPond_IdAndStatus(pondId, BatchStatus.ACTIVE))
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Pond already has an active batch");
        if (request.stockedOn().isAfter(java.time.LocalDate.now()))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Stocked date cannot be in the future");
        try { return BatchDtos.Response.from(batches.saveAndFlush(new FishBatch(pond, request))); }
        catch (DataIntegrityViolationException exception) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Pond already has an active batch");
        }
    }

    @Transactional(readOnly = true)
    public List<BatchDtos.Response> list(String email, Long pondId) {
        Long ownerId = ownerId(email);
        if (!ponds.findByIdAndOwnerId(pondId, ownerId).isPresent())
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Pond not found");
        return batches.findAllByPond_IdAndPond_Owner_IdOrderByStockedOnDesc(pondId, ownerId)
                .stream().map(BatchDtos.Response::from).toList();
    }

    @Transactional
    public BatchDtos.Response complete(String email, Long batchId, BatchDtos.CompleteRequest request) {
        Long ownerId = ownerId(email);
        FishBatch batch = batches.findByIdAndPond_Owner_Id(batchId, ownerId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Batch not found"));
        if (batch.getStatus() != BatchStatus.ACTIVE)
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Batch is already completed");
        if (request.endedOn().isBefore(batch.getStockedOn()) || request.endedOn().isAfter(java.time.LocalDate.now()))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "End date must be between stocked date and today");
        batch.complete(request);
        return BatchDtos.Response.from(batch);
    }

    private Long ownerId(String email) {
        return users.findByEmail(email).orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED)).getId();
    }
}
