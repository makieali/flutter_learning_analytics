import 'learning_session.dart';
import 'mastery_level.dart';
import 'progress_point.dart';
import 'quiz_analytics.dart';
import 'recommendation.dart';
import 'retention_data.dart';
import 'streak_data.dart';

/// Comprehensive data model for the analytics dashboard.
///
/// This model aggregates all learning data needed to display
/// a complete analytics dashboard.
class LearningAnalyticsData {
  /// Creates a new [LearningAnalyticsData].
  const LearningAnalyticsData({
    this.sessions = const [],
    this.quizzes = const [],
    this.masteryProgress = const [],
    this.progressHistory = const [],
    this.streakData,
    this.retentionItems = const [],
    this.recommendations = const [],
    this.skillData = const [],
    this.activityMap = const {},
    this.totalXp = 0,
    this.currentLevel = 1,
    this.metadata = const {},
  });

  /// List of learning sessions.
  final List<LearningSession> sessions;

  /// List of quiz analytics.
  final List<QuizAnalytics> quizzes;

  /// Mastery progress for each topic.
  final List<MasteryProgress> masteryProgress;

  /// Progress history over time.
  final List<ProgressPoint> progressHistory;

  /// Streak tracking data.
  final StreakData? streakData;

  /// Items being tracked for retention.
  final List<RetentionData> retentionItems;

  /// Generated recommendations.
  final List<Recommendation> recommendations;

  /// Skill data for radar charts.
  final List<SkillData> skillData;

  /// Activity heatmap data (date -> activity count).
  final Map<DateTime, int> activityMap;

  /// Total experience points.
  final int totalXp;

  /// Current level based on XP.
  final int currentLevel;

  /// Additional metadata.
  final Map<String, dynamic> metadata;

  // Computed properties

  /// Total questions answered across all sessions.
  int get totalQuestionsAnswered {
    return sessions.fold(0, (sum, s) => sum + s.questionsAttempted);
  }

  /// Total correct answers.
  int get totalCorrectAnswers {
    return sessions.fold(0, (sum, s) => sum + s.correctAnswers);
  }

  /// Total wrong answers.
  int get totalWrongAnswers {
    return sessions.fold(0, (sum, s) => sum + s.wrongAnswers);
  }

  /// Total skipped questions.
  int get totalSkippedQuestions {
    return sessions.fold(0, (sum, s) => sum + s.skippedQuestions);
  }

  /// Overall accuracy rate.
  double get overallAccuracy {
    if (totalQuestionsAnswered == 0) return 0;
    return totalCorrectAnswers / totalQuestionsAnswered;
  }

  /// Total time spent learning.
  Duration get totalTimeSpent {
    return sessions.fold(
      Duration.zero,
      (sum, s) => sum + s.duration,
    );
  }

  /// Average session duration.
  Duration get averageSessionDuration {
    if (sessions.isEmpty) return Duration.zero;
    return Duration(
      milliseconds: totalTimeSpent.inMilliseconds ~/ sessions.length,
    );
  }

  /// Number of topics at each mastery level.
  Map<MasteryLevel, int> get masteryDistribution {
    final distribution = <MasteryLevel, int>{};
    for (final level in MasteryLevel.values) {
      distribution[level] = 0;
    }
    for (final progress in masteryProgress) {
      distribution[progress.level] = (distribution[progress.level] ?? 0) + 1;
    }
    return distribution;
  }

  /// Topics that need attention (low mastery).
  List<MasteryProgress> get topicsNeedingAttention {
    return masteryProgress
        .where(
          (p) =>
              p.level == MasteryLevel.novice || p.level == MasteryLevel.beginner,
        )
        .toList()
      ..sort((a, b) => a.currentScore.compareTo(b.currentScore));
  }

  /// Top performing topics.
  List<MasteryProgress> get topPerformingTopics {
    return masteryProgress
        .where(
          (p) =>
              p.level == MasteryLevel.advanced || p.level == MasteryLevel.expert,
        )
        .toList()
      ..sort((a, b) => b.currentScore.compareTo(a.currentScore));
  }

  /// Items due for review (low retention).
  List<RetentionData> get itemsDueForReview {
    return retentionItems.where((item) => item.isReviewDue()).toList()
      ..sort(
        (a, b) => a
            .calculateRetrievability()
            .compareTo(b.calculateRetrievability()),
      );
  }

  /// Retention statistics.
  RetentionStats get retentionStats {
    return RetentionStats.fromItems(retentionItems);
  }

  /// High priority recommendations.
  List<Recommendation> get highPriorityRecommendations {
    return recommendations
        .where(
          (r) =>
              r.priority == RecommendationPriority.high ||
              r.priority == RecommendationPriority.critical,
        )
        .toList();
  }

  /// Creates a copy with the given fields replaced.
  LearningAnalyticsData copyWith({
    List<LearningSession>? sessions,
    List<QuizAnalytics>? quizzes,
    List<MasteryProgress>? masteryProgress,
    List<ProgressPoint>? progressHistory,
    StreakData? streakData,
    List<RetentionData>? retentionItems,
    List<Recommendation>? recommendations,
    List<SkillData>? skillData,
    Map<DateTime, int>? activityMap,
    int? totalXp,
    int? currentLevel,
    Map<String, dynamic>? metadata,
  }) {
    return LearningAnalyticsData(
      sessions: sessions ?? this.sessions,
      quizzes: quizzes ?? this.quizzes,
      masteryProgress: masteryProgress ?? this.masteryProgress,
      progressHistory: progressHistory ?? this.progressHistory,
      streakData: streakData ?? this.streakData,
      retentionItems: retentionItems ?? this.retentionItems,
      recommendations: recommendations ?? this.recommendations,
      skillData: skillData ?? this.skillData,
      activityMap: activityMap ?? this.activityMap,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates an empty [LearningAnalyticsData].
  factory LearningAnalyticsData.empty() {
    return const LearningAnalyticsData();
  }

  /// Creates sample data for testing/demo purposes.
  factory LearningAnalyticsData.sample() {
    final now = DateTime.now();

    return LearningAnalyticsData(
      sessions: [
        LearningSession(
          id: '1',
          startTime: now.subtract(const Duration(hours: 2)),
          endTime: now.subtract(const Duration(hours: 1)),
          questionsAttempted: 20,
          correctAnswers: 15,
          wrongAnswers: 4,
          skippedQuestions: 1,
        ),
      ],
      streakData: StreakData(
        currentStreak: 7,
        longestStreak: 14,
        lastActivityDate: now,
        totalActiveDays: 45,
        weeklyActivity: {1: true, 2: true, 3: true, 4: true, 5: true, 6: false, 7: false},
      ),
      totalXp: 1250,
      currentLevel: 5,
    );
  }
}
