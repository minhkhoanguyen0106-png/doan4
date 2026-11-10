class AquacultureSpecies {
  const AquacultureSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.icon,
    required this.optimalPhMin,
    required this.optimalPhMax,
    required this.optimalDoMin,
    required this.optimalTempMin,
    required this.optimalTempMax,
    required this.maxTurbidity,
    required this.description,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String scientificName;
  final String icon;
  final double optimalPhMin;
  final double optimalPhMax;
  final double optimalDoMin;
  final double optimalTempMin;
  final double optimalTempMax;
  final double maxTurbidity;
  final String description;
  final bool isCustom;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientificName': scientificName,
        'icon': icon,
        'optimalPhMin': optimalPhMin,
        'optimalPhMax': optimalPhMax,
        'optimalDoMin': optimalDoMin,
        'optimalTempMin': optimalTempMin,
        'optimalTempMax': optimalTempMax,
        'maxTurbidity': maxTurbidity,
        'description': description,
        'isCustom': isCustom,
      };

  factory AquacultureSpecies.fromJson(Map<String, dynamic> json) => AquacultureSpecies(
        id: json['id'] as String,
        name: json['name'] as String,
        scientificName: json['scientificName'] as String? ?? '',
        icon: json['icon'] as String? ?? '🐟',
        optimalPhMin: (json['optimalPhMin'] as num).toDouble(),
        optimalPhMax: (json['optimalPhMax'] as num).toDouble(),
        optimalDoMin: (json['optimalDoMin'] as num).toDouble(),
        optimalTempMin: (json['optimalTempMin'] as num).toDouble(),
        optimalTempMax: (json['optimalTempMax'] as num).toDouble(),
        maxTurbidity: (json['maxTurbidity'] as num).toDouble(),
        description: json['description'] as String? ?? '',
        isCustom: json['isCustom'] as bool? ?? true,
      );

  static const List<AquacultureSpecies> presets = [
    AquacultureSpecies(
      id: 'shrimp_white',
      name: 'Tôm thẻ chân trắng',
      scientificName: 'Litopenaeus vannamei',
      icon: '🦐',
      optimalPhMin: 7.5,
      optimalPhMax: 8.5,
      optimalDoMin: 4.0,
      optimalTempMin: 28.0,
      optimalTempMax: 32.0,
      maxTurbidity: 25.0,
      description: 'Nhạy cảm cao với biến động pH rạng sáng và sụt giảm oxy hòa tan đáy ao.',
    ),
    AquacultureSpecies(
      id: 'shrimp_black_tiger',
      name: 'Tôm sú',
      scientificName: 'Penaeus monodon',
      icon: '🦞',
      optimalPhMin: 7.5,
      optimalPhMax: 8.3,
      optimalDoMin: 3.5,
      optimalTempMin: 27.0,
      optimalTempMax: 31.0,
      maxTurbidity: 30.0,
      description: 'Yêu cầu độ kiềm ổn định 100-150 mg/L, hạn chế sốc nhiệt khi mưa lớn.',
    ),
    AquacultureSpecies(
      id: 'shrimp_giant_prawn',
      name: 'Tôm càng xanh',
      scientificName: 'Macrobrachium rosenbergii',
      icon: '🦐',
      optimalPhMin: 7.0,
      optimalPhMax: 8.5,
      optimalDoMin: 3.5,
      optimalTempMin: 28.0,
      optimalTempMax: 31.0,
      maxTurbidity: 40.0,
      description: 'Ưa nước ngọt hoặc lợ nhẹ, nhạy cảm với thiếu oxy khi tôm lột xác đồng loạt.',
    ),
  ];
}

