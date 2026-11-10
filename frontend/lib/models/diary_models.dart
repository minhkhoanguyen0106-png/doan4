class ShrimpProfile {
  const ShrimpProfile({
    required this.siteId,
    required this.siteName,
    required this.areaM2,
    required this.depthM,
    required this.waterVolumeM3,
    required this.shrimpSpecies,
    required this.stockedCount,
    this.stockedOn,
    this.currentDoc,
    required this.farmingStage,
    this.targetHarvestWeightG,
    this.stockingDensityPerM2,
  });

  final int siteId;
  final String siteName;
  final double areaM2;
  final double depthM;
  final double waterVolumeM3;
  final String shrimpSpecies;
  final int stockedCount;
  final DateTime? stockedOn;
  final int? currentDoc;
  final String farmingStage;
  final double? targetHarvestWeightG;
  final double? stockingDensityPerM2;

  factory ShrimpProfile.fromJson(Map<String, dynamic> json) => ShrimpProfile(
        siteId: json['siteId'] as int,
        siteName: json['siteName'] as String? ?? '',
        areaM2: (json['areaM2'] as num?)?.toDouble() ?? 1000.0,
        depthM: (json['depthM'] as num?)?.toDouble() ?? 1.5,
        waterVolumeM3: (json['waterVolumeM3'] as num?)?.toDouble() ?? 1500.0,
        shrimpSpecies: json['shrimpSpecies'] as String? ?? 'Tôm thẻ chân trắng',
        stockedCount: json['stockedCount'] as int? ?? 100000,
        stockedOn: json['stockedOn'] != null ? DateTime.parse(json['stockedOn'] as String) : null,
        currentDoc: json['currentDoc'] as int?,
        farmingStage: json['farmingStage'] as String? ?? 'GIAI_DOAN_1',
        targetHarvestWeightG: (json['targetHarvestWeightG'] as num?)?.toDouble() ?? 25.0,
        stockingDensityPerM2: (json['stockingDensityPerM2'] as num?)?.toDouble() ?? 100.0,
      );

  Map<String, dynamic> toJson() => {
        'areaM2': areaM2,
        'depthM': depthM,
        'shrimpSpecies': shrimpSpecies,
        'stockedCount': stockedCount,
        'stockedOn': stockedOn != null
            ? "${stockedOn!.year.toString().padLeft(4, '0')}-${stockedOn!.month.toString().padLeft(2, '0')}-${stockedOn!.day.toString().padLeft(2, '0')}"
            : null,
        'farmingStage': farmingStage,
        'targetHarvestWeightG': targetHarvestWeightG,
      };
}

class PondFeedingLog {
  const PondFeedingLog({
    required this.id,
    required this.siteId,
    required this.fedAt,
    required this.feedMeal,
    this.feedBrand,
    required this.amountKg,
    required this.feedTrayStatus,
    this.notes,
  });

  final int id;
  final int siteId;
  final DateTime fedAt;
  final String feedMeal;
  final String? feedBrand;
  final double amountKg;
  final String feedTrayStatus;
  final String? notes;

  factory PondFeedingLog.fromJson(Map<String, dynamic> json) => PondFeedingLog(
        id: json['id'] as int,
        siteId: json['siteId'] as int,
        fedAt: DateTime.parse(json['fedAt'] as String),
        feedMeal: json['feedMeal'] as String? ?? 'CỮ 1',
        feedBrand: json['feedBrand'] as String?,
        amountKg: (json['amountKg'] as num?)?.toDouble() ?? 0.0,
        feedTrayStatus: json['feedTrayStatus'] as String? ?? 'HẾT',
        notes: json['notes'] as String?,
      );
}

class ShrimpHealthLog {
  const ShrimpHealthLog({
    required this.id,
    required this.siteId,
    required this.loggedAt,
    this.ageDays,
    required this.averageWeightG,
    this.sizeCountPerKg,
    this.estimatedSurvivalRate,
    required this.healthStatus,
    this.gutCondition,
    this.hepatopancreas,
    this.shellCondition,
    this.notes,
  });

  final int id;
  final int siteId;
  final DateTime loggedAt;
  final int? ageDays;
  final double averageWeightG;
  final int? sizeCountPerKg;
  final double? estimatedSurvivalRate;
  final String healthStatus;
  final String? gutCondition;
  final String? hepatopancreas;
  final String? shellCondition;
  final String? notes;

  factory ShrimpHealthLog.fromJson(Map<String, dynamic> json) => ShrimpHealthLog(
        id: json['id'] as int,
        siteId: json['siteId'] as int,
        loggedAt: DateTime.parse(json['loggedAt'] as String),
        ageDays: json['ageDays'] as int?,
        averageWeightG: (json['averageWeightG'] as num?)?.toDouble() ?? 0.0,
        sizeCountPerKg: json['sizeCountPerKg'] as int?,
        estimatedSurvivalRate: (json['estimatedSurvivalRate'] as num?)?.toDouble() ?? 85.0,
        healthStatus: json['healthStatus'] as String? ?? 'KHỎE_MẠNH',
        gutCondition: json['gutCondition'] as String?,
        hepatopancreas: json['hepatopancreas'] as String?,
        shellCondition: json['shellCondition'] as String?,
        notes: json['notes'] as String?,
      );
}

class PondTreatmentLog {
  const PondTreatmentLog({
    required this.id,
    required this.siteId,
    required this.treatedAt,
    required this.treatmentType,
    required this.productName,
    required this.dosage,
    required this.unit,
    this.purpose,
    this.notes,
  });

  final int id;
  final int siteId;
  final DateTime treatedAt;
  final String treatmentType;
  final String productName;
  final double dosage;
  final String unit;
  final String? purpose;
  final String? notes;

  factory PondTreatmentLog.fromJson(Map<String, dynamic> json) => PondTreatmentLog(
        id: json['id'] as int,
        siteId: json['siteId'] as int,
        treatedAt: DateTime.parse(json['treatedAt'] as String),
        treatmentType: json['treatmentType'] as String? ?? 'KHAC',
        productName: json['productName'] as String? ?? '',
        dosage: (json['dosage'] as num?)?.toDouble() ?? 0.0,
        unit: json['unit'] as String? ?? 'kg',
        purpose: json['purpose'] as String?,
        notes: json['notes'] as String?,
      );
}

class PondWaterOperation {
  const PondWaterOperation({
    required this.id,
    required this.siteId,
    required this.operatedAt,
    required this.operationType,
    this.volumeM3,
    this.waterSource,
    this.notes,
  });

  final int id;
  final int siteId;
  final DateTime operatedAt;
  final String operationType;
  final double? volumeM3;
  final String? waterSource;
  final String? notes;

  factory PondWaterOperation.fromJson(Map<String, dynamic> json) => PondWaterOperation(
        id: json['id'] as int,
        siteId: json['siteId'] as int,
        operatedAt: DateTime.parse(json['operatedAt'] as String),
        operationType: json['operationType'] as String? ?? 'THAY_NUOC',
        volumeM3: (json['volumeM3'] as num?)?.toDouble(),
        waterSource: json['waterSource'] as String?,
        notes: json['notes'] as String?,
      );
}

class DailyFeedPoint {
  const DailyFeedPoint({
    required this.dateLabel,
    required this.amountKg,
    required this.mealsCount,
  });

  final String dateLabel;
  final double amountKg;
  final int mealsCount;

  factory DailyFeedPoint.fromJson(Map<String, dynamic> json) => DailyFeedPoint(
        dateLabel: json['dateLabel'] as String? ?? '',
        amountKg: (json['amountKg'] as num?)?.toDouble() ?? 0.0,
        mealsCount: json['mealsCount'] as int? ?? 0,
      );
}

class GrowthCurvePoint {
  const GrowthCurvePoint({
    required this.doc,
    required this.actualWeightG,
    required this.standardWeightG,
  });

  final int doc;
  final double actualWeightG;
  final double standardWeightG;

  factory GrowthCurvePoint.fromJson(Map<String, dynamic> json) => GrowthCurvePoint(
        doc: json['doc'] as int? ?? 0,
        actualWeightG: (json['actualWeightG'] as num?)?.toDouble() ?? 0.0,
        standardWeightG: (json['standardWeightG'] as num?)?.toDouble() ?? 0.0,
      );
}

class DiaryAnalytics {
  const DiaryAnalytics({
    required this.totalFeedKg,
    this.estimatedBiomassKg,
    this.fcr,
    this.currentDoc,
    this.survivalRatePercent,
    this.currentAvgWeightG,
    this.currentSizeCountPerKg,
    this.treatmentCount = 0,
    this.waterOpCount = 0,
    this.dailyFeedTrend = const [],
    this.growthCurve = const [],
  });

  final double totalFeedKg;
  final double? estimatedBiomassKg;
  final double? fcr;
  final int? currentDoc;
  final double? survivalRatePercent;
  final double? currentAvgWeightG;
  final int? currentSizeCountPerKg;
  final int treatmentCount;
  final int waterOpCount;
  final List<DailyFeedPoint> dailyFeedTrend;
  final List<GrowthCurvePoint> growthCurve;

  factory DiaryAnalytics.fromJson(Map<String, dynamic> json) => DiaryAnalytics(
        totalFeedKg: (json['totalFeedKg'] as num?)?.toDouble() ?? 0.0,
        estimatedBiomassKg: (json['estimatedBiomassKg'] as num?)?.toDouble(),
        fcr: (json['fcr'] as num?)?.toDouble(),
        currentDoc: json['currentDoc'] as int?,
        survivalRatePercent: (json['survivalRatePercent'] as num?)?.toDouble(),
        currentAvgWeightG: (json['currentAvgWeightG'] as num?)?.toDouble(),
        currentSizeCountPerKg: json['currentSizeCountPerKg'] as int?,
        treatmentCount: json['treatmentCount'] as int? ?? 0,
        waterOpCount: json['waterOpCount'] as int? ?? 0,
        dailyFeedTrend: (json['dailyFeedTrend'] as List?)
                ?.map((e) => DailyFeedPoint.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        growthCurve: (json['growthCurve'] as List?)
                ?.map((e) => GrowthCurvePoint.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
