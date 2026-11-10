package com.example.backend.monitor;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity @Table(name = "water_measurements", uniqueConstraints = @UniqueConstraint(name = "uq_measurement_device_message", columnNames = {"device_id", "message_id"}), indexes = @Index(name = "ix_measurement_device_time", columnList = "device_id, measured_at"))
public class WaterMeasurement {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(columnDefinition = "BIGINT UNSIGNED") private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "device_id", nullable = false) private IotDevice device;
    @Column(name = "message_id", nullable = false, length = 100) private String messageId;
    @Column(name = "measured_at", nullable = false) private Instant measuredAt;
    @Column(name = "received_at", nullable = false, insertable = false, updatable = false) private Instant receivedAt;
    @Column(name = "temperature_c", precision = 5, scale = 2) private BigDecimal temperatureC;
    @Column(precision = 4, scale = 2) private BigDecimal ph;
    @Column(name = "dissolved_oxygen_mg_l", precision = 6, scale = 2) private BigDecimal dissolvedOxygenMgL;
    @Column(name = "turbidity_ntu", precision = 8, scale = 2) private BigDecimal turbidityNtu;
    @Column(name = "tds_mg_l", precision = 8, scale = 2) private BigDecimal tdsMgL;
    @Column(name = "quality_status", nullable = false, length = 24) private String qualityStatus;
    @Column(name = "assessment_level", nullable = false, length = 24) private String assessmentLevel;
    @Column(name = "threshold_version", nullable = false) private int thresholdVersion;
    protected WaterMeasurement() { }
    public WaterMeasurement(IotDevice device, MeasurementDtos.IngestRequest request, String qualityStatus, String level, int version) {
        this.device = device; this.messageId = request.messageId(); this.measuredAt = request.measuredAt();
        var r = request.readings(); this.temperatureC = r.temperatureC(); this.ph = r.ph();
        this.dissolvedOxygenMgL = r.dissolvedOxygenMgL(); this.turbidityNtu = r.turbidityNtu(); this.tdsMgL = r.tdsMgL();
        this.qualityStatus = qualityStatus; this.assessmentLevel = level; this.thresholdVersion = version;
    }
    public Long getId() { return id; }
    public IotDevice getDevice() { return device; }
    public String getMessageId() { return messageId; }
    public Instant getMeasuredAt() { return measuredAt; }
    public Instant getReceivedAt() { return receivedAt; }
    public BigDecimal getTemperatureC() { return temperatureC; }
    public BigDecimal getPh() { return ph; }
    public BigDecimal getDissolvedOxygenMgL() { return dissolvedOxygenMgL; }
    public BigDecimal getTurbidityNtu() { return turbidityNtu; }
    public BigDecimal getTdsMgL() { return tdsMgL; }
    public String getQualityStatus() { return qualityStatus; }
    public String getAssessmentLevel() { return assessmentLevel; }
    public int getThresholdVersion() { return thresholdVersion; }
}
