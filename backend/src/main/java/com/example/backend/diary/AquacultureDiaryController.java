package com.example.backend.diary;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sites/{siteId}/diary")
public class AquacultureDiaryController {
    private final AquacultureDiaryService service;

    public AquacultureDiaryController(AquacultureDiaryService service) {
        this.service = service;
    }

    @GetMapping("/profile")
    public DiaryDtos.ShrimpProfileResponse getProfile(Authentication auth, @PathVariable Long siteId) {
        return service.getShrimpProfile(auth.getName(), siteId);
    }

    @PutMapping("/profile")
    public DiaryDtos.ShrimpProfileResponse updateProfile(
            Authentication auth,
            @PathVariable Long siteId,
            @Valid @RequestBody DiaryDtos.ShrimpProfileRequest request
    ) {
        return service.updateShrimpProfile(auth.getName(), siteId, request);
    }

    @GetMapping("/feedings")
    public List<DiaryDtos.FeedingResponse> listFeedings(Authentication auth, @PathVariable Long siteId) {
        return service.listFeedings(auth.getName(), siteId);
    }

    @PostMapping("/feedings")
    @ResponseStatus(HttpStatus.CREATED)
    public DiaryDtos.FeedingResponse addFeeding(
            Authentication auth,
            @PathVariable Long siteId,
            @Valid @RequestBody DiaryDtos.FeedingRequest request
    ) {
        return service.addFeeding(auth.getName(), siteId, request);
    }

    @DeleteMapping("/feedings/{logId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteFeeding(Authentication auth, @PathVariable Long siteId, @PathVariable Long logId) {
        service.deleteFeeding(auth.getName(), siteId, logId);
    }

    @GetMapping("/health-logs")
    public List<DiaryDtos.HealthResponse> listHealthLogs(Authentication auth, @PathVariable Long siteId) {
        return service.listHealthLogs(auth.getName(), siteId);
    }

    @PostMapping("/health-logs")
    @ResponseStatus(HttpStatus.CREATED)
    public DiaryDtos.HealthResponse addHealthLog(
            Authentication auth,
            @PathVariable Long siteId,
            @Valid @RequestBody DiaryDtos.HealthRequest request
    ) {
        return service.addHealthLog(auth.getName(), siteId, request);
    }

    @DeleteMapping("/health-logs/{logId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteHealthLog(Authentication auth, @PathVariable Long siteId, @PathVariable Long logId) {
        service.deleteHealthLog(auth.getName(), siteId, logId);
    }

    @GetMapping("/treatments")
    public List<DiaryDtos.TreatmentResponse> listTreatments(Authentication auth, @PathVariable Long siteId) {
        return service.listTreatments(auth.getName(), siteId);
    }

    @PostMapping("/treatments")
    @ResponseStatus(HttpStatus.CREATED)
    public DiaryDtos.TreatmentResponse addTreatment(
            Authentication auth,
            @PathVariable Long siteId,
            @Valid @RequestBody DiaryDtos.TreatmentRequest request
    ) {
        return service.addTreatment(auth.getName(), siteId, request);
    }

    @DeleteMapping("/treatments/{logId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteTreatment(Authentication auth, @PathVariable Long siteId, @PathVariable Long logId) {
        service.deleteTreatment(auth.getName(), siteId, logId);
    }

    @GetMapping("/water-operations")
    public List<DiaryDtos.WaterOpResponse> listWaterOps(Authentication auth, @PathVariable Long siteId) {
        return service.listWaterOps(auth.getName(), siteId);
    }

    @PostMapping("/water-operations")
    @ResponseStatus(HttpStatus.CREATED)
    public DiaryDtos.WaterOpResponse addWaterOp(
            Authentication auth,
            @PathVariable Long siteId,
            @Valid @RequestBody DiaryDtos.WaterOpRequest request
    ) {
        return service.addWaterOp(auth.getName(), siteId, request);
    }

    @DeleteMapping("/water-operations/{logId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteWaterOp(Authentication auth, @PathVariable Long siteId, @PathVariable Long logId) {
        service.deleteWaterOp(auth.getName(), siteId, logId);
    }

    @GetMapping("/analytics")
    public DiaryDtos.DiaryAnalyticsResponse getAnalytics(Authentication auth, @PathVariable Long siteId) {
        return service.getAnalytics(auth.getName(), siteId);
    }
}

