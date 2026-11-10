package com.example.backend.monitor;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/device-ingest")
public class DeviceIngestController {
    private final MeasurementService measurements;
    public DeviceIngestController(MeasurementService measurements) { this.measurements = measurements; }
    @PostMapping("/{deviceCode}/measurements") @ResponseStatus(HttpStatus.CREATED)
    public MeasurementDtos.MeasurementResponse ingest(@PathVariable String deviceCode,
            @RequestHeader(name = "X-Device-Token", required = false) String token,
            @Valid @RequestBody MeasurementDtos.IngestRequest request) {
        return measurements.ingest(deviceCode, token, request);
    }
}
