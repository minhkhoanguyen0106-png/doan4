package com.example.backend.monitor;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.Instant;
import java.time.LocalDate;

@Entity @Table(name = "daily_water_summaries", uniqueConstraints = @UniqueConstraint(name = "uq_daily_summary_site_date_version", columnNames = {"site_id", "local_date", "threshold_version"}))
public class DailyWaterSummary {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(columnDefinition = "BIGINT UNSIGNED") private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "site_id", nullable = false) private MonitoringSite site;
    @Column(name = "local_date", nullable = false) private LocalDate localDate;
    @Column(name = "valid_sample_count", nullable = false) private long validSampleCount;
    @Column(name = "screening_level", nullable = false, length = 24) private String screeningLevel;
    @Column(name = "threshold_version", nullable = false) private int thresholdVersion;
    @JdbcTypeCode(SqlTypes.JSON) @Column(name = "aggregates_json", nullable = false, columnDefinition = "JSON") private String aggregatesJson;
    @Column(name = "updated_at", nullable = false) private Instant updatedAt;
    protected DailyWaterSummary() { }
    public DailyWaterSummary(MonitoringSite site, LocalDate date, long count, String level, int version, String json) {
        this.site = site; this.localDate = date; this.validSampleCount = count; this.screeningLevel = level;
        this.thresholdVersion = version; this.aggregatesJson = json; this.updatedAt = Instant.now();
    }
    public void refresh(long count, String level, String json) {
        this.validSampleCount = count; this.screeningLevel = level; this.aggregatesJson = json; this.updatedAt = Instant.now();
    }
}
