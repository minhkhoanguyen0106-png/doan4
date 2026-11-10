package com.example.backend.monitor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Instant;

public final class MonitoringDtos {
    private MonitoringDtos() { }
    public record SiteRequest(@NotBlank @Size(max = 120) String name, @Size(max = 255) String location,
                              @NotBlank @Size(max = 64) String timezone, @Size(max = 5000) String notes) { }
    public record SiteResponse(Long id, String name, String location, String timezone, String notes, String status) {
        static SiteResponse from(MonitoringSite site) {
            return new SiteResponse(site.getId(), site.getName(), site.getLocation(), site.getTimezone(), site.getNotes(), site.getStatus());
        }
    }
    public record DeviceRequest(@NotBlank @Size(max = 120) String name) { }
    public record DeviceResponse(Long id, String deviceCode, String name, String status, Instant lastSeenAt, boolean online) {
        static DeviceResponse from(IotDevice device, Instant now, long offlineTimeoutSeconds) {
            boolean online = "ACTIVE".equals(device.getStatus()) && device.getLastSeenAt() != null
                    && device.getLastSeenAt().isAfter(now.minusSeconds(offlineTimeoutSeconds));
            return new DeviceResponse(device.getId(), device.getDeviceCode(), device.getName(), device.getStatus(), device.getLastSeenAt(), online);
        }
    }
    public record DeviceCreatedResponse(Long id, String deviceCode, String name, String status, String deviceToken) { }
}
