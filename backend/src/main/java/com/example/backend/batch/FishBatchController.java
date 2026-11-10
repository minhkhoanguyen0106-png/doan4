package com.example.backend.batch;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
public class FishBatchController {
    private final FishBatchService service;
    public FishBatchController(FishBatchService service) { this.service = service; }

    @GetMapping("/api/ponds/{pondId}/batches")
    public List<BatchDtos.Response> list(Authentication auth, @PathVariable Long pondId) {
        return service.list(auth.getName(), pondId);
    }
    @PostMapping("/api/ponds/{pondId}/batches")
    @ResponseStatus(HttpStatus.CREATED)
    public BatchDtos.Response create(Authentication auth, @PathVariable Long pondId,
                                     @Valid @RequestBody BatchDtos.CreateRequest request) {
        return service.create(auth.getName(), pondId, request);
    }
    @PostMapping("/api/batches/{batchId}/complete")
    public BatchDtos.Response complete(Authentication auth, @PathVariable Long batchId,
                                       @Valid @RequestBody BatchDtos.CompleteRequest request) {
        return service.complete(auth.getName(), batchId, request);
    }
}
