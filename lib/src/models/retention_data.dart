import 'dart:math' as math;

/// Data model for tracking memory retention and forgetting curves.
///
/// Based on Ebbinghaus forgetting curve: R = e^(-t/S)
/// Where R = retention, t = time since last review, S = stability
class RetentionData {
  /// Creates a new [RetentionData].
  const RetentionData({
    required this.itemId,
    required this.createdAt,
    required this.stability,
    this.difficulty = 0.5,
    this.reviews = const [],
    this.retrievability,
  });

  /// Unique identifier for the item being tracked.
  final String itemId;

  /// When the item was first learned.
  final DateTime createdAt;

  /// Memory stability in days (how long before retention drops significantly).
  /// Higher values mean slower forgetting.
  final double stability;

  /// Item difficulty (0.0 = easy, 1.0 = hard).
  final double difficulty;

  /// List of review dates.
  final List<ReviewRecord> reviews;

  /// Current retrievability (0.0 to 1.0), if pre-calculated.
  final double? retrievability;

  /// Calculates current retrievability using the forgetting curve formula.
  /// R = e^(-t/S) where t = time since last review, S = stability
  double calculateRetrievability([DateTime? atTime]) {
    if (retrievability != null && atTime == null) return retrievability!;

    final now = atTime ?? DateTime.now();
    final lastReview = reviews.isNotEmpty ? reviews.last.date : createdAt;
    final daysSinceReview = now.difference(lastReview).inHours / 24.0;

    if (daysSinceReview <= 0) return 1.0;

    return math.exp(-daysSinceReview / stability);
  }

  /// Calculates retrievability at various time points for plotting.
  List<RetentionPoint> calculateRetentionCurve({
    int days = 30,
    int pointsPerDay = 4,
  }) {
    final points = <RetentionPoint>[];
    final startDate = reviews.isNotEmpty ? reviews.last.date : createdAt;

    for (int i = 0; i <= days * pointsPerDay; i++) {
      final hoursOffset = (i * 24) ~/ pointsPerDay;
      final date = startDate.add(Duration(hours: hoursOffset));
      final retention = calculateRetrievability(date);
      points.add(RetentionPoint(date: date, retention: retention));
    }

    return points;
  }

  /// Calculates when the next review should happen for optimal retention.
  DateTime calculateOptimalReviewTime({double targetRetention = 0.9}) {
    // Solve for t: targetRetention = e^(-t/S)
    // t = -S * ln(targetRetention)
    final daysUntilTarget = -stability * math.log(targetRetention);
    final lastReview = reviews.isNotEmpty ? reviews.last.date : createdAt;

    return lastReview.add(
      Duration(hours: (daysUntilTarget * 24).round()),
    );
  }

  /// Whether a review is due (retrievability below threshold).
  bool isReviewDue({double threshold = 0.9}) {
    return calculateRetrievability() < threshold;
  }

  /// Days until retrievability drops below threshold.
  double daysUntilReviewDue({double threshold = 0.9}) {
    final current = calculateRetrievability();
    if (current < threshold) return 0;

    // Solve for t: threshold = current * e^(-t/S)
    // Note: We're calculating from now, not from last review
    final t = -stability * math.log(threshold / current);
    return t;
  }

  /// Number of reviews completed.
  int get reviewCount => reviews.length;

  /// Average interval between reviews in days.
  double? get averageReviewInterval {
    if (reviews.length < 2) return null;

    double totalDays = 0;
    for (int i = 1; i < reviews.length; i++) {
      totalDays +=
          reviews[i].date.difference(reviews[i - 1].date).inHours / 24.0;
    }

    return totalDays / (reviews.length - 1);
  }

  /// Creates a copy with the given fields replaced.
  RetentionData copyWith({
    String? itemId,
    DateTime? createdAt,
    double? stability,
    double? difficulty,
    List<ReviewRecord>? reviews,
    double? retrievability,
  }) {
    return RetentionData(
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reviews: reviews ?? this.reviews,
      retrievability: retrievability ?? this.retrievability,
    );
  }

  /// Creates a [RetentionData] with a new review added.
  RetentionData addReview({
    required DateTime date,
    required int rating,
    double? newStability,
  }) {
    final newReviews = [
      ...reviews,
      ReviewRecord(date: date, rating: rating),
    ];

    return copyWith(
      reviews: newReviews,
      stability: newStability ?? stability,
    );
  }

  /// Creates from JSON.
  factory RetentionData.fromJson(Map<String, dynamic> json) {
    return RetentionData(
      itemId: json['itemId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      stability: (json['stability'] as num).toDouble(),
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      retrievability: (json['retrievability'] as num?)?.toDouble(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'createdAt': createdAt.toIso8601String(),
      'stability': stability,
      'difficulty': difficulty,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'retrievability': retrievability,
    };
  }

  @override
  String toString() {
    return 'RetentionData(itemId: $itemId, stability: ${stability.toStringAsFixed(1)} days, '
        'retrievability: ${(calculateRetrievability() * 100).toStringAsFixed(1)}%)';
  }
}

/// A single review record.
class ReviewRecord {
  /// Creates a new [ReviewRecord].
  const ReviewRecord({
    required this.date,
    required this.rating,
  });

  /// When the review occurred.
  final DateTime date;

  /// Rating given (typically 1-4, where 4 is best recall).
  final int rating;

  /// Creates from JSON.
  factory ReviewRecord.fromJson(Map<String, dynamic> json) {
    return ReviewRecord(
      date: DateTime.parse(json['date'] as String),
      rating: json['rating'] as int,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'rating': rating,
    };
  }
}

/// A point on the retention curve.
class RetentionPoint {
  /// Creates a new [RetentionPoint].
  const RetentionPoint({
    required this.date,
    required this.retention,
  });

  /// The date/time for this point.
  final DateTime date;

  /// The retention value (0.0 to 1.0).
  final double retention;

  /// The retention as a percentage (0 to 100).
  double get percentage => retention * 100;
}

/// Aggregated retention statistics for multiple items.
class RetentionStats {
  /// Creates a new [RetentionStats].
  const RetentionStats({
    required this.totalItems,
    required this.itemsDue,
    required this.averageRetention,
    required this.averageStability,
    this.retentionDistribution = const {},
  });

  /// Total number of items being tracked.
  final int totalItems;

  /// Number of items due for review.
  final int itemsDue;

  /// Average retention across all items.
  final double averageRetention;

  /// Average stability across all items.
  final double averageStability;

  /// Distribution of items by retention level.
  /// Key: retention bucket (e.g., '0-20', '20-40', etc.)
  final Map<String, int> retentionDistribution;

  /// Percentage of items that are due.
  double get percentageDue {
    if (totalItems == 0) return 0;
    return (itemsDue / totalItems) * 100;
  }

  /// Creates from a list of [RetentionData].
  factory RetentionStats.fromItems(
    List<RetentionData> items, {
    double dueThreshold = 0.9,
  }) {
    if (items.isEmpty) {
      return const RetentionStats(
        totalItems: 0,
        itemsDue: 0,
        averageRetention: 0,
        averageStability: 0,
      );
    }

    double totalRetention = 0;
    double totalStability = 0;
    int due = 0;
    final distribution = <String, int>{
      '0-20': 0,
      '20-40': 0,
      '40-60': 0,
      '60-80': 0,
      '80-100': 0,
    };

    for (final item in items) {
      final retention = item.calculateRetrievability();
      totalRetention += retention;
      totalStability += item.stability;

      if (retention < dueThreshold) due++;

      final percentage = retention * 100;
      if (percentage < 20) {
        distribution['0-20'] = distribution['0-20']! + 1;
      } else if (percentage < 40) {
        distribution['20-40'] = distribution['20-40']! + 1;
      } else if (percentage < 60) {
        distribution['40-60'] = distribution['40-60']! + 1;
      } else if (percentage < 80) {
        distribution['60-80'] = distribution['60-80']! + 1;
      } else {
        distribution['80-100'] = distribution['80-100']! + 1;
      }
    }

    return RetentionStats(
      totalItems: items.length,
      itemsDue: due,
      averageRetention: totalRetention / items.length,
      averageStability: totalStability / items.length,
      retentionDistribution: distribution,
    );
  }
}
