package com.example.backend.diary;

import com.example.backend.monitor.MonitoringSite;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "shrimp_health_logs")
public class ShrimpHealthLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "site_id", nullable = false)
    private MonitoringSite site;

    @Column(name = "logged_at", nullable = false)
    private Instant loggedAt;

    @Column(name = "age_days")
    private Integer ageDays;

    @Column(name = "average_weight_g", nullable = false, precision = 8, scale = 2)
    private BigDecimal averageWeightG;

    @Column(name = "estimated_survival_rate", precision = 5, scale = 2)
    private BigDecimal estimatedSurvivalRate = BigDecimal.valueOf(85.00);

    @Column(name = "health_status", nullable = false, length = 64)
    private String healthStatus = "KHỎE_MẠNH";

    @Column(name = "gut_condition", length = 120)
    private String gutCondition;

    @Column(name = "hepatopancreas", length = 120)
    private String hepatopancreas;

    @Column(name = "shell_condition", length = 120)
    private String shellCondition;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    protected ShrimpHealthLog() { }

    public ShrimpHealthLog(MonitoringSite site, Instant loggedAt, Integer ageDays, BigDecimal averageWeightG,
                           BigDecimal estimatedSurvivalRate, String healthStatus, String gutCondition,
                           String hepatopancreas, String shellCondition, String notes) {
        this.site = site;
        this.loggedAt = loggedAt;
        this.ageDays = ageDays;
        this.averageWeightG = averageWeightG != null ? averageWeightG : BigDecimal.ZERO;
        this.estimatedSurvivalRate = estimatedSurvivalRate != null ? estimatedSurvivalRate : BigDecimal.valueOf(85.00);
        this.healthStatus = healthStatus != null ? healthStatus.trim() : "KHỎE_MẠNH";
        this.gutCondition = gutCondition != null ? gutCondition.trim() : null;
        this.hepatopancreas = hepatopancreas != null ? hepatopancreas.trim() : null;
        this.shellCondition = shellCondition != null ? shellCondition.trim() : null;
        this.notes = notes != null ? notes.trim() : null;
    }

    public Long getId() { return id; }
    public MonitoringSite getSite() { return site; }
    public Instant getLoggedAt() { return loggedAt; }
    public Integer getAgeDays() { return ageDays; }
    public BigDecimal getAverageWeightG() { return averageWeightG; }
    public BigDecimal getEstimatedSurvivalRate() { return estimatedSurvivalRate; }
    public String getHealthStatus() { return healthStatus; }
    public String getGutCondition() { return gutCondition; }
    public String getHepatopancreas() { return hepatopancreas; }
    public String getShellCondition() { return shellCondition; }
    public String getNotes() { return notes; }
    public Instant getCreatedAt() { return createdAt; }
}

