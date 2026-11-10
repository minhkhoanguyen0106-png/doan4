package com.example.backend.diary;

import com.example.backend.monitor.MonitoringSite;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "pond_treatment_logs")
public class PondTreatmentLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "site_id", nullable = false)
    private MonitoringSite site;

    @Column(name = "treated_at", nullable = false)
    private Instant treatedAt;

    @Column(name = "treatment_type", nullable = false, length = 64)
    private String treatmentType;

    @Column(name = "product_name", nullable = false, length = 150)
    private String productName;

    @Column(name = "dosage", nullable = false, precision = 8, scale = 2)
    private BigDecimal dosage;

    @Column(name = "unit", nullable = false, length = 32)
    private String unit = "kg";

    @Column(name = "purpose", length = 255)
    private String purpose;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    protected PondTreatmentLog() { }

    public PondTreatmentLog(MonitoringSite site, Instant treatedAt, String treatmentType, String productName,
                            BigDecimal dosage, String unit, String purpose, String notes) {
        this.site = site;
        this.treatedAt = treatedAt;
        this.treatmentType = treatmentType != null ? treatmentType.trim() : "KHAC";
        this.productName = productName != null ? productName.trim() : "";
        this.dosage = dosage != null ? dosage : BigDecimal.ZERO;
        this.unit = unit != null ? unit.trim() : "kg";
        this.purpose = purpose != null ? purpose.trim() : null;
        this.notes = notes != null ? notes.trim() : null;
    }

    public Long getId() { return id; }
    public MonitoringSite getSite() { return site; }
    public Instant getTreatedAt() { return treatedAt; }
    public String getTreatmentType() { return treatmentType; }
    public String getProductName() { return productName; }
    public BigDecimal getDosage() { return dosage; }
    public String getUnit() { return unit; }
    public String getPurpose() { return purpose; }
    public String getNotes() { return notes; }
    public Instant getCreatedAt() { return createdAt; }
}

