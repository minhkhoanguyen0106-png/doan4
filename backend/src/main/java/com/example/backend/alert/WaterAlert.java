package com.example.backend.alert;

import com.example.backend.monitor.IotDevice;
import com.example.backend.monitor.MonitoringSite;
import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "water_alerts")
public class WaterAlert {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "site_id", nullable = false)
    private MonitoringSite site;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id")
    private IotDevice device;

    @Column(name = "alert_type", nullable = false, length = 32)
    private String alertType;

    @Column(nullable = false, length = 16)
    private String severity;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(nullable = false, length = 16)
    private String status = "ACTIVE";

    @Column(name = "triggered_at", nullable = false)
    private Instant triggeredAt;

    @Column(name = "resolved_at")
    private Instant resolvedAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    protected WaterAlert() {}

    public WaterAlert(MonitoringSite site, IotDevice device, String alertType, String severity,
                      String title, String message, Instant triggeredAt) {
        this.site = site;
        this.device = device;
        this.alertType = alertType;
        this.severity = severity;
        this.title = title;
        this.message = message;
        this.status = "ACTIVE";
        this.triggeredAt = triggeredAt;
    }

    public void resolve(Instant at) {
        this.status = "RESOLVED";
        this.resolvedAt = at;
    }

    public void updateDetails(String severity, String title, String message, Instant triggeredAt) {
        this.severity = severity;
        this.title = title;
        this.message = message;
        this.triggeredAt = triggeredAt;
        this.status = "ACTIVE";
    }

    public Long getId() { return id; }
    public MonitoringSite getSite() { return site; }
    public IotDevice getDevice() { return device; }
    public String getAlertType() { return alertType; }
    public String getSeverity() { return severity; }
    public String getTitle() { return title; }
    public String getMessage() { return message; }
    public String getStatus() { return status; }
    public Instant getTriggeredAt() { return triggeredAt; }
    public Instant getResolvedAt() { return resolvedAt; }
    public Instant getCreatedAt() { return createdAt; }
}

