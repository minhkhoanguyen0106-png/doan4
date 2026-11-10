package com.example.backend.diary;

import com.example.backend.monitor.MonitoringSite;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "pond_feeding_logs")
public class PondFeedingLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "site_id", nullable = false)
    private MonitoringSite site;

    @Column(name = "fed_at", nullable = false)
    private Instant fedAt;

    @Column(name = "feed_meal", nullable = false, length = 64)
    private String feedMeal;

    @Column(name = "feed_brand", length = 120)
    private String feedBrand;

    @Column(name = "amount_kg", nullable = false, precision = 8, scale = 2)
    private BigDecimal amountKg;

    @Column(name = "feed_tray_status", nullable = false, length = 64)
    private String feedTrayStatus = "HẾT";

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    protected PondFeedingLog() { }

    public PondFeedingLog(MonitoringSite site, Instant fedAt, String feedMeal, String feedBrand,
                          BigDecimal amountKg, String feedTrayStatus, String notes) {
        this.site = site;
        this.fedAt = fedAt;
        this.feedMeal = feedMeal != null ? feedMeal.trim() : "CỮ 1";
        this.feedBrand = feedBrand != null ? feedBrand.trim() : null;
        this.amountKg = amountKg != null ? amountKg : BigDecimal.ZERO;
        this.feedTrayStatus = feedTrayStatus != null ? feedTrayStatus.trim() : "HẾT";
        this.notes = notes != null ? notes.trim() : null;
    }

    public Long getId() { return id; }
    public MonitoringSite getSite() { return site; }
    public Instant getFedAt() { return fedAt; }
    public String getFeedMeal() { return feedMeal; }
    public String getFeedBrand() { return feedBrand; }
    public BigDecimal getAmountKg() { return amountKg; }
    public String getFeedTrayStatus() { return feedTrayStatus; }
    public String getNotes() { return notes; }
    public Instant getCreatedAt() { return createdAt; }
}

