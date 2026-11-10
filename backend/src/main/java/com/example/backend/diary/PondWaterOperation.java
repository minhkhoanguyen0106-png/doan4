package com.example.backend.diary;

import com.example.backend.monitor.MonitoringSite;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "pond_water_operations")
public class PondWaterOperation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "site_id", nullable = false)
    private MonitoringSite site;

    @Column(name = "operated_at", nullable = false)
    private Instant operatedAt;

    @Column(name = "operation_type", nullable = false, length = 64)
    private String operationType;

    @Column(name = "volume_m3", precision = 8, scale = 2)
    private BigDecimal volumeM3;

    @Column(name = "water_source", length = 120)
    private String waterSource;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    protected PondWaterOperation() { }

    public PondWaterOperation(MonitoringSite site, Instant operatedAt, String operationType,
                              BigDecimal volumeM3, String waterSource, String notes) {
        this.site = site;
        this.operatedAt = operatedAt;
        this.operationType = operationType != null ? operationType.trim() : "THAY_NUOC";
        this.volumeM3 = volumeM3;
        this.waterSource = waterSource != null ? waterSource.trim() : null;
        this.notes = notes != null ? notes.trim() : null;
    }

    public Long getId() { return id; }
    public MonitoringSite getSite() { return site; }
    public Instant getOperatedAt() { return operatedAt; }
    public String getOperationType() { return operationType; }
    public BigDecimal getVolumeM3() { return volumeM3; }
    public String getWaterSource() { return waterSource; }
    public String getNotes() { return notes; }
    public Instant getCreatedAt() { return createdAt; }
}

