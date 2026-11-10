package com.example.backend.water;

import com.example.backend.batch.FishBatch;
import com.example.backend.pond.Pond;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity @Table(name = "water_quality_records")
public class WaterQualityRecord {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED") private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "pond_id", nullable = false)
    private Pond pond;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "batch_id")
    private FishBatch batch;
    @Column(name = "measured_at", nullable = false) private Instant measuredAt;
    @Column(name = "temperature_c", precision = 5, scale = 2) private BigDecimal temperatureC;
    @Column(precision = 4, scale = 2) private BigDecimal ph;
    @Column(name = "dissolved_oxygen_mg_l", precision = 6, scale = 2) private BigDecimal dissolvedOxygenMgL;
    @Column(name = "water_level_m", precision = 7, scale = 3) private BigDecimal waterLevelM;
    @Column(name = "turbidity_ntu", precision = 8, scale = 2) private BigDecimal turbidityNtu;
    @Column(nullable = false, length = 16) private String source = "MANUAL";
    @Column(columnDefinition = "TEXT") private String notes;
    protected WaterQualityRecord() { }
    public WaterQualityRecord(Pond pond, FishBatch batch, WaterDtos.CreateRequest request) {
        this.pond = pond; this.batch = batch; this.measuredAt = request.measuredAt();
        this.temperatureC = request.temperatureC(); this.ph = request.ph();
        this.dissolvedOxygenMgL = request.dissolvedOxygenMgL(); this.waterLevelM = request.waterLevelM();
        this.turbidityNtu = request.turbidityNtu(); this.notes = request.notes() == null || request.notes().isBlank() ? null : request.notes().trim();
    }
    public Long getId() { return id; }
    public Long getPondId() { return pond.getId(); }
    public Long getBatchId() { return batch == null ? null : batch.getId(); }
    public Instant getMeasuredAt() { return measuredAt; }
    public BigDecimal getTemperatureC() { return temperatureC; }
    public BigDecimal getPh() { return ph; }
    public BigDecimal getDissolvedOxygenMgL() { return dissolvedOxygenMgL; }
    public BigDecimal getWaterLevelM() { return waterLevelM; }
    public BigDecimal getTurbidityNtu() { return turbidityNtu; }
    public String getSource() { return source; }
    public String getNotes() { return notes; }
}
