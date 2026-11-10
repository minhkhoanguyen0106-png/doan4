package com.example.backend.monitor;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;

@Service
public class WaterAssessmentService {
    public static final int THRESHOLD_VERSION = 1;
    private final BigDecimal phWatchMin, phWatchMax, phHighMin, phHighMax, phCriticalMin, phCriticalMax;
    private final BigDecimal doWatchMin, doHighMin, doCriticalMin, turbidityWatchMax, turbidityHighMax, turbidityCriticalMax;
    private final BigDecimal tdsWatchMax, tdsHighMax, tdsCriticalMax;
    public WaterAssessmentService(
            @Value("${monitoring.thresholds.ph-watch-min:7.5}") BigDecimal phWatchMin,
            @Value("${monitoring.thresholds.ph-watch-max:8.5}") BigDecimal phWatchMax,
            @Value("${monitoring.thresholds.ph-high-min:7.0}") BigDecimal phHighMin,
            @Value("${monitoring.thresholds.ph-high-max:9.0}") BigDecimal phHighMax,
            @Value("${monitoring.thresholds.ph-critical-min:6.5}") BigDecimal phCriticalMin,
            @Value("${monitoring.thresholds.ph-critical-max:9.5}") BigDecimal phCriticalMax,
            @Value("${monitoring.thresholds.do-watch-min:5.0}") BigDecimal doWatchMin,
            @Value("${monitoring.thresholds.do-high-min:4.0}") BigDecimal doHighMin,
            @Value("${monitoring.thresholds.do-critical-min:2.0}") BigDecimal doCriticalMin,
            @Value("${monitoring.thresholds.turbidity-watch-max:5}") BigDecimal turbidityWatchMax,
            @Value("${monitoring.thresholds.turbidity-high-max:25}") BigDecimal turbidityHighMax,
            @Value("${monitoring.thresholds.turbidity-critical-max:50}") BigDecimal turbidityCriticalMax,
            @Value("${monitoring.thresholds.tds-watch-max:500}") BigDecimal tdsWatchMax,
            @Value("${monitoring.thresholds.tds-high-max:1000}") BigDecimal tdsHighMax,
            @Value("${monitoring.thresholds.tds-critical-max:2000}") BigDecimal tdsCriticalMax) {
        this.phWatchMin=phWatchMin; this.phWatchMax=phWatchMax; this.phHighMin=phHighMin; this.phHighMax=phHighMax;
        this.phCriticalMin=phCriticalMin; this.phCriticalMax=phCriticalMax; this.doWatchMin=doWatchMin;
        this.doHighMin=doHighMin; this.doCriticalMin=doCriticalMin; this.turbidityWatchMax=turbidityWatchMax;
        this.turbidityHighMax=turbidityHighMax; this.turbidityCriticalMax=turbidityCriticalMax;
        this.tdsWatchMax=tdsWatchMax; this.tdsHighMax=tdsHighMax; this.tdsCriticalMax=tdsCriticalMax;
    }
    public static double calculateToxicNH3Percent(double ph, double tempC) {
        double pKa = 0.09018 + (2729.92 / (273.15 + tempC));
        return 100.0 / (1.0 + Math.pow(10.0, pKa - ph));
    }

    public static double calculateSalinityPpt(double tdsMgL) {
        return (tdsMgL / 1000.0) * 1.05;
    }

    public String assess(MeasurementDtos.Readings r) {
        int level = assessRange(r.ph(), phWatchMin, phWatchMax, phHighMin, phHighMax, phCriticalMin, phCriticalMax);
        level = Math.max(level, assessLow(r.dissolvedOxygenMgL(), doWatchMin, doHighMin, doCriticalMin));
        level = Math.max(level, assessHigh(r.turbidityNtu(), turbidityWatchMax, turbidityHighMax, turbidityCriticalMax));
        level = Math.max(level, assessHigh(r.tdsMgL(), tdsWatchMax, tdsHighMax, tdsCriticalMax));

        // Soft Sensor: Evaluate Toxic NH3
        if (r.ph() != null) {
            double temp = r.temperatureC() != null ? r.temperatureC().doubleValue() : 28.0;
            double nh3 = calculateToxicNH3Percent(r.ph().doubleValue(), temp);
            if (nh3 >= 20.0) {
                level = Math.max(level, 3); // CRITICAL
            } else if (nh3 >= 10.0) {
                level = Math.max(level, 2); // HIGH
            } else if (nh3 >= 5.0) {
                level = Math.max(level, 1); // WATCH
            }
        }

        // Evaluate Salinity
        if (r.tdsMgL() != null) {
            double sal = calculateSalinityPpt(r.tdsMgL().doubleValue());
            if (sal < 2.0 || sal > 38.0) {
                level = Math.max(level, 3); // CRITICAL
            } else if (sal < 5.0 || sal > 32.0) {
                level = Math.max(level, 2); // HIGH
            } else if (sal < 8.0 || sal > 28.0) {
                level = Math.max(level, 1); // WATCH
            }
        }

        return switch (level) { case 3 -> "CRITICAL"; case 2 -> "HIGH"; case 1 -> "WATCH"; default -> "GOOD"; };
    }
    private int assessRange(BigDecimal v, BigDecimal watchMin, BigDecimal watchMax, BigDecimal highMin, BigDecimal highMax, BigDecimal criticalMin, BigDecimal criticalMax) {
        if (v == null) return 0;
        if (v.compareTo(criticalMin) < 0 || v.compareTo(criticalMax) > 0) return 3;
        if (v.compareTo(highMin) < 0 || v.compareTo(highMax) > 0) return 2;
        if (v.compareTo(watchMin) < 0 || v.compareTo(watchMax) > 0) return 1;
        return 0;
    }
    private int assessLow(BigDecimal v, BigDecimal watch, BigDecimal high, BigDecimal critical) {
        if (v == null) return 0;
        if (v.compareTo(critical) < 0) return 3;
        if (v.compareTo(high) < 0) return 2;
        if (v.compareTo(watch) < 0) return 1;
        return 0;
    }
    private int assessHigh(BigDecimal v, BigDecimal watch, BigDecimal high, BigDecimal critical) {
        if (v == null) return 0;
        if (v.compareTo(critical) > 0) return 3;
        if (v.compareTo(high) > 0) return 2;
        if (v.compareTo(watch) > 0) return 1;
        return 0;
    }
    public static String worst(String a, String b) { return rank(a) >= rank(b) ? a : b; }
    private static int rank(String s) { return switch (s) { case "CRITICAL" -> 3; case "HIGH" -> 2; case "WATCH" -> 1; default -> 0; }; }
}
