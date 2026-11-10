package com.example.backend.monitor;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/sites")
public class MonitoringController {
    private final MonitoringService monitoring;
    private final MeasurementService measurements;
    public MonitoringController(MonitoringService monitoring, MeasurementService measurements) { this.monitoring = monitoring; this.measurements = measurements; }
    @GetMapping public List<MonitoringDtos.SiteResponse> list(Authentication auth) { return monitoring.listSites(auth.getName()); }
    @PostMapping @ResponseStatus(HttpStatus.CREATED)
    public MonitoringDtos.SiteResponse create(Authentication auth, @Valid @RequestBody MonitoringDtos.SiteRequest request) {
        return monitoring.createSite(auth.getName(), request);
    }
    @GetMapping("/{siteId}/devices")
    public List<MonitoringDtos.DeviceResponse> devices(Authentication auth, @PathVariable Long siteId) {
        return monitoring.listDevices(auth.getName(), siteId);
    }
    @PostMapping("/{siteId}/devices") @ResponseStatus(HttpStatus.CREATED)
    public MonitoringDtos.DeviceCreatedResponse createDevice(Authentication auth, @PathVariable Long siteId,
                                                               @Valid @RequestBody MonitoringDtos.DeviceRequest request) {
        return monitoring.createDevice(auth.getName(), siteId, request);
    }
    @GetMapping("/{siteId}/measurements/latest")
    public Optional<MeasurementDtos.MeasurementResponse> latest(Authentication auth, @PathVariable Long siteId) {
        return measurements.latest(auth.getName(), siteId);
    }
    @GetMapping("/{siteId}/measurements")
    public List<MeasurementDtos.MeasurementResponse> history(Authentication auth, @PathVariable Long siteId,
            @RequestParam Instant from, @RequestParam Instant to, @RequestParam(defaultValue = "200") int limit) {
        return measurements.history(auth.getName(), siteId, from, to, limit);
    }
    @GetMapping("/{siteId}/daily-summary")
    public MeasurementDtos.DailySummary daily(Authentication auth, @PathVariable Long siteId, @RequestParam LocalDate date) {
        return measurements.daily(auth.getName(), siteId, date);
    }
}
