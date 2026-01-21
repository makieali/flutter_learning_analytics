import 'package:flutter_learning_analytics/src/calculators/mastery_calculator.dart';
import 'package:flutter_learning_analytics/src/models/mastery_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MasteryCalculator', () {
    const calculator = MasteryCalculator();

    group('calculateNewScore', () {
      test('returns correct score for first attempt', () {
        final score = calculator.calculateNewScore(
          currentScore: 0.0,
          wasCorrect: true,
          totalAttempts: 1,
        );
        expect(score, equals(1.0));
      });

      test('returns 0 for first wrong attempt', () {
        final score = calculator.calculateNewScore(
          currentScore: 0.0,
          wasCorrect: false,
          totalAttempts: 1,
        );
        expect(score, equals(0.0));
      });

      test('uses simple average for first few attempts', () {
        // After 2 attempts: 1 correct, 1 wrong = 0.5
        final score1 = calculator.calculateNewScore(
          currentScore: 1.0,
          wasCorrect: false,
          totalAttempts: 2,
        );
        expect(score1, equals(0.5));

        // After 3 attempts: 2 correct, 1 wrong = 0.667
        final score2 = calculator.calculateNewScore(
          currentScore: 0.5,
          wasCorrect: true,
          totalAttempts: 3,
        );
        expect(score2, closeTo(0.667, 0.01));
      });

      test('uses EMA after minimum attempts', () {
        // After minimum attempts, use EMA
        final score = calculator.calculateNewScore(
          currentScore: 0.6,
          wasCorrect: true,
          totalAttempts: 5,
        );
        // EMA: alpha * 1.0 + (1 - alpha) * 0.6 = 0.3 * 1.0 + 0.7 * 0.6 = 0.72
        expect(score, closeTo(0.72, 0.01));
      });

      test('decreases score for wrong answers', () {
        final score = calculator.calculateNewScore(
          currentScore: 0.8,
          wasCorrect: false,
          totalAttempts: 5,
        );
        // EMA: 0.3 * 0.0 + 0.7 * 0.8 = 0.56
        expect(score, closeTo(0.56, 0.01));
      });
    });

    group('calculateDecay', () {
      test('returns same score within decay period', () {
        final score = calculator.calculateDecay(
          currentScore: 0.8,
          lastAttemptDate: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(score, equals(0.8));
      });

      test('applies decay after decay period', () {
        final score = calculator.calculateDecay(
          currentScore: 0.8,
          lastAttemptDate: DateTime.now().subtract(const Duration(days: 14)),
        );
        // 7 days past decay period, score should be lower
        expect(score, lessThan(0.8));
      });

      test('does not go below minimum', () {
        final score = calculator.calculateDecay(
          currentScore: 0.8,
          lastAttemptDate: DateTime.now().subtract(const Duration(days: 365)),
        );
        expect(score, greaterThanOrEqualTo(0.1));
      });
    });

    group('calculateFromBatch', () {
      test('calculates score from batch of attempts', () {
        final score = calculator.calculateFromBatch([
          true,
          true,
          false,
          true,
          true,
        ]);
        // 4 correct out of 5 = 0.8 (with weighting newer is higher)
        expect(score, greaterThan(0.7));
        expect(score, lessThan(0.9));
      });

      test('returns 0 for empty batch', () {
        final score = calculator.calculateFromBatch([]);
        expect(score, equals(0.0));
      });

      test('returns 1.0 for all correct', () {
        final score = calculator.calculateFromBatch([
          true,
          true,
          true,
          true,
          true,
        ]);
        expect(score, equals(1.0));
      });

      test('throws for mismatched weights', () {
        expect(
          () => calculator.calculateFromBatch(
            [true, false, true],
            weights: [1.0, 2.0],
          ),
          throwsArgumentError,
        );
      });
    });

    group('estimateAttemptsToTarget', () {
      test('returns 0 when already at target', () {
        final attempts = calculator.estimateAttemptsToTarget(
          currentScore: 0.9,
          targetScore: 0.8,
        );
        expect(attempts, equals(0));
      });

      test('estimates attempts needed', () {
        final attempts = calculator.estimateAttemptsToTarget(
          currentScore: 0.5,
          targetScore: 0.8,
        );
        expect(attempts, greaterThan(0));
        expect(attempts, lessThan(20));
      });

      test('returns -1 for impossible target', () {
        final attempts = calculator.estimateAttemptsToTarget(
          currentScore: 0.5,
          targetScore: 1.5,
        );
        expect(attempts, equals(-1));
      });
    });

    group('getLevelForScore', () {
      test('returns correct mastery level', () {
        expect(calculator.getLevelForScore(0.0), equals(MasteryLevel.novice));
        expect(calculator.getLevelForScore(0.25), equals(MasteryLevel.beginner));
        expect(
          calculator.getLevelForScore(0.5),
          equals(MasteryLevel.intermediate),
        );
        expect(calculator.getLevelForScore(0.7), equals(MasteryLevel.advanced));
        expect(calculator.getLevelForScore(0.9), equals(MasteryLevel.expert));
      });
    });
  });

  group('MasteryCalculatorExtension', () {
    test('converts list of bools to mastery score', () {
      final score = [true, true, false, true].toMasteryScore();
      expect(score, greaterThan(0.6));
      expect(score, lessThan(0.9));
    });
  });
}
