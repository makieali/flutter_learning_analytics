import 'dart:math' as math;

import '../models/retention_data.dart';

/// Calculator for memory retention based on the Ebbinghaus forgetting curve.
///
/// The forgetting curve formula: R = e^(-t/S)
/// Where R = retrievability, t = time since last review, S = stability
class RetentionCalculator {
  /// Creates a new [RetentionCalculator].
  const RetentionCalculator({
    this.initialStability = 1.0,
    this.stabilityGrowthFactor = 2.5,
    this.difficultyWeight = 0.5,
    this.targetRetention = 0.9,
  });

  /// Initial stability for new items (in days).
  final double initialStability;

  /// Factor by which stability increases after successful review.
  final double stabilityGrowthFactor;

  /// Weight given to difficulty when adjusting stability.
  final double difficultyWeight;

  /// Default target retention level.
  final double targetRetention;

  /// Calculates current retrievability for an item.
  ///
  /// [daysSinceReview] - Days since the last review
  /// [stability] - Current stability in days
  double calculateRetrievability({
    required double daysSinceReview,
    required double stability,
  }) {
    if (daysSinceReview <= 0) return 1.0;
    return math.exp(-daysSinceReview / stability);
  }

  /// Calculates the time until retrievability drops to a threshold.
  ///
  /// Solves: threshold = e^(-t/S) for t
  /// t = -S * ln(threshold)
  double daysUntilThreshold({
    required double stability,
    required double threshold,
  }) {
    if (threshold <= 0 || threshold >= 1) {
      throw ArgumentError('Threshold must be between 0 and 1 (exclusive)');
    }
    return -stability * math.log(threshold);
  }

  /// Calculates the optimal next review date.
  ///
  /// [lastReviewDate] - When the item was last reviewed
  /// [stability] - Current stability in days
  /// [threshold] - Target retention level (defaults to [targetRetention])
  DateTime calculateNextReviewDate({
    required DateTime lastReviewDate,
    required double stability,
    double? threshold,
  }) {
    final target = threshold ?? targetRetention;
    final daysUntil = daysUntilThreshold(
      stability: stability,
      threshold: target,
    );

    return lastReviewDate.add(Duration(hours: (daysUntil * 24).round()));
  }

  /// Calculates new stability after a review.
  ///
  /// [currentStability] - Current stability in days
  /// [rating] - Review rating (1-4, where 4 is perfect recall)
  /// [difficulty] - Item difficulty (0.0 to 1.0)
  double calculateNewStability({
    required double currentStability,
    required int rating,
    double difficulty = 0.5,
  }) {
    // Validate rating
    if (rating < 1 || rating > 4) {
      throw ArgumentError('Rating must be between 1 and 4');
    }

    // Calculate rating multiplier
    double ratingMultiplier;
    switch (rating) {
      case 1: // Complete failure
        // Reset stability significantly
        return math.max(initialStability * 0.5, 0.5);
      case 2: // Hard recall
        ratingMultiplier = 1.2;
      case 3: // Good recall
        ratingMultiplier = stabilityGrowthFactor;
      case 4: // Easy recall
        ratingMultiplier = stabilityGrowthFactor * 1.3;
      default:
        ratingMultiplier = 1.0;
    }

    // Adjust for difficulty (harder items grow stability slower)
    final difficultyMultiplier = 1.0 - (difficultyWeight * difficulty);

    return currentStability * ratingMultiplier * difficultyMultiplier;
  }

  /// Calculates new difficulty based on review history.
  ///
  /// [currentDifficulty] - Current difficulty (0.0 to 1.0)
  /// [rating] - Review rating (1-4)
  double calculateNewDifficulty({
    required double currentDifficulty,
    required int rating,
  }) {
    // Difficulty adjustment based on rating
    // Lower ratings increase difficulty, higher ratings decrease it
    const adjustmentFactor = 0.1;

    final targetDifficulty = switch (rating) {
      1 => 1.0,
      2 => currentDifficulty + adjustmentFactor,
      3 => currentDifficulty - (adjustmentFactor * 0.5),
      4 => currentDifficulty - adjustmentFactor,
      _ => currentDifficulty,
    };

    // Clamp to valid range
    return targetDifficulty.clamp(0.0, 1.0);
  }

  /// Generates points for plotting the forgetting curve.
  ///
  /// [stability] - Memory stability in days
  /// [days] - Number of days to plot
  /// [pointsPerDay] - Number of points per day
  List<RetentionCurvePoint> generateForgettingCurve({
    required double stability,
    int days = 30,
    int pointsPerDay = 4,
  }) {
    final points = <RetentionCurvePoint>[];

    for (int i = 0; i <= days * pointsPerDay; i++) {
      final dayOffset = i / pointsPerDay;
      final retention = calculateRetrievability(
        daysSinceReview: dayOffset,
        stability: stability,
      );

      points.add(RetentionCurvePoint(
        day: dayOffset,
        retention: retention,
        isAboveThreshold: retention >= targetRetention,
      ));
    }

    return points;
  }

  /// Generates optimal review schedule for maximum retention.
  ///
  /// [initialStability] - Starting stability in days
  /// [reviews] - Number of reviews to schedule
  /// [targetRetention] - Target retention level for each review
  List<ScheduledReview> generateReviewSchedule({
    double? initialStability,
    int reviews = 10,
    double? targetRetention,
  }) {
    final stability = initialStability ?? this.initialStability;
    final threshold = targetRetention ?? this.targetRetention;

    final schedule = <ScheduledReview>[];
    double currentStability = stability;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < reviews; i++) {
      final daysUntil = daysUntilThreshold(
        stability: currentStability,
        threshold: threshold,
      );

      final reviewDate = currentDate.add(
        Duration(hours: (daysUntil * 24).round()),
      );

      schedule.add(ScheduledReview(
        reviewNumber: i + 1,
        scheduledDate: reviewDate,
        expectedRetention: threshold,
        stabilityAtReview: currentStability,
        intervalDays: daysUntil,
      ));

      // Assume successful review (rating 3) for scheduling
      currentStability = calculateNewStability(
        currentStability: currentStability,
        rating: 3,
      );
      currentDate = reviewDate;
    }

    return schedule;
  }

  /// Calculates bulk retention statistics for multiple items.
  ///
  /// [items] - List of retention data items
  RetentionSummary calculateBulkRetention(List<RetentionData> items) {
    if (items.isEmpty) {
      return const RetentionSummary(
        totalItems: 0,
        averageRetention: 0,
        itemsDue: 0,
        itemsCritical: 0,
        averageStability: 0,
      );
    }

    double totalRetention = 0;
    double totalStability = 0;
    int itemsDue = 0;
    int itemsCritical = 0;

    for (final item in items) {
      final retention = item.calculateRetrievability();
      totalRetention += retention;
      totalStability += item.stability;

      if (retention < targetRetention) {
        itemsDue++;
      }
      if (retention < 0.5) {
        itemsCritical++;
      }
    }

    return RetentionSummary(
      totalItems: items.length,
      averageRetention: totalRetention / items.length,
      itemsDue: itemsDue,
      itemsCritical: itemsCritical,
      averageStability: totalStability / items.length,
    );
  }

  /// Prioritizes items for review based on retention and stability.
  ///
  /// [items] - List of retention data items
  /// [maxItems] - Maximum number of items to return
  List<RetentionData> prioritizeForReview(
    List<RetentionData> items, {
    int maxItems = 20,
  }) {
    // Sort by retention (ascending) - lowest retention first
    final sorted = List<RetentionData>.from(items)
      ..sort((a, b) {
        final retentionA = a.calculateRetrievability();
        final retentionB = b.calculateRetrievability();
        return retentionA.compareTo(retentionB);
      });

    return sorted.take(maxItems).toList();
  }
}

/// A point on the forgetting curve.
class RetentionCurvePoint {
  /// Creates a new [RetentionCurvePoint].
  const RetentionCurvePoint({
    required this.day,
    required this.retention,
    required this.isAboveThreshold,
  });

  /// Days since last review.
  final double day;

  /// Retention level (0.0 to 1.0).
  final double retention;

  /// Whether retention is above the target threshold.
  final bool isAboveThreshold;

  /// Retention as percentage.
  double get percentage => retention * 100;
}

/// A scheduled review in the review schedule.
class ScheduledReview {
  /// Creates a new [ScheduledReview].
  const ScheduledReview({
    required this.reviewNumber,
    required this.scheduledDate,
    required this.expectedRetention,
    required this.stabilityAtReview,
    required this.intervalDays,
  });

  /// Review number (1-based).
  final int reviewNumber;

  /// Scheduled date for the review.
  final DateTime scheduledDate;

  /// Expected retention at review time.
  final double expectedRetention;

  /// Stability at the time of this review.
  final double stabilityAtReview;

  /// Interval in days since last review.
  final double intervalDays;
}

/// Summary statistics for bulk retention calculation.
class RetentionSummary {
  /// Creates a new [RetentionSummary].
  const RetentionSummary({
    required this.totalItems,
    required this.averageRetention,
    required this.itemsDue,
    required this.itemsCritical,
    required this.averageStability,
  });

  /// Total number of items.
  final int totalItems;

  /// Average retention across all items.
  final double averageRetention;

  /// Number of items due for review.
  final int itemsDue;

  /// Number of items with critically low retention.
  final int itemsCritical;

  /// Average stability across all items.
  final double averageStability;

  /// Percentage of items due.
  double get percentageDue {
    if (totalItems == 0) return 0;
    return (itemsDue / totalItems) * 100;
  }

  /// Percentage of items critical.
  double get percentageCritical {
    if (totalItems == 0) return 0;
    return (itemsCritical / totalItems) * 100;
  }

  /// Average retention as percentage.
  double get averageRetentionPercentage => averageRetention * 100;
}
