package com.example.backend.batch;

import com.example.backend.pond.Pond;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "fish_batches")
public class FishBatch {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "pond_id", nullable = false)
    private Pond pond;
    @Column(name = "fish_species", nullable = false, length = 120)
    private String fishSpecies;
    @Column(name = "stocked_count", nullable = false)
    private Integer stockedCount;
    @Column(name = "stocked_on", nullable = false)
    private LocalDate stockedOn;
    @Column(length = 255)
    private String source;
    @Column(columnDefinition = "TEXT")
    private String notes;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private BatchStatus status = BatchStatus.ACTIVE;
    @Column(name = "ended_on")
    private LocalDate endedOn;
    @Column(name = "harvested_count")
    private Integer harvestedCount;
    @Column(name = "harvest_weight_kg", precision = 12, scale = 3)
    private BigDecimal harvestWeightKg;

    protected FishBatch() { }

    public FishBatch(Pond pond, BatchDtos.CreateRequest request) {
        this.pond = pond;
        this.fishSpecies = request.fishSpecies().trim();
        this.stockedCount = request.stockedCount();
        this.stockedOn = request.stockedOn();
        this.source = clean(request.source());
        this.notes = clean(request.notes());
    }

    public void complete(BatchDtos.CompleteRequest request) {
        this.status = BatchStatus.COMPLETED;
        this.endedOn = request.endedOn();
        this.harvestedCount = request.harvestedCount();
        this.harvestWeightKg = request.harvestWeightKg();
        this.notes = clean(request.notes());
    }

    public Long getId() { return id; }
    public Pond getPond() { return pond; }
    public String getFishSpecies() { return fishSpecies; }
    public Integer getStockedCount() { return stockedCount; }
    public LocalDate getStockedOn() { return stockedOn; }
    public String getSource() { return source; }
    public String getNotes() { return notes; }
    public BatchStatus getStatus() { return status; }
    public LocalDate getEndedOn() { return endedOn; }
    public Integer getHarvestedCount() { return harvestedCount; }
    public BigDecimal getHarvestWeightKg() { return harvestWeightKg; }

    private static String clean(String value) { return value == null || value.isBlank() ? null : value.trim(); }
}
