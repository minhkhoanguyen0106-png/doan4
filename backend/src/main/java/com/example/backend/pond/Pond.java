package com.example.backend.pond;

import com.example.backend.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "ponds")
public class Pond {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "BIGINT UNSIGNED")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User owner;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(name = "area_m2", nullable = false, precision = 10, scale = 2)
    private BigDecimal areaM2;

    @Column(name = "depth_m", nullable = false, precision = 6, scale = 2)
    private BigDecimal depthM;

    @Column(name = "fish_species", length = 120)
    private String fishSpecies;

    @Column(name = "initial_fish_count")
    private Integer initialFishCount;

    @Column(name = "started_on")
    private LocalDate startedOn;

    @Column(length = 255)
    private String location;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private PondStatus status = PondStatus.ACTIVE;

    protected Pond() { }

    public Pond(User owner, PondDtos.PondRequest request) {
        this.owner = owner;
        update(request);
        this.status = PondStatus.ACTIVE;
    }

    public void update(PondDtos.PondRequest request) {
        this.name = request.name().trim();
        this.areaM2 = request.areaM2();
        this.depthM = request.depthM();
        this.fishSpecies = blankToNull(request.fishSpecies());
        this.initialFishCount = request.initialFishCount();
        this.startedOn = request.startedOn();
        this.location = blankToNull(request.location());
        this.notes = blankToNull(request.notes());
    }

    public void deactivate() { this.status = PondStatus.INACTIVE; }
    public Long getId() { return id; }
    public User getOwner() { return owner; }
    public String getName() { return name; }
    public BigDecimal getAreaM2() { return areaM2; }
    public BigDecimal getDepthM() { return depthM; }
    public String getFishSpecies() { return fishSpecies; }
    public Integer getInitialFishCount() { return initialFishCount; }
    public LocalDate getStartedOn() { return startedOn; }
    public String getLocation() { return location; }
    public String getNotes() { return notes; }
    public PondStatus getStatus() { return status; }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
