package com.example.backend.alert;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sites/{siteId}/alerts")
public class AlertController {
    private final AlertService alerts;

    public AlertController(AlertService alerts) {
        this.alerts = alerts;
    }

    @GetMapping
    public List<AlertDtos.AlertResponse> list(
            Authentication auth,
            @PathVariable Long siteId,
            @RequestParam(required = false) String status) {
        return alerts.listAlerts(auth.getName(), siteId, status);
    }

    @GetMapping("/stats")
    public AlertDtos.AlertStatsResponse stats(
            Authentication auth,
            @PathVariable Long siteId) {
        return alerts.getStats(auth.getName(), siteId);
    }

    @PatchMapping("/{alertId}/resolve")
    public AlertDtos.AlertResponse resolve(
            Authentication auth,
            @PathVariable Long siteId,
            @PathVariable Long alertId) {
        return alerts.resolveAlert(auth.getName(), siteId, alertId);
    }
}

