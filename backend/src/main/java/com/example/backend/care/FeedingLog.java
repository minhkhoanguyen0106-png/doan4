package com.example.backend.care;

import com.example.backend.batch.FishBatch;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity @Table(name = "feeding_logs")
public class FeedingLog {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED") private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "batch_id", nullable = false)
    private FishBatch batch;
    @Column(name = "fed_at", nullable = false) private Instant fedAt;
    @Column(name = "feed_type", nullable = false, length = 120) private String feedType;
    @Column(name = "amount_kg", nullable = false, precision = 10, scale = 3) private BigDecimal amountKg;
    @Column(name = "feedings_count", nullable = false) private Integer feedingsCount;
    @Column(columnDefinition = "TEXT") private String notes;
    protected FeedingLog() { }
    public FeedingLog(FishBatch batch, CareDtos.FeedingRequest request) {
        this.batch = batch; this.fedAt = request.fedAt(); this.feedType = request.feedType().trim();
        this.amountKg = request.amountKg(); this.feedingsCount = request.feedingsCount();
        this.notes = clean(request.notes());
    }
    public Long getId() { return id; }
    public Long getBatchId() { return batch.getId(); }
    public Instant getFedAt() { return fedAt; }
    public String getFeedType() { return feedType; }
    public BigDecimal getAmountKg() { return amountKg; }
    public Integer getFeedingsCount() { return feedingsCount; }
    public String getNotes() { return notes; }
    private static String clean(String value) { return value == null || value.isBlank() ? null : value.trim(); }
}
