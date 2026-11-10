package com.example.backend.monitor;

import com.example.backend.user.User;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity @Table(name = "monitoring_sites")
public class MonitoringSite {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "user_id", nullable = false)
    private User owner;
    @Column(nullable = false, length = 120) private String name;
    @Column(length = 255) private String location;
    @Column(nullable = false, length = 64) private String timezone;
    @Column(columnDefinition = "TEXT") private String notes;
    @Column(nullable = false, length = 16) private String status = "ACTIVE";
    @Column(name = "created_at", insertable = false, updatable = false) private Instant createdAt;

    // Digital Pond Profile & Shrimp Farming Data
    @Column(name = "area_m2", precision = 10, scale = 2)
    private BigDecimal areaM2 = BigDecimal.valueOf(1000.00);

    @Column(name = "depth_m", precision = 6, scale = 2)
    private BigDecimal depthM = BigDecimal.valueOf(1.50);

    @Column(name = "shrimp_species", length = 120)
    private String shrimpSpecies = "Tôm thẻ chân trắng";

    @Column(name = "stocked_count")
    private Integer stockedCount = 100000;

    @Column(name = "stocked_on")
    private LocalDate stockedOn;

    @Column(name = "farming_stage", length = 64)
    private String farmingStage = "GIAI_DOAN_1";

    @Column(name = "target_harvest_weight_g", precision = 6, scale = 2)
    private BigDecimal targetHarvestWeightG = BigDecimal.valueOf(25.00);

    protected MonitoringSite() { }
    public MonitoringSite(User owner, String name, String location, String timezone, String notes) {
        this.owner = owner; this.name = name.trim(); this.location = blankToNull(location);
        this.timezone = timezone; this.notes = blankToNull(notes);
        this.areaM2 = BigDecimal.valueOf(1000.00);
        this.depthM = BigDecimal.valueOf(1.50);
        this.shrimpSpecies = "Tôm thẻ chân trắng";
        this.stockedCount = 100000;
        this.stockedOn = LocalDate.now().minusDays(25);
        this.farmingStage = "GIAI_DOAN_1";
        this.targetHarvestWeightG = BigDecimal.valueOf(25.00);
    }

    public void updateShrimpProfile(BigDecimal areaM2, BigDecimal depthM, String shrimpSpecies,
                                   Integer stockedCount, LocalDate stockedOn, String farmingStage,
                                   BigDecimal targetHarvestWeightG) {
        if (areaM2 != null) this.areaM2 = areaM2;
        if (depthM != null) this.depthM = depthM;
        if (shrimpSpecies != null && !shrimpSpecies.isBlank()) this.shrimpSpecies = shrimpSpecies.trim();
        if (stockedCount != null) this.stockedCount = stockedCount;
        if (stockedOn != null) this.stockedOn = stockedOn;
        if (farmingStage != null && !farmingStage.isBlank()) this.farmingStage = farmingStage.trim();
        if (targetHarvestWeightG != null) this.targetHarvestWeightG = targetHarvestWeightG;
    }

    private static String blankToNull(String value) { return value == null || value.isBlank() ? null : value.trim(); }
    public Long getId() { return id; }
    public User getOwner() { return owner; }
    public String getName() { return name; }
    public String getLocation() { return location; }
    public String getTimezone() { return timezone; }
    public String getNotes() { return notes; }
    public String getStatus() { return status; }
    public Instant getCreatedAt() { return createdAt; }

    public BigDecimal getAreaM2() { return areaM2; }
    public BigDecimal getDepthM() { return depthM; }
    public String getShrimpSpecies() { return shrimpSpecies; }
    public Integer getStockedCount() { return stockedCount; }
    public LocalDate getStockedOn() { return stockedOn; }
    public String getFarmingStage() { return farmingStage; }
    public BigDecimal getTargetHarvestWeightG() { return targetHarvestWeightG; }
}
