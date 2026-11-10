package com.example.backend.water;

import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.time.Instant;

@RestController
@RequestMapping("/api/ponds/{pondId}/water-quality")
public class WaterQualityController {
    private final WaterQualityService service;
    public WaterQualityController(WaterQualityService service) { this.service = service; }
    @PostMapping @ResponseStatus(HttpStatus.CREATED)
    public WaterDtos.Response create(Authentication auth, @PathVariable Long pondId,
                                     @Valid @RequestBody WaterDtos.CreateRequest request) {
        return service.create(auth.getName(), pondId, request);
    }
    @GetMapping
    public Page<WaterDtos.Response> history(Authentication auth, @PathVariable Long pondId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant to,
            Pageable pageable) {
        return service.history(auth.getName(), pondId, from, to, pageable);
    }
}
