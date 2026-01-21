import '../models/mastery_level.dart';

/// Calculator for computing mastery levels using exponential moving average.
///
/// The mastery score is calculated using EMA (Exponential Moving Average)
/// to give more weight to recent performance while still considering history.
class MasteryCalculator {
  /// Creates a new [MasteryCalculator].
  const MasteryCalculator({
    this.alpha = 0.3,
    this.minAttempts = 3,
    this.decayFactor = 0.95,
    this.decayPeriodDays = 7,
  });

  /// Smoothing factor for EMA (0 to 1).
  /// Higher values give more weight to recent performance.
  final double alpha;

  /// Minimum attempts before mastery is calculated.
  final int minAttempts;

  /// Decay factor applied when no activity occurs.
  final double decayFactor;

  /// Days before decay starts being applied.
  final int decayPeriodDays;

  /// Calculates the new mastery score after an attempt.
  ///
  /// [currentScore] - Current mastery score (0.0 to 1.0)
  /// [wasCorrect] - Whether the attempt was correct
  /// [totalAttempts] - Total number of attempts including this one
  /// [timeTaken] - Optional time taken (affects score for timed assessments)
  /// [expectedTime] - Optional expected time (for time-based adjustments)
  double calculateNewScore({
    required double currentScore,
    required bool wasCorrect,
    required int totalAttempts,
    Duration? timeTaken,
    Duration? expectedTime,
  }) {
    // Use simple average for first few attempts
    if (totalAttempts <= minAttempts) {
      return _calculateSimpleAverage(currentScore, wasCorrect, totalAttempts);
    }

    // Calculate the new observation value
    double observation = wasCorrect ? 1.0 : 0.0;

    // Adjust for time if both are provided
    if (timeTaken != null && expectedTime != null && wasCorrect) {
      observation = _adjustForTime(timeTaken, expectedTime);
    }

    // Apply EMA formula: new_score = alpha * observation + (1 - alpha) * current_score
    return alpha * observation + (1 - alpha) * currentScore;
  }

  /// Calculates score decay when user hasn't practiced.
  ///
  /// [currentScore] - Current mastery score
  /// [lastAttemptDate] - When the last attempt was made
  /// [currentDate] - Current date (defaults to now)
  double calculateDecay({
    required double currentScore,
    required DateTime lastAttemptDate,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final daysSinceLastAttempt =
        now.difference(lastAttemptDate).inDays - decayPeriodDays;

    if (daysSinceLastAttempt <= 0) {
      return currentScore;
    }

    // Apply decay: score * decayFactor^days
    final decayedScore =
        currentScore * _pow(decayFactor, daysSinceLastAttempt);

    // Don't go below 0.1 (preserve some memory)
    return decayedScore.clamp(0.1, 1.0);
  }

  /// Calculates mastery score from a batch of attempts.
  ///
  /// [attempts] - List of attempt results (true = correct, false = incorrect)
  /// [weights] - Optional weights for each attempt (newer = higher weight)
  double calculateFromBatch(
    List<bool> attempts, {
    List<double>? weights,
  }) {
    if (attempts.isEmpty) return 0.0;

    if (weights != null && weights.length != attempts.length) {
      throw ArgumentError('Weights length must match attempts length');
    }

    if (weights == null) {
      // Generate exponential weights (newer attempts have higher weight)
      weights = List.generate(
        attempts.length,
        (i) => _pow(1.5, i),
      );
    }

    double weightedSum = 0;
    double totalWeight = 0;

    for (int i = 0; i < attempts.length; i++) {
      final value = attempts[i] ? 1.0 : 0.0;
      weightedSum += value * weights[i];
      totalWeight += weights[i];
    }

    return weightedSum / totalWeight;
  }

  /// Estimates how many correct answers are needed to reach a target level.
  ///
  /// [currentScore] - Current mastery score
  /// [targetScore] - Target mastery score
  /// Returns the estimated number of consecutive correct answers needed.
  int estimateAttemptsToTarget({
    required double currentScore,
    required double targetScore,
  }) {
    if (currentScore >= targetScore) return 0;
    if (targetScore > 1.0) return -1; // Impossible

    double score = currentScore;
    int attempts = 0;
    const maxIterations = 100;

    while (score < targetScore && attempts < maxIterations) {
      score = alpha * 1.0 + (1 - alpha) * score;
      attempts++;
    }

    return attempts;
  }

  /// Gets the mastery level for a given score.
  MasteryLevel getLevelForScore(double score) {
    return MasteryLevel.fromScore(score);
  }

  /// Calculates progress toward the next mastery level.
  ///
  /// Returns a value between 0.0 and 1.0 representing progress within
  /// the current level toward the next level.
  double calculateProgressToNextLevel(double score) {
    final currentLevel = MasteryLevel.fromScore(score);
    return currentLevel.progressInLevel(score);
  }

  double _calculateSimpleAverage(
    double currentScore,
    bool wasCorrect,
    int totalAttempts,
  ) {
    if (totalAttempts == 1) {
      return wasCorrect ? 1.0 : 0.0;
    }

    final totalCorrect =
        (currentScore * (totalAttempts - 1)) + (wasCorrect ? 1.0 : 0.0);
    return totalCorrect / totalAttempts;
  }

  double _adjustForTime(Duration timeTaken, Duration expectedTime) {
    final ratio = timeTaken.inMilliseconds / expectedTime.inMilliseconds;

    if (ratio <= 0.5) {
      // Very fast - full marks
      return 1.0;
    } else if (ratio <= 1.0) {
      // Within expected time - full marks
      return 1.0;
    } else if (ratio <= 2.0) {
      // Slightly slow - partial credit
      return 1.0 - ((ratio - 1.0) * 0.3);
    } else {
      // Very slow - minimum credit
      return 0.4;
    }
  }

  double _pow(double base, num exponent) {
    if (exponent == 0) return 1.0;
    if (exponent == 1) return base;

    double result = 1.0;
    final intExp = exponent.toInt();
    for (int i = 0; i < intExp; i++) {
      result *= base;
    }
    return result;
  }
}

/// Extension methods for mastery calculations.
extension MasteryCalculatorExtension on List<bool> {
  /// Calculates mastery score from a list of attempt results.
  double toMasteryScore([MasteryCalculator? calculator]) {
    final calc = calculator ?? const MasteryCalculator();
    return calc.calculateFromBatch(this);
  }
}
