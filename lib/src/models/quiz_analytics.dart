/// Analytics data for a quiz or assessment.
///
/// This model captures detailed performance metrics for a quiz,
/// including per-question timing and topic-level breakdowns.
class QuizAnalytics {
  /// Creates a new [QuizAnalytics] instance.
  const QuizAnalytics({
    required this.quizId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    required this.completedAt,
    this.timeTaken,
    this.questionTimes = const [],
    this.topicBreakdown = const {},
    this.difficultyBreakdown = const {},
    this.metadata = const {},
  });

  /// Unique identifier for the quiz.
  final String quizId;

  /// Total number of questions in the quiz.
  final int totalQuestions;

  /// Number of correct answers.
  final int correctAnswers;

  /// Number of wrong answers.
  final int wrongAnswers;

  /// Number of skipped questions.
  final int skippedQuestions;

  /// When the quiz was completed.
  final DateTime completedAt;

  /// Total time taken to complete the quiz.
  final Duration? timeTaken;

  /// Time spent on each question (in order).
  final List<Duration> questionTimes;

  /// Performance breakdown by topic.
  /// Key: topic name, Value: accuracy (0.0 to 1.0)
  final Map<String, double> topicBreakdown;

  /// Performance breakdown by difficulty level.
  /// Key: difficulty (e.g., 'easy', 'medium', 'hard'), Value: accuracy
  final Map<String, double> difficultyBreakdown;

  /// Additional metadata.
  final Map<String, dynamic> metadata;

  /// The accuracy rate (0.0 to 1.0).
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }

  /// The percentage score (0 to 100).
  double get percentageScore => accuracy * 100;

  /// The skip rate (0.0 to 1.0).
  double get skipRate {
    if (totalQuestions == 0) return 0.0;
    return skippedQuestions / totalQuestions;
  }

  /// The error rate (0.0 to 1.0).
  double get errorRate {
    if (totalQuestions == 0) return 0.0;
    return wrongAnswers / totalQuestions;
  }

  /// Average time per question.
  Duration? get averageTimePerQuestion {
    if (questionTimes.isEmpty) {
      if (timeTaken != null && totalQuestions > 0) {
        return Duration(
          milliseconds: timeTaken!.inMilliseconds ~/ totalQuestions,
        );
      }
      return null;
    }
    final totalMs = questionTimes.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ questionTimes.length);
  }

  /// The fastest question time.
  Duration? get fastestTime {
    if (questionTimes.isEmpty) return null;
    return questionTimes.reduce(
      (a, b) => a.inMilliseconds < b.inMilliseconds ? a : b,
    );
  }

  /// The slowest question time.
  Duration? get slowestTime {
    if (questionTimes.isEmpty) return null;
    return questionTimes.reduce(
      (a, b) => a.inMilliseconds > b.inMilliseconds ? a : b,
    );
  }

  /// Gets the letter grade based on accuracy.
  String get grade {
    final score = percentageScore;
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  /// Creates a copy with the given fields replaced.
  QuizAnalytics copyWith({
    String? quizId,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedQuestions,
    DateTime? completedAt,
    Duration? timeTaken,
    List<Duration>? questionTimes,
    Map<String, double>? topicBreakdown,
    Map<String, double>? difficultyBreakdown,
    Map<String, dynamic>? metadata,
  }) {
    return QuizAnalytics(
      quizId: quizId ?? this.quizId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      completedAt: completedAt ?? this.completedAt,
      timeTaken: timeTaken ?? this.timeTaken,
      questionTimes: questionTimes ?? this.questionTimes,
      topicBreakdown: topicBreakdown ?? this.topicBreakdown,
      difficultyBreakdown: difficultyBreakdown ?? this.difficultyBreakdown,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates a [QuizAnalytics] from a JSON map.
  factory QuizAnalytics.fromJson(Map<String, dynamic> json) {
    return QuizAnalytics(
      quizId: json['quizId'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      skippedQuestions: json['skippedQuestions'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      timeTaken: json['timeTaken'] != null
          ? Duration(milliseconds: json['timeTaken'] as int)
          : null,
      questionTimes: (json['questionTimes'] as List<dynamic>?)
              ?.map((e) => Duration(milliseconds: e as int))
              .toList() ??
          const [],
      topicBreakdown:
          (json['topicBreakdown'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              ) ??
              const {},
      difficultyBreakdown:
          (json['difficultyBreakdown'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              ) ??
              const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  /// Converts this analytics to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'skippedQuestions': skippedQuestions,
      'completedAt': completedAt.toIso8601String(),
      'timeTaken': timeTaken?.inMilliseconds,
      'questionTimes': questionTimes.map((d) => d.inMilliseconds).toList(),
      'topicBreakdown': topicBreakdown,
      'difficultyBreakdown': difficultyBreakdown,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizAnalytics && other.quizId == quizId;
  }

  @override
  int get hashCode => quizId.hashCode;

  @override
  String toString() {
    return 'QuizAnalytics(quizId: $quizId, score: ${percentageScore.toStringAsFixed(1)}%, grade: $grade)';
  }
}

/// Represents performance data for a single question.
class QuestionPerformance {
  /// Creates a new [QuestionPerformance].
  const QuestionPerformance({
    required this.questionId,
    required this.isCorrect,
    required this.timeTaken,
    this.wasSkipped = false,
    this.topic,
    this.difficulty,
  });

  /// The question identifier.
  final String questionId;

  /// Whether the answer was correct.
  final bool isCorrect;

  /// Time taken to answer.
  final Duration timeTaken;

  /// Whether the question was skipped.
  final bool wasSkipped;

  /// The topic this question belongs to.
  final String? topic;

  /// The difficulty level.
  final String? difficulty;

  /// Creates from JSON.
  factory QuestionPerformance.fromJson(Map<String, dynamic> json) {
    return QuestionPerformance(
      questionId: json['questionId'] as String,
      isCorrect: json['isCorrect'] as bool,
      timeTaken: Duration(milliseconds: json['timeTaken'] as int),
      wasSkipped: json['wasSkipped'] as bool? ?? false,
      topic: json['topic'] as String?,
      difficulty: json['difficulty'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'isCorrect': isCorrect,
      'timeTaken': timeTaken.inMilliseconds,
      'wasSkipped': wasSkipped,
      'topic': topic,
      'difficulty': difficulty,
    };
  }
}
