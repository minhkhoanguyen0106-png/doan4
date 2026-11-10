package com.example.backend.care;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/batches/{batchId}")
public class CareLogController {
    private final CareLogService service;
    public CareLogController(CareLogService service) { this.service = service; }
    @GetMapping("/feeding-logs")
    public List<CareDtos.FeedingResponse> feedings(Authentication auth, @PathVariable Long batchId) {
        return service.feedings(auth.getName(), batchId);
    }
    @PostMapping("/feeding-logs") @ResponseStatus(HttpStatus.CREATED)
    public CareDtos.FeedingResponse addFeeding(Authentication auth, @PathVariable Long batchId,
                                               @Valid @RequestBody CareDtos.FeedingRequest request) {
        return service.addFeeding(auth.getName(), batchId, request);
    }
    @GetMapping("/water-change-logs")
    public List<CareDtos.WaterChangeResponse> waterChanges(Authentication auth, @PathVariable Long batchId) {
        return service.waterChanges(auth.getName(), batchId);
    }
    @PostMapping("/water-change-logs") @ResponseStatus(HttpStatus.CREATED)
    public CareDtos.WaterChangeResponse addWaterChange(Authentication auth, @PathVariable Long batchId,
                                                       @Valid @RequestBody CareDtos.WaterChangeRequest request) {
        return service.addWaterChange(auth.getName(), batchId, request);
    }
}
