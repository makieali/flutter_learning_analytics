import 'package:flutter_learning_analytics/src/models/learning_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearningSession', () {
    late LearningSession session;

    setUp(() {
      session = LearningSession(
        id: 'test-session-1',
        startTime: DateTime(2024, 1, 1, 10, 0),
        endTime: DateTime(2024, 1, 1, 11, 0),
        questionsAttempted: 20,
        correctAnswers: 15,
        wrongAnswers: 3,
        skippedQuestions: 2,
      );
    });

    test('calculates duration correctly', () {
      expect(session.duration, equals(const Duration(hours: 1)));
    });

    test('calculates accuracy correctly', () {
      // 15 correct out of 20 = 0.75
      expect(session.accuracy, equals(0.75));
    });

    test('calculates completion rate correctly', () {
      // 15 + 3 = 18 answered out of 20 = 0.9
      expect(session.completionRate, equals(0.9));
    });

    test('calculates skip rate correctly', () {
      // 2 skipped out of 20 = 0.1
      expect(session.skipRate, equals(0.1));
    });

    test('handles zero questions gracefully', () {
      final emptySession = LearningSession(
        id: 'empty',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        questionsAttempted: 0,
        correctAnswers: 0,
        wrongAnswers: 0,
        skippedQuestions: 0,
      );

      expect(emptySession.accuracy, equals(0.0));
      expect(emptySession.completionRate, equals(0.0));
      expect(emptySession.skipRate, equals(0.0));
    });

    group('copyWith', () {
      test('creates copy with modified fields', () {
        final modified = session.copyWith(
          correctAnswers: 18,
          wrongAnswers: 2,
        );

        expect(modified.id, equals(session.id));
        expect(modified.correctAnswers, equals(18));
        expect(modified.wrongAnswers, equals(2));
        expect(modified.questionsAttempted, equals(session.questionsAttempted));
      });
    });

    group('JSON serialization', () {
      test('converts to JSON correctly', () {
        final json = session.toJson();

        expect(json['id'], equals('test-session-1'));
        expect(json['questionsAttempted'], equals(20));
        expect(json['correctAnswers'], equals(15));
      });

      test('creates from JSON correctly', () {
        final json = session.toJson();
        final restored = LearningSession.fromJson(json);

        expect(restored.id, equals(session.id));
        expect(restored.questionsAttempted, equals(session.questionsAttempted));
        expect(restored.correctAnswers, equals(session.correctAnswers));
      });

      test('handles optional fields in JSON', () {
        final json = <String, dynamic>{
          'id': 'test',
          'startTime': DateTime.now().toIso8601String(),
          'endTime': DateTime.now().toIso8601String(),
          'questionsAttempted': 10,
          'correctAnswers': 8,
          'wrongAnswers': 2,
          'skippedQuestions': 0,
        };

        final session = LearningSession.fromJson(json);

        expect(session.subjectId, isNull);
        expect(session.topicId, isNull);
        expect(session.xpEarned, equals(0));
      });
    });

    group('equality', () {
      test('sessions with same id are equal', () {
        final session1 = LearningSession(
          id: 'same-id',
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          questionsAttempted: 10,
          correctAnswers: 5,
          wrongAnswers: 5,
          skippedQuestions: 0,
        );
        final session2 = LearningSession(
          id: 'same-id',
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1)),
          questionsAttempted: 20,
          correctAnswers: 15,
          wrongAnswers: 5,
          skippedQuestions: 0,
        );

        expect(session1, equals(session2));
        expect(session1.hashCode, equals(session2.hashCode));
      });

      test('sessions with different ids are not equal', () {
        final session1 = LearningSession(
          id: 'id-1',
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          questionsAttempted: 10,
          correctAnswers: 5,
          wrongAnswers: 5,
          skippedQuestions: 0,
        );
        final session2 = LearningSession(
          id: 'id-2',
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          questionsAttempted: 10,
          correctAnswers: 5,
          wrongAnswers: 5,
          skippedQuestions: 0,
        );

        expect(session1, isNot(equals(session2)));
      });
    });

    test('toString returns readable format', () {
      final str = session.toString();
      expect(str, contains('test-session-1'));
      expect(str, contains('75.0%'));
    });
  });
}
