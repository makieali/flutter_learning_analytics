/// A data point representing progress at a specific time.
class ProgressPoint {
  /// Creates a new [ProgressPoint].
  const ProgressPoint({
    required this.date,
    required this.value,
    this.label,
    this.metadata = const {},
  });

  /// The date/time for this data point.
  final DateTime date;

  /// The value at this point (typically 0.0 to 1.0 or 0 to 100).
  final double value;

  /// Optional label for this point.
  final String? label;

  /// Additional metadata.
  final Map<String, dynamic> metadata;

  /// Creates from JSON.
  factory ProgressPoint.fromJson(Map<String, dynamic> json) {
    return ProgressPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
      'metadata': metadata,
    };
  }

  /// Creates a copy with the given fields replaced.
  ProgressPoint copyWith({
    DateTime? date,
    double? value,
    String? label,
    Map<String, dynamic>? metadata,
  }) {
    return ProgressPoint(
      date: date ?? this.date,
      value: value ?? this.value,
      label: label ?? this.label,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'ProgressPoint(date: $date, value: $value)';
  }
}

/// Aggregated progress data over a time period.
class ProgressSummary {
  /// Creates a new [ProgressSummary].
  const ProgressSummary({
    required this.points,
    required this.startDate,
    required this.endDate,
  });

  /// List of progress points.
  final List<ProgressPoint> points;

  /// Start of the period.
  final DateTime startDate;

  /// End of the period.
  final DateTime endDate;

  /// Average value across all points.
  double get average {
    if (points.isEmpty) return 0;
    return points.map((p) => p.value).reduce((a, b) => a + b) / points.length;
  }

  /// Minimum value.
  double get min {
    if (points.isEmpty) return 0;
    return points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
  }

  /// Maximum value.
  double get max {
    if (points.isEmpty) return 0;
    return points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
  }

  /// The trend direction (-1 = declining, 0 = stable, 1 = improving).
  int get trendDirection {
    if (points.length < 2) return 0;

    final firstHalf = points.sublist(0, points.length ~/ 2);
    final secondHalf = points.sublist(points.length ~/ 2);

    final firstAvg =
        firstHalf.map((p) => p.value).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((p) => p.value).reduce((a, b) => a + b) /
        secondHalf.length;

    final diff = secondAvg - firstAvg;
    if (diff > 0.05) return 1;
    if (diff < -0.05) return -1;
    return 0;
  }

  /// Percentage change from first to last point.
  double? get percentageChange {
    if (points.length < 2) return null;
    final first = points.first.value;
    final last = points.last.value;
    if (first == 0) return null;
    return ((last - first) / first) * 100;
  }

  /// Creates from a list of points.
  factory ProgressSummary.fromPoints(List<ProgressPoint> points) {
    if (points.isEmpty) {
      return ProgressSummary(
        points: const [],
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
    }

    final sorted = List<ProgressPoint>.from(points)
      ..sort((a, b) => a.date.compareTo(b.date));

    return ProgressSummary(
      points: sorted,
      startDate: sorted.first.date,
      endDate: sorted.last.date,
    );
  }
}

/// Skill or topic performance data for radar charts.
class SkillData {
  /// Creates a new [SkillData].
  const SkillData({
    required this.skillId,
    required this.skillName,
    required this.currentValue,
    this.targetValue,
    this.previousValue,
    this.iconName,
  });

  /// Unique identifier for the skill.
  final String skillId;

  /// Display name.
  final String skillName;

  /// Current skill level (0.0 to 1.0).
  final double currentValue;

  /// Target skill level (0.0 to 1.0).
  final double? targetValue;

  /// Previous skill level for comparison.
  final double? previousValue;

  /// Optional icon name.
  final String? iconName;

  /// Change from previous value.
  double? get change {
    if (previousValue == null) return null;
    return currentValue - previousValue!;
  }

  /// Whether the skill is improving.
  bool get isImproving => change != null && change! > 0;

  /// Creates from JSON.
  factory SkillData.fromJson(Map<String, dynamic> json) {
    return SkillData(
      skillId: json['skillId'] as String,
      skillName: json['skillName'] as String,
      currentValue: (json['currentValue'] as num).toDouble(),
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      previousValue: (json['previousValue'] as num?)?.toDouble(),
      iconName: json['iconName'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'skillName': skillName,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'previousValue': previousValue,
      'iconName': iconName,
    };
  }
}
