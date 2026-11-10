package com.example.backend.monitor;

import jakarta.persistence.*;
import java.time.Instant;

@Entity @Table(name = "iot_devices")
public class IotDevice {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "site_id", nullable = false)
    private MonitoringSite site;
    @Column(name = "device_code", nullable = false, unique = true, length = 64) private String deviceCode;
    @Column(nullable = false, length = 120) private String name;
    @Column(name = "token_hash", nullable = false, length = 100) private String tokenHash;
    @Column(nullable = false, length = 16) private String status = "ACTIVE";
    @Column(name = "last_seen_at") private Instant lastSeenAt;
    protected IotDevice() { }
    public IotDevice(MonitoringSite site, String deviceCode, String name, String tokenHash) {
        this.site = site; this.deviceCode = deviceCode; this.name = name.trim(); this.tokenHash = tokenHash;
    }
    public void markSeen(Instant at) { this.lastSeenAt = at; }
    public Long getId() { return id; }
    public MonitoringSite getSite() { return site; }
    public String getDeviceCode() { return deviceCode; }
    public String getName() { return name; }
    public String getTokenHash() { return tokenHash; }
    public String getStatus() { return status; }
    public Instant getLastSeenAt() { return lastSeenAt; }
}
