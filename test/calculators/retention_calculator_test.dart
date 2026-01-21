import 'package:flutter_learning_analytics/src/calculators/retention_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetentionCalculator', () {
    const calculator = RetentionCalculator();

    group('calculateRetrievability', () {
      test('returns 1.0 immediately after review', () {
        final retention = calculator.calculateRetrievability(
          daysSinceReview: 0,
          stability: 7.0,
        );
        expect(retention, equals(1.0));
      });

      test('decays over time', () {
        final retentionDay1 = calculator.calculateRetrievability(
          daysSinceReview: 1,
          stability: 7.0,
        );
        final retentionDay7 = calculator.calculateRetrievability(
          daysSinceReview: 7,
          stability: 7.0,
        );

        expect(retentionDay1, lessThan(1.0));
        expect(retentionDay7, lessThan(retentionDay1));
      });

      test('at stability days, retention is about 0.368 (1/e)', () {
        final retention = calculator.calculateRetrievability(
          daysSinceReview: 7,
          stability: 7.0,
        );
        // R = e^(-7/7) = e^(-1) ≈ 0.368
        expect(retention, closeTo(0.368, 0.01));
      });

      test('higher stability means slower decay', () {
        final lowStability = calculator.calculateRetrievability(
          daysSinceReview: 7,
          stability: 3.0,
        );
        final highStability = calculator.calculateRetrievability(
          daysSinceReview: 7,
          stability: 14.0,
        );

        expect(highStability, greaterThan(lowStability));
      });
    });

    group('daysUntilThreshold', () {
      test('calculates days until threshold correctly', () {
        final days = calculator.daysUntilThreshold(
          stability: 7.0,
          threshold: 0.9,
        );
        // t = -7 * ln(0.9) ≈ 0.74
        expect(days, closeTo(0.74, 0.1));
      });

      test('throws for invalid threshold', () {
        expect(
          () => calculator.daysUntilThreshold(stability: 7.0, threshold: 0.0),
          throwsArgumentError,
        );
        expect(
          () => calculator.daysUntilThreshold(stability: 7.0, threshold: 1.0),
          throwsArgumentError,
        );
      });
    });

    group('calculateNextReviewDate', () {
      test('returns future date', () {
        final now = DateTime.now();
        final nextReview = calculator.calculateNextReviewDate(
          lastReviewDate: now,
          stability: 7.0,
          threshold: 0.9,
        );

        expect(nextReview.isAfter(now), isTrue);
      });
    });

    group('calculateNewStability', () {
      test('resets stability for rating 1', () {
        final newStability = calculator.calculateNewStability(
          currentStability: 14.0,
          rating: 1,
        );

        expect(newStability, lessThan(14.0));
        expect(newStability, greaterThan(0));
      });

      test('increases stability for good recall', () {
        final newStability = calculator.calculateNewStability(
          currentStability: 7.0,
          rating: 3,
        );

        expect(newStability, greaterThan(7.0));
      });

      test('increases stability more for easy recall', () {
        final stabilityGood = calculator.calculateNewStability(
          currentStability: 7.0,
          rating: 3,
        );
        final stabilityEasy = calculator.calculateNewStability(
          currentStability: 7.0,
          rating: 4,
        );

        expect(stabilityEasy, greaterThan(stabilityGood));
      });

      test('throws for invalid rating', () {
        expect(
          () => calculator.calculateNewStability(
            currentStability: 7.0,
            rating: 0,
          ),
          throwsArgumentError,
        );
        expect(
          () => calculator.calculateNewStability(
            currentStability: 7.0,
            rating: 5,
          ),
          throwsArgumentError,
        );
      });
    });

    group('calculateNewDifficulty', () {
      test('increases difficulty for low ratings', () {
        final newDifficulty = calculator.calculateNewDifficulty(
          currentDifficulty: 0.5,
          rating: 1,
        );

        expect(newDifficulty, greaterThan(0.5));
      });

      test('decreases difficulty for high ratings', () {
        final newDifficulty = calculator.calculateNewDifficulty(
          currentDifficulty: 0.5,
          rating: 4,
        );

        expect(newDifficulty, lessThan(0.5));
      });

      test('clamps difficulty to valid range', () {
        final highDifficulty = calculator.calculateNewDifficulty(
          currentDifficulty: 0.95,
          rating: 1,
        );
        final lowDifficulty = calculator.calculateNewDifficulty(
          currentDifficulty: 0.05,
          rating: 4,
        );

        expect(highDifficulty, lessThanOrEqualTo(1.0));
        expect(lowDifficulty, greaterThanOrEqualTo(0.0));
      });
    });

    group('generateForgettingCurve', () {
      test('generates correct number of points', () {
        final curve = calculator.generateForgettingCurve(
          stability: 7.0,
          days: 10,
          pointsPerDay: 2,
        );

        // 10 days * 2 points + 1 for day 0
        expect(curve.length, equals(21));
      });

      test('first point has 100% retention', () {
        final curve = calculator.generateForgettingCurve(
          stability: 7.0,
          days: 10,
        );

        expect(curve.first.retention, equals(1.0));
        expect(curve.first.day, equals(0.0));
      });

      test('retention decreases over time', () {
        final curve = calculator.generateForgettingCurve(
          stability: 7.0,
          days: 10,
        );

        for (int i = 1; i < curve.length; i++) {
          expect(
            curve[i].retention,
            lessThan(curve[i - 1].retention),
          );
        }
      });
    });

    group('generateReviewSchedule', () {
      test('generates correct number of reviews', () {
        final schedule = calculator.generateReviewSchedule(
          initialStability: 1.0,
          reviews: 5,
        );

        expect(schedule.length, equals(5));
      });

      test('intervals increase over time', () {
        final schedule = calculator.generateReviewSchedule(
          initialStability: 1.0,
          reviews: 5,
        );

        for (int i = 1; i < schedule.length; i++) {
          expect(
            schedule[i].intervalDays,
            greaterThan(schedule[i - 1].intervalDays),
          );
        }
      });
    });
  });

  group('RetentionCurvePoint', () {
    test('calculates percentage correctly', () {
      const point = RetentionCurvePoint(
        day: 5,
        retention: 0.75,
        isAboveThreshold: true,
      );

      expect(point.percentage, equals(75.0));
    });
  });

  group('RetentionSummary', () {
    test('calculates percentages correctly', () {
      const summary = RetentionSummary(
        totalItems: 100,
        averageRetention: 0.85,
        itemsDue: 20,
        itemsCritical: 5,
        averageStability: 14.0,
      );

      expect(summary.percentageDue, equals(20.0));
      expect(summary.percentageCritical, equals(5.0));
      expect(summary.averageRetentionPercentage, equals(85.0));
    });

    test('handles zero total items', () {
      const summary = RetentionSummary(
        totalItems: 0,
        averageRetention: 0,
        itemsDue: 0,
        itemsCritical: 0,
        averageStability: 0,
      );

      expect(summary.percentageDue, equals(0));
      expect(summary.percentageCritical, equals(0));
    });
  });
}
