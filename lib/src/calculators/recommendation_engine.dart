import '../models/learning_session.dart';
import '../models/mastery_level.dart';
import '../models/quiz_analytics.dart';
import '../models/recommendation.dart';
import '../models/retention_data.dart';
import '../models/streak_data.dart';

/// Engine for generating personalized learning recommendations.
///
/// Analyzes learning data patterns and generates actionable recommendations
/// to help users improve their learning effectiveness.
class RecommendationEngine {
  /// Creates a new [RecommendationEngine].
  const RecommendationEngine({
    this.config = const RecommendationConfig(),
  });

  /// Configuration for the recommendation engine.
  final RecommendationConfig config;

  /// Generates recommendations based on all available data.
  List<Recommendation> analyze({
    List<LearningSession> sessions = const [],
    List<QuizAnalytics> quizzes = const [],
    List<MasteryProgress> masteryProgress = const [],
    List<RetentionData> retentionItems = const [],
    StreakData? streakData,
  }) {
    final recommendations = <Recommendation>[];

    // Check minimum data requirements
    if (sessions.length < config.minSessionsForAnalysis &&
        quizzes.length < config.minSessionsForAnalysis) {
      recommendations.add(_createNotEnoughDataRecommendation());
      return recommendations;
    }

    // Analyze different aspects
    if (config.isTypeEnabled(RecommendationType.timeManagement)) {
      recommendations.addAll(_analyzeTimeManagement(sessions, quizzes));
    }

    if (config.isTypeEnabled(RecommendationType.accuracy)) {
      recommendations.addAll(_analyzeAccuracy(sessions, quizzes));
    }

    if (config.isTypeEnabled(RecommendationType.skipPattern)) {
      recommendations.addAll(_analyzeSkipPatterns(sessions, quizzes));
    }

    if (config.isTypeEnabled(RecommendationType.subjectFocus)) {
      recommendations.addAll(_analyzeSubjectPerformance(
        masteryProgress,
        quizzes,
      ));
    }

    if (config.isTypeEnabled(RecommendationType.streak) && streakData != null) {
      recommendations.addAll(_analyzeStreak(streakData));
    }

    if (config.isTypeEnabled(RecommendationType.retention)) {
      recommendations.addAll(_analyzeRetention(retentionItems));
    }

    if (config.isTypeEnabled(RecommendationType.encouragement)) {
      recommendations.addAll(_generateEncouragement(sessions, streakData));
    }

    // Sort by priority and limit
    recommendations.sort(
      (a, b) => b.priority.value.compareTo(a.priority.value),
    );

    return recommendations.take(config.maxRecommendations).toList();
  }

  /// Analyzes quiz data specifically.
  List<Recommendation> analyzeQuiz(QuizAnalytics quiz) {
    final recommendations = <Recommendation>[];

    // Time analysis
    if (quiz.averageTimePerQuestion != null &&
        quiz.averageTimePerQuestion! > config.timeThreshold) {
      recommendations.add(_createTimeRecommendation(
        averageTime: quiz.averageTimePerQuestion!,
        threshold: config.timeThreshold,
      ));
    }

    // Accuracy analysis
    if (quiz.accuracy < config.accuracyThreshold) {
      recommendations.add(_createAccuracyRecommendation(
        accuracy: quiz.accuracy,
        threshold: config.accuracyThreshold,
      ));
    }

    // Skip pattern analysis
    if (quiz.skipRate > config.skipThreshold) {
      recommendations.add(_createSkipRecommendation(
        skipRate: quiz.skipRate,
        threshold: config.skipThreshold,
      ));
    }

    // Topic-specific recommendations
    for (final entry in quiz.topicBreakdown.entries) {
      if (entry.value < config.accuracyThreshold) {
        recommendations.add(_createTopicRecommendation(
          topic: entry.key,
          accuracy: entry.value,
        ));
      }
    }

    return recommendations;
  }

  List<Recommendation> _analyzeTimeManagement(
    List<LearningSession> sessions,
    List<QuizAnalytics> quizzes,
  ) {
    final recommendations = <Recommendation>[];

    // Analyze quiz time patterns
    final slowQuizzes = quizzes.where((q) {
      final avgTime = q.averageTimePerQuestion;
      return avgTime != null && avgTime > config.timeThreshold;
    }).toList();

    if (slowQuizzes.length >= 2) {
      final avgTime = _calculateAverageQuestionTime(slowQuizzes);
      recommendations.add(_createTimeRecommendation(
        averageTime: avgTime,
        threshold: config.timeThreshold,
      ));
    }

    return recommendations;
  }

  List<Recommendation> _analyzeAccuracy(
    List<LearningSession> sessions,
    List<QuizAnalytics> quizzes,
  ) {
    final recommendations = <Recommendation>[];

    // Calculate overall accuracy trend
    if (sessions.length >= 3) {
      final recentSessions = sessions.take(5).toList();
      final avgAccuracy = recentSessions.fold<double>(
            0,
            (sum, s) => sum + s.accuracy,
          ) /
          recentSessions.length;

      if (avgAccuracy < config.accuracyThreshold) {
        recommendations.add(_createAccuracyRecommendation(
          accuracy: avgAccuracy,
          threshold: config.accuracyThreshold,
        ));
      }
    }

    return recommendations;
  }

  List<Recommendation> _analyzeSkipPatterns(
    List<LearningSession> sessions,
    List<QuizAnalytics> quizzes,
  ) {
    final recommendations = <Recommendation>[];

    // Check for consistent skipping behavior
    final highSkipSessions = sessions.where(
      (s) => s.skipRate > config.skipThreshold,
    );

    if (highSkipSessions.length >= 3) {
      final avgSkipRate =
          highSkipSessions.fold<double>(0, (sum, s) => sum + s.skipRate) /
              highSkipSessions.length;

      recommendations.add(_createSkipRecommendation(
        skipRate: avgSkipRate,
        threshold: config.skipThreshold,
      ));
    }

    return recommendations;
  }

  List<Recommendation> _analyzeSubjectPerformance(
    List<MasteryProgress> masteryProgress,
    List<QuizAnalytics> quizzes,
  ) {
    final recommendations = <Recommendation>[];

    // Find topics needing attention
    final weakTopics = masteryProgress.where(
      (p) =>
          p.level == MasteryLevel.novice || p.level == MasteryLevel.beginner,
    );

    for (final topic in weakTopics.take(2)) {
      recommendations.add(_createTopicRecommendation(
        topic: topic.topicName,
        accuracy: topic.accuracy,
        topicId: topic.topicId,
      ));
    }

    return recommendations;
  }

  List<Recommendation> _analyzeStreak(StreakData streakData) {
    final recommendations = <Recommendation>[];

    // Streak at risk
    if (!streakData.hasActivityToday && streakData.currentStreak > 0) {
      recommendations.add(Recommendation(
        id: 'streak_risk_${DateTime.now().millisecondsSinceEpoch}',
        type: RecommendationType.streak,
        title: 'Keep Your Streak Alive!',
        description:
            'You have a ${streakData.currentStreak}-day streak. '
            'Complete a quick study session today to maintain it.',
        priority: streakData.currentStreak >= 7
            ? RecommendationPriority.high
            : RecommendationPriority.medium,
        actionLabel: 'Start Session',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ));
    }

    // Approaching personal best
    if (streakData.currentStreak >= streakData.longestStreak - 1 &&
        streakData.currentStreak > 5) {
      recommendations.add(Recommendation(
        id: 'streak_record_${DateTime.now().millisecondsSinceEpoch}',
        type: RecommendationType.streak,
        title: 'You\'re Close to a Record!',
        description:
            'Your current streak of ${streakData.currentStreak} days is '
            '${streakData.currentStreak == streakData.longestStreak ? "matching" : "close to"} '
            'your personal best of ${streakData.longestStreak} days!',
        priority: RecommendationPriority.medium,
        createdAt: DateTime.now(),
      ));
    }

    return recommendations;
  }

  List<Recommendation> _analyzeRetention(List<RetentionData> items) {
    final recommendations = <Recommendation>[];

    // Count items due for review
    final itemsDue = items.where((item) {
      return item.calculateRetrievability() < config.retentionThreshold;
    }).toList();

    if (itemsDue.length >= 5) {
      recommendations.add(Recommendation(
        id: 'retention_due_${DateTime.now().millisecondsSinceEpoch}',
        type: RecommendationType.retention,
        title: '${itemsDue.length} Items Need Review',
        description:
            'You have ${itemsDue.length} items with declining retention. '
            'Review them soon to maintain your knowledge.',
        priority: itemsDue.length >= 20
            ? RecommendationPriority.high
            : RecommendationPriority.medium,
        actionLabel: 'Start Review',
        createdAt: DateTime.now(),
        relatedData: {'dueCount': itemsDue.length},
      ));
    }

    // Critical items (very low retention)
    final criticalItems = items.where((item) {
      return item.calculateRetrievability() < 0.5;
    }).toList();

    if (criticalItems.isNotEmpty) {
      recommendations.add(Recommendation(
        id: 'retention_critical_${DateTime.now().millisecondsSinceEpoch}',
        type: RecommendationType.reviewDifficult,
        title: 'Critical: ${criticalItems.length} Items at Risk',
        description:
            '${criticalItems.length} items have very low retention and '
            'may be forgotten soon. Prioritize reviewing these.',
        priority: RecommendationPriority.critical,
        actionLabel: 'Review Now',
        createdAt: DateTime.now(),
        relatedData: {'criticalCount': criticalItems.length},
      ));
    }

    return recommendations;
  }

  List<Recommendation> _generateEncouragement(
    List<LearningSession> sessions,
    StreakData? streakData,
  ) {
    final recommendations = <Recommendation>[];

    // Recent improvement
    if (sessions.length >= 5) {
      final recent = sessions.take(3).toList();
      final older = sessions.skip(3).take(3).toList();

      if (older.isNotEmpty) {
        final recentAvg =
            recent.fold<double>(0, (sum, s) => sum + s.accuracy) /
                recent.length;
        final olderAvg =
            older.fold<double>(0, (sum, s) => sum + s.accuracy) / older.length;

        if (recentAvg > olderAvg + 0.1) {
          final improvement = ((recentAvg - olderAvg) * 100).round();
          recommendations.add(Recommendation(
            id: 'encouragement_improvement_${DateTime.now().millisecondsSinceEpoch}',
            type: RecommendationType.encouragement,
            title: 'Great Progress!',
            description:
                'Your accuracy has improved by $improvement% recently. '
                'Keep up the excellent work!',
            priority: RecommendationPriority.low,
            createdAt: DateTime.now(),
          ));
        }
      }
    }

    // Milestone streak
    if (streakData != null) {
      final milestones = [7, 14, 30, 60, 100, 365];
      for (final milestone in milestones) {
        if (streakData.currentStreak == milestone) {
          recommendations.add(Recommendation(
            id: 'encouragement_milestone_${DateTime.now().millisecondsSinceEpoch}',
            type: RecommendationType.encouragement,
            title: '$milestone Day Streak!',
            description:
                'Congratulations! You\'ve maintained a $milestone-day '
                'learning streak. This is a fantastic achievement!',
            priority: RecommendationPriority.low,
            createdAt: DateTime.now(),
          ));
          break;
        }
      }
    }

    return recommendations;
  }

  Recommendation _createNotEnoughDataRecommendation() {
    return Recommendation(
      id: 'not_enough_data_${DateTime.now().millisecondsSinceEpoch}',
      type: RecommendationType.encouragement,
      title: 'Keep Learning!',
      description:
          'Complete a few more sessions and we\'ll have personalized '
          'recommendations for you.',
      priority: RecommendationPriority.low,
      createdAt: DateTime.now(),
    );
  }

  Recommendation _createTimeRecommendation({
    required Duration averageTime,
    required Duration threshold,
  }) {
    return Recommendation(
      id: 'time_${DateTime.now().millisecondsSinceEpoch}',
      type: RecommendationType.timeManagement,
      title: 'Improve Your Pace',
      description:
          'Your average response time (${averageTime.inSeconds}s) is above '
          'the recommended ${threshold.inSeconds}s. Try to read questions '
          'more quickly and trust your first instinct.',
      priority: RecommendationPriority.medium,
      createdAt: DateTime.now(),
      relatedData: {
        'averageTimeSeconds': averageTime.inSeconds,
        'thresholdSeconds': threshold.inSeconds,
      },
    );
  }

  Recommendation _createAccuracyRecommendation({
    required double accuracy,
    required double threshold,
  }) {
    return Recommendation(
      id: 'accuracy_${DateTime.now().millisecondsSinceEpoch}',
      type: RecommendationType.accuracy,
      title: 'Focus on Accuracy',
      description:
          'Your recent accuracy (${(accuracy * 100).round()}%) is below '
          'the target of ${(threshold * 100).round()}%. Consider reviewing '
          'the material before attempting more questions.',
      priority:
          accuracy < 0.4 ? RecommendationPriority.high : RecommendationPriority.medium,
      actionLabel: 'Review Material',
      createdAt: DateTime.now(),
      relatedData: {
        'accuracy': accuracy,
        'threshold': threshold,
      },
    );
  }

  Recommendation _createSkipRecommendation({
    required double skipRate,
    required double threshold,
  }) {
    return Recommendation(
      id: 'skip_${DateTime.now().millisecondsSinceEpoch}',
      type: RecommendationType.skipPattern,
      title: 'Reduce Skipping',
      description:
          'You\'re skipping ${(skipRate * 100).round()}% of questions. '
          'Try to attempt more questions, even if you\'re unsure - '
          'it helps reinforce your learning.',
      priority: RecommendationPriority.medium,
      createdAt: DateTime.now(),
      relatedData: {
        'skipRate': skipRate,
        'threshold': threshold,
      },
    );
  }

  Recommendation _createTopicRecommendation({
    required String topic,
    required double accuracy,
    String? topicId,
  }) {
    return Recommendation(
      id: 'topic_${topicId ?? topic}_${DateTime.now().millisecondsSinceEpoch}',
      type: RecommendationType.subjectFocus,
      title: 'Focus on $topic',
      description:
          'Your performance in $topic (${(accuracy * 100).round()}%) '
          'needs improvement. Consider dedicating more study time to this area.',
      priority: accuracy < 0.4
          ? RecommendationPriority.high
          : RecommendationPriority.medium,
      actionLabel: 'Study $topic',
      relatedTopicId: topicId,
      createdAt: DateTime.now(),
      relatedData: {'topic': topic, 'accuracy': accuracy},
    );
  }

  Duration _calculateAverageQuestionTime(List<QuizAnalytics> quizzes) {
    final times = quizzes
        .where((q) => q.averageTimePerQuestion != null)
        .map((q) => q.averageTimePerQuestion!.inMilliseconds)
        .toList();

    if (times.isEmpty) return Duration.zero;

    final avgMs = times.reduce((a, b) => a + b) ~/ times.length;
    return Duration(milliseconds: avgMs);
  }
}
