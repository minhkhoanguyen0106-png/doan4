package com.example.backend.diary;

import com.example.backend.monitor.MonitoringSite;
import com.example.backend.monitor.MonitoringSiteRepository;
import com.example.backend.user.User;
import com.example.backend.user.UserRepository;
import com.example.backend.user.UserRole;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
public class AquacultureDiaryService {
    private final MonitoringSiteRepository sites;
    private final UserRepository users;
    private final PondFeedingLogRepository feedings;
    private final ShrimpHealthLogRepository healthLogs;
    private final PondTreatmentLogRepository treatments;
    private final PondWaterOperationRepository waterOps;

    public AquacultureDiaryService(
            MonitoringSiteRepository sites,
            UserRepository users,
            PondFeedingLogRepository feedings,
            ShrimpHealthLogRepository healthLogs,
            PondTreatmentLogRepository treatments,
            PondWaterOperationRepository waterOps
    ) {
        this.sites = sites;
        this.users = users;
        this.feedings = feedings;
        this.healthLogs = healthLogs;
        this.treatments = treatments;
        this.waterOps = waterOps;
    }

    private MonitoringSite getAuthorizedSite(String email, Long siteId) {
        User user = users.findByEmail(email.toLowerCase())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Không tìm thấy người dùng."));
        MonitoringSite site = sites.findById(siteId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy ao nuôi."));
        if (user.getRole() != UserRole.ADMIN && !site.getOwner().getId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Bạn không có quyền truy cập ao này.");
        }
        return site;
    }

    public DiaryDtos.ShrimpProfileResponse getShrimpProfile(String email, Long siteId) {
        MonitoringSite site = getAuthorizedSite(email, siteId);
        return mapToProfileResponse(site);
    }

    @Transactional
    public DiaryDtos.ShrimpProfileResponse updateShrimpProfile(String email, Long siteId, DiaryDtos.ShrimpProfileRequest req) {
        MonitoringSite site = getAuthorizedSite(email, siteId);
        site.updateShrimpProfile(
                req.areaM2(),
                req.depthM(),
                req.shrimpSpecies(),
                req.stockedCount(),
                req.stockedOn(),
                req.farmingStage(),
                req.targetHarvestWeightG()
        );
        return mapToProfileResponse(sites.save(site));
    }

    private DiaryDtos.ShrimpProfileResponse mapToProfileResponse(MonitoringSite site) {
        BigDecimal area = site.getAreaM2() != null ? site.getAreaM2() : BigDecimal.valueOf(1000.00);
        BigDecimal depth = site.getDepthM() != null ? site.getDepthM() : BigDecimal.valueOf(1.50);
        BigDecimal volume = area.multiply(depth).setScale(2, RoundingMode.HALF_UP);

        Integer doc = null;
        if (site.getStockedOn() != null) {
            doc = (int) ChronoUnit.DAYS.between(site.getStockedOn(), LocalDate.now());
            if (doc < 0) doc = 0;
        }

        Double density = null;
        if (site.getStockedCount() != null && area.doubleValue() > 0) {
            density = Math.round((site.getStockedCount() / area.doubleValue()) * 10.0) / 10.0;
        }

        return new DiaryDtos.ShrimpProfileResponse(
                site.getId(),
                site.getName(),
                area,
                depth,
                volume,
                site.getShrimpSpecies(),
                site.getStockedCount(),
                site.getStockedOn(),
                doc,
                site.getFarmingStage(),
                site.getTargetHarvestWeightG(),
                density
        );
    }

    public List<DiaryDtos.FeedingResponse> listFeedings(String email, Long siteId) {
        getAuthorizedSite(email, siteId);
        return feedings.findAllBySite_IdOrderByFedAtDesc(siteId).stream()
                .map(DiaryDtos.FeedingResponse::from)
                .toList();
    }

    @Transactional
    public DiaryDtos.FeedingResponse addFeeding(String email, Long siteId, DiaryDtos.FeedingRequest req) {
        MonitoringSite site = getAuthorizedSite(email, siteId);
        PondFeedingLog log = new PondFeedingLog(
                site,
                req.fedAt(),
                req.feedMeal(),
                req.feedBrand(),
                req.amountKg(),
                req.feedTrayStatus(),
                req.notes()
        );
        return DiaryDtos.FeedingResponse.from(feedings.save(log));
    }

    @Transactional
    public void deleteFeeding(String email, Long siteId, Long logId) {
        getAuthorizedSite(email, siteId);
        feedings.deleteById(logId);
    }

    public List<DiaryDtos.HealthResponse> listHealthLogs(String email, Long siteId) {
        getAuthorizedSite(email, siteId);
        return healthLogs.findAllBySite_IdOrderByLoggedAtDesc(siteId).stream()
                .map(DiaryDtos.HealthResponse::from)
                .toList();
    }

    @Transactional
    public DiaryDtos.HealthResponse addHealthLog(String email, Long siteId, DiaryDtos.HealthRequest req) {
        MonitoringSite site = getAuthorizedSite(email, siteId);
        Integer ageDays = req.ageDays();
        if (ageDays == null && site.getStockedOn() != null) {
            LocalDate logDate = req.loggedAt().atZone(ZoneId.systemDefault()).toLocalDate();
            ageDays = (int) ChronoUnit.DAYS.between(site.getStockedOn(), logDate);
            if (ageDays < 0) ageDays = 0;
        }

        ShrimpHealthLog log = new ShrimpHealthLog(
                site,
                req.loggedAt(),
                ageDays,
                req.averageWeightG(),
                req.estimatedSurvivalRate(),
                req.healthStatus(),
                req.gutCondition(),
                req.hepatopancreas(),
                req.shellCondition(),
                req.notes()
        );
        return DiaryDtos.HealthResponse.from(healthLogs.save(log));
    }

    @Transactional
    public void deleteHealthLog(String email, Long siteId, Long logId) {
        getAuthorizedSite(email, siteId);
        healthLogs.deleteById(logId);
    }

    public List<DiaryDtos.TreatmentResponse> listTreatments(String email, Long siteId) {
        getAuthorizedSite(email, siteId);
        return treatments.findAllBySite_IdOrderByTreatedAtDesc(siteId).stream()
                .map(DiaryDtos.TreatmentResponse::from)
                .toList();
    }

    @Transactional
    public DiaryDtos.TreatmentResponse addTreatment(String email, Long siteId, DiaryDtos.TreatmentRequest req) {
        MonitoringSite site = getAuthorizedSite(email, siteId);
        PondTreatmentLog log = new PondTreatmentLog(
                site,
                req.treatedAt(),
                req.treatmentType(),
                req.productName(),
                req.dosage(),
                req.unit(),
                req.purpose(),
                req.notes()
        );
        return DiaryDtos.TreatmentResponse.from(treatments.save(log));
    }

    @Transactional
    public void deleteTreatment(String email, Long siteId, Long logId) {
        getAuthorizedSite(email, siteId);
        treatments.deleteById(logId);
    }

    public List<DiaryDtos.WaterOpResponse> listWaterOps(String email, Long siteId) {
        getAuthorizedSite(email, siteId);
        return waterOps.findAllBySite_IdOrderByOperatedAtDesc(siteId).stream()
                .map(DiaryDtos.WaterOpResponse::from)
                .toList();
    }

    @Transactional
    public DiaryDtos.WaterOpResponse addWaterOp(String email, Long siteId, DiaryDtos.WaterOpRequest req) {
        MonitoringSite site = getAuthorizedSite(email, siteId);
        PondWaterOperation log = new PondWaterOperation(
                site,
                req.operatedAt(),
                req.operationType(),
                req.volumeM3(),
                req.waterSource(),
                req.notes()
        );
        return DiaryDtos.WaterOpResponse.from(waterOps.save(log));
    }

    @Transactional
    public void deleteWaterOp(String email, Long siteId, Long logId) {
        getAuthorizedSite(email, siteId);
        waterOps.deleteById(logId);
    }

    public DiaryDtos.DiaryAnalyticsResponse getAnalytics(String email, Long siteId) {
        MonitoringSite site = getAuthorizedSite(email, siteId);
        List<PondFeedingLog> feedingList = feedings.findAllBySite_IdOrderByFedAtDesc(siteId);
        Optional<ShrimpHealthLog> latestHealthOpt = healthLogs.findFirstBySite_IdOrderByLoggedAtDesc(siteId);
        List<ShrimpHealthLog> allHealthLogs = healthLogs.findAllBySite_IdOrderByLoggedAtAsc(siteId);

        BigDecimal totalFeedKg = feedingList.stream()
                .map(PondFeedingLog::getAmountKg)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);

        Integer doc = null;
        if (site.getStockedOn() != null) {
            doc = (int) ChronoUnit.DAYS.between(site.getStockedOn(), LocalDate.now());
            if (doc < 0) doc = 0;
        }

        Double currentAvgWeightG = null;
        Integer currentSizeCount = null;
        Double survivalRate = 85.0;

        if (latestHealthOpt.isPresent()) {
            ShrimpHealthLog latest = latestHealthOpt.get();
            if (latest.getAverageWeightG() != null) {
                currentAvgWeightG = latest.getAverageWeightG().doubleValue();
                if (currentAvgWeightG > 0) {
                    currentSizeCount = (int) Math.round(1000.0 / currentAvgWeightG);
                }
            }
            if (latest.getEstimatedSurvivalRate() != null) {
                survivalRate = latest.getEstimatedSurvivalRate().doubleValue();
            }
        } else if (doc != null && doc > 0) {
            // Ước tính sơ bộ theo đường cong sinh học nếu chưa cân đo
            currentAvgWeightG = Math.round(0.005 * Math.pow(doc, 2.1) * 10.0) / 10.0;
            if (currentAvgWeightG > 35.0) currentAvgWeightG = 35.0;
            currentSizeCount = (int) Math.round(1000.0 / currentAvgWeightG);
        }

        Double estimatedBiomassKg = null;
        Double fcr = null;

        if (site.getStockedCount() != null && currentAvgWeightG != null && currentAvgWeightG > 0) {
            double shrimpRemaining = site.getStockedCount() * (survivalRate / 100.0);
            estimatedBiomassKg = Math.round((shrimpRemaining * currentAvgWeightG / 1000.0) * 10.0) / 10.0;
            if (estimatedBiomassKg > 0 && totalFeedKg.doubleValue() > 0) {
                fcr = Math.round((totalFeedKg.doubleValue() / estimatedBiomassKg) * 100.0) / 100.0;
            }
        }

        // Daily Feed Trend (group by day)
        Map<String, double[]> dailyMap = new TreeMap<>();
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM");
        ZoneId zone = ZoneId.systemDefault();

        for (PondFeedingLog f : feedingList) {
            String dayKey = f.getFedAt().atZone(zone).format(dtf);
            double[] agg = dailyMap.computeIfAbsent(dayKey, k -> new double[]{0.0, 0.0});
            agg[0] += f.getAmountKg().doubleValue();
            agg[1] += 1.0;
        }

        List<DiaryDtos.DailyFeedPoint> dailyFeedTrend = new ArrayList<>();
        dailyMap.forEach((k, v) -> dailyFeedTrend.add(new DiaryDtos.DailyFeedPoint(k, Math.round(v[0] * 10.0) / 10.0, (int) v[1])));

        // Growth Curve (Actual vs VietGAP Standard)
        List<DiaryDtos.GrowthCurvePoint> growthCurve = new ArrayList<>();
        if (!allHealthLogs.isEmpty()) {
            for (ShrimpHealthLog h : allHealthLogs) {
                int d = h.getAgeDays() != null ? h.getAgeDays() : 0;
                double actual = h.getAverageWeightG().doubleValue();
                double standard = Math.round(0.006 * Math.pow(Math.max(d, 1), 2.05) * 10.0) / 10.0;
                growthCurve.add(new DiaryDtos.GrowthCurvePoint(d, actual, standard));
            }
        } else if (doc != null) {
            for (int d = 5; d <= doc; d += 5) {
                double std = Math.round(0.006 * Math.pow(d, 2.05) * 10.0) / 10.0;
                growthCurve.add(new DiaryDtos.GrowthCurvePoint(d, std, std));
            }
        }

        long treatmentCount = treatments.countBySite_Id(siteId);
        long waterOpCount = waterOps.countBySite_Id(siteId);

        return new DiaryDtos.DiaryAnalyticsResponse(
                totalFeedKg,
                estimatedBiomassKg,
                fcr,
                doc,
                survivalRate,
                currentAvgWeightG,
                currentSizeCount,
                treatmentCount,
                waterOpCount,
                dailyFeedTrend,
                growthCurve
        );
    }
}

