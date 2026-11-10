package com.example.backend.care;

import com.example.backend.batch.FishBatch;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity @Table(name = "water_change_logs")
public class WaterChangeLog {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED") private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "batch_id", nullable = false)
    private FishBatch batch;
    @Column(name = "changed_at", nullable = false) private Instant changedAt;
    @Column(name = "changed_percent", precision = 5, scale = 2) private BigDecimal changedPercent;
    @Column(length = 120) private String method;
    @Column(length = 255) private String reason;
    @Column(columnDefinition = "TEXT") private String notes;
    protected WaterChangeLog() { }
    public WaterChangeLog(FishBatch batch, CareDtos.WaterChangeRequest request) {
        this.batch = batch; this.changedAt = request.changedAt(); this.changedPercent = request.changedPercent();
        this.method = clean(request.method()); this.reason = clean(request.reason()); this.notes = clean(request.notes());
    }
    public Long getId() { return id; }
    public Long getBatchId() { return batch.getId(); }
    public Instant getChangedAt() { return changedAt; }
    public BigDecimal getChangedPercent() { return changedPercent; }
    public String getMethod() { return method; }
    public String getReason() { return reason; }
    public String getNotes() { return notes; }
    private static String clean(String value) { return value == null || value.isBlank() ? null : value.trim(); }
}
