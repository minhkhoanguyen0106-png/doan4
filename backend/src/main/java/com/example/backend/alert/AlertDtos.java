package com.example.backend.alert;

import java.time.Instant;

public class AlertDtos {
    public record AlertResponse(
            Long id,
            Long siteId,
            String siteName,
            Long deviceId,
            String deviceCode,
            String deviceName,
            String alertType,
            String severity,
            String title,
            String message,
            String status,
            Instant triggeredAt,
            Instant resolvedAt
    ) {
        public static AlertResponse from(WaterAlert a) {
            return new AlertResponse(
                    a.getId(),
                    a.getSite().getId(),
                    a.getSite().getName(),
                    a.getDevice() == null ? null : a.getDevice().getId(),
                    a.getDevice() == null ? null : a.getDevice().getDeviceCode(),
                    a.getDevice() == null ? null : a.getDevice().getName(),
                    a.getAlertType(),
                    a.getSeverity(),
                    a.getTitle(),
                    a.getMessage(),
                    a.getStatus(),
                    a.getTriggeredAt(),
                    a.getResolvedAt()
            );
        }
    }

    public record AlertStatsResponse(
            long activeCount,
            long criticalCount,
            long highCount,
            long watchCount
    ) {}
}

