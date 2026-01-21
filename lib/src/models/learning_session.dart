/// A model representing a single learning session.
///
/// A learning session captures the user's activity during a study period,
/// including duration, questions answered, and performance metrics.
class LearningSession {
  /// Creates a new [LearningSession].
  const LearningSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.questionsAttempted,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    this.subjectId,
    this.topicId,
    this.averageTimePerQuestion,
    this.xpEarned = 0,
    this.metadata = const {},
  });

  /// Unique identifier for the session.
  final String id;

  /// When the session started.
  final DateTime startTime;

  /// When the session ended.
  final DateTime endTime;

  /// Total number of questions attempted.
  final int questionsAttempted;

  /// Number of correct answers.
  final int correctAnswers;

  /// Number of wrong answers.
  final int wrongAnswers;

  /// Number of skipped questions.
  final int skippedQuestions;

  /// Optional subject identifier.
  final String? subjectId;

  /// Optional topic identifier.
  final String? topicId;

  /// Average time spent per question.
  final Duration? averageTimePerQuestion;

  /// Experience points earned during this session.
  final int xpEarned;

  /// Additional metadata for the session.
  final Map<String, dynamic> metadata;

  /// The duration of the session.
  Duration get duration => endTime.difference(startTime);

  /// The accuracy rate (0.0 to 1.0).
  double get accuracy {
    if (questionsAttempted == 0) return 0.0;
    return correctAnswers / questionsAttempted;
  }

  /// The completion rate (answered questions / total attempted).
  double get completionRate {
    if (questionsAttempted == 0) return 0.0;
    return (correctAnswers + wrongAnswers) / questionsAttempted;
  }

  /// The skip rate (0.0 to 1.0).
  double get skipRate {
    if (questionsAttempted == 0) return 0.0;
    return skippedQuestions / questionsAttempted;
  }

  /// Creates a copy with the given fields replaced.
  LearningSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? questionsAttempted,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedQuestions,
    String? subjectId,
    String? topicId,
    Duration? averageTimePerQuestion,
    int? xpEarned,
    Map<String, dynamic>? metadata,
  }) {
    return LearningSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      questionsAttempted: questionsAttempted ?? this.questionsAttempted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      averageTimePerQuestion:
          averageTimePerQuestion ?? this.averageTimePerQuestion,
      xpEarned: xpEarned ?? this.xpEarned,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates a [LearningSession] from a JSON map.
  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      questionsAttempted: json['questionsAttempted'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      skippedQuestions: json['skippedQuestions'] as int,
      subjectId: json['subjectId'] as String?,
      topicId: json['topicId'] as String?,
      averageTimePerQuestion: json['averageTimePerQuestion'] != null
          ? Duration(milliseconds: json['averageTimePerQuestion'] as int)
          : null,
      xpEarned: json['xpEarned'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  /// Converts this session to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'questionsAttempted': questionsAttempted,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'skippedQuestions': skippedQuestions,
      'subjectId': subjectId,
      'topicId': topicId,
      'averageTimePerQuestion': averageTimePerQuestion?.inMilliseconds,
      'xpEarned': xpEarned,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LearningSession(id: $id, accuracy: ${(accuracy * 100).toStringAsFixed(1)}%)';
  }
}
