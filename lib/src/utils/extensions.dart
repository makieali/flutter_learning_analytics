import '../models/learning_session.dart';
import '../models/mastery_level.dart';
import '../models/quiz_analytics.dart';

/// Extension methods for learning sessions.
extension LearningSessionListExtension on List<LearningSession> {
  /// Gets total questions answered.
  int get totalQuestions => fold(0, (sum, s) => sum + s.questionsAttempted);

  /// Gets total correct answers.
  int get totalCorrect => fold(0, (sum, s) => sum + s.correctAnswers);

  /// Gets total wrong answers.
  int get totalWrong => fold(0, (sum, s) => sum + s.wrongAnswers);

  /// Gets total skipped questions.
  int get totalSkipped => fold(0, (sum, s) => sum + s.skippedQuestions);

  /// Gets overall accuracy.
  double get overallAccuracy {
    final total = totalQuestions;
    if (total == 0) return 0.0;
    return totalCorrect / total;
  }

  /// Gets total time spent.
  Duration get totalDuration {
    return fold(Duration.zero, (sum, s) => sum + s.duration);
  }

  /// Gets average session duration.
  Duration get averageDuration {
    if (isEmpty) return Duration.zero;
    return Duration(milliseconds: totalDuration.inMilliseconds ~/ length);
  }

  /// Gets sessions from the last N days.
  List<LearningSession> fromLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return where((s) => s.startTime.isAfter(cutoff)).toList();
  }

  /// Gets sessions for a specific topic.
  List<LearningSession> forTopic(String topicId) {
    return where((s) => s.topicId == topicId).toList();
  }

  /// Gets the most recent session.
  LearningSession? get mostRecent {
    if (isEmpty) return null;
    return reduce((a, b) => a.startTime.isAfter(b.startTime) ? a : b);
  }

  /// Groups sessions by date.
  Map<DateTime, List<LearningSession>> groupByDate() {
    final grouped = <DateTime, List<LearningSession>>{};
    for (final session in this) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      grouped.putIfAbsent(date, () => []).add(session);
    }
    return grouped;
  }
}

/// Extension methods for quiz analytics.
extension QuizAnalyticsListExtension on List<QuizAnalytics> {
  /// Gets overall accuracy across all quizzes.
  double get overallAccuracy {
    if (isEmpty) return 0.0;
    final total = fold(0, (sum, q) => sum + q.totalQuestions);
    final correct = fold(0, (sum, q) => sum + q.correctAnswers);
    if (total == 0) return 0.0;
    return correct / total;
  }

  /// Gets average score.
  double get averageScore {
    if (isEmpty) return 0.0;
    return fold(0.0, (sum, q) => sum + q.percentageScore) / length;
  }

  /// Gets best quiz.
  QuizAnalytics? get best {
    if (isEmpty) return null;
    return reduce((a, b) => a.accuracy > b.accuracy ? a : b);
  }

  /// Gets worst quiz.
  QuizAnalytics? get worst {
    if (isEmpty) return null;
    return reduce((a, b) => a.accuracy < b.accuracy ? a : b);
  }

  /// Gets quizzes from the last N days.
  List<QuizAnalytics> fromLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return where((q) => q.completedAt.isAfter(cutoff)).toList();
  }

  /// Gets topic performance breakdown.
  Map<String, double> get topicPerformance {
    final topicScores = <String, List<double>>{};

    for (final quiz in this) {
      for (final entry in quiz.topicBreakdown.entries) {
        topicScores.putIfAbsent(entry.key, () => []).add(entry.value);
      }
    }

    return topicScores.map(
      (topic, scores) => MapEntry(
        topic,
        scores.fold(0.0, (sum, s) => sum + s) / scores.length,
      ),
    );
  }
}

/// Extension methods for mastery progress.
extension MasteryProgressListExtension on List<MasteryProgress> {
  /// Gets topics at a specific level.
  List<MasteryProgress> atLevel(MasteryLevel level) {
    return where((p) => p.level == level).toList();
  }

  /// Gets topics needing attention (novice or beginner).
  List<MasteryProgress> get needingAttention {
    return where(
      (p) => p.level == MasteryLevel.novice || p.level == MasteryLevel.beginner,
    ).toList()
      ..sort((a, b) => a.currentScore.compareTo(b.currentScore));
  }

  /// Gets mastered topics (advanced or expert).
  List<MasteryProgress> get mastered {
    return where(
      (p) => p.level == MasteryLevel.advanced || p.level == MasteryLevel.expert,
    ).toList()
      ..sort((a, b) => b.currentScore.compareTo(a.currentScore));
  }

  /// Gets average mastery score.
  double get averageMastery {
    if (isEmpty) return 0.0;
    return fold(0.0, (sum, p) => sum + p.currentScore) / length;
  }

  /// Gets mastery distribution.
  Map<MasteryLevel, int> get distribution {
    final dist = <MasteryLevel, int>{};
    for (final level in MasteryLevel.values) {
      dist[level] = 0;
    }
    for (final progress in this) {
      dist[progress.level] = (dist[progress.level] ?? 0) + 1;
    }
    return dist;
  }
}

/// Extension for DateTime to check if same day.
extension DateTimeComparison on DateTime {
  /// Checks if this date is the same day as another.
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Gets the start of the day.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Gets the end of the day.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Gets the start of the week (Monday).
  DateTime get startOfWeek {
    final daysToSubtract = weekday - 1;
    return DateTime(year, month, day - daysToSubtract);
  }

  /// Gets the start of the month.
  DateTime get startOfMonth => DateTime(year, month, 1);
}
