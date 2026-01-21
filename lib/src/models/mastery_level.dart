import 'package:flutter/material.dart';

/// Represents different levels of mastery for a topic or skill.
enum MasteryLevel {
  /// No exposure to the topic yet.
  novice(0, 'Novice', 0.0, 0.2),

  /// Basic understanding, just getting started.
  beginner(1, 'Beginner', 0.2, 0.4),

  /// Developing competence, making progress.
  intermediate(2, 'Intermediate', 0.4, 0.6),

  /// Strong understanding, consistently performing well.
  advanced(3, 'Advanced', 0.6, 0.8),

  /// Complete mastery, expert-level performance.
  expert(4, 'Expert', 0.8, 1.0);

  const MasteryLevel(
    this.value,
    this.displayName,
    this.minThreshold,
    this.maxThreshold,
  );

  /// Numeric value of the level (0-4).
  final int value;

  /// Human-readable name.
  final String displayName;

  /// Minimum score threshold for this level.
  final double minThreshold;

  /// Maximum score threshold for this level.
  final double maxThreshold;

  /// Gets the appropriate mastery level for a given score (0.0 to 1.0).
  static MasteryLevel fromScore(double score) {
    if (score >= MasteryLevel.expert.minThreshold) return MasteryLevel.expert;
    if (score >= MasteryLevel.advanced.minThreshold) {
      return MasteryLevel.advanced;
    }
    if (score >= MasteryLevel.intermediate.minThreshold) {
      return MasteryLevel.intermediate;
    }
    if (score >= MasteryLevel.beginner.minThreshold) {
      return MasteryLevel.beginner;
    }
    return MasteryLevel.novice;
  }

  /// Gets the default color for this mastery level.
  Color get defaultColor {
    switch (this) {
      case MasteryLevel.novice:
        return const Color(0xFF9E9E9E); // Grey
      case MasteryLevel.beginner:
        return const Color(0xFFFF9800); // Orange
      case MasteryLevel.intermediate:
        return const Color(0xFFFFC107); // Amber
      case MasteryLevel.advanced:
        return const Color(0xFF4CAF50); // Green
      case MasteryLevel.expert:
        return const Color(0xFF2196F3); // Blue
    }
  }

  /// Gets the icon for this mastery level.
  IconData get icon {
    switch (this) {
      case MasteryLevel.novice:
        return Icons.star_border;
      case MasteryLevel.beginner:
        return Icons.star_half;
      case MasteryLevel.intermediate:
        return Icons.star;
      case MasteryLevel.advanced:
        return Icons.stars;
      case MasteryLevel.expert:
        return Icons.emoji_events;
    }
  }

  /// Returns progress within this level (0.0 to 1.0).
  double progressInLevel(double score) {
    if (score < minThreshold) return 0.0;
    if (score >= maxThreshold) return 1.0;
    return (score - minThreshold) / (maxThreshold - minThreshold);
  }
}

/// Tracks mastery progress for a specific topic or skill.
class MasteryProgress {
  /// Creates a new [MasteryProgress].
  const MasteryProgress({
    required this.topicId,
    required this.topicName,
    required this.currentScore,
    required this.totalAttempts,
    required this.correctAttempts,
    this.lastAttemptDate,
    this.scoreHistory = const [],
  });

  /// The topic identifier.
  final String topicId;

  /// Human-readable topic name.
  final String topicName;

  /// Current mastery score (0.0 to 1.0).
  final double currentScore;

  /// Total number of attempts.
  final int totalAttempts;

  /// Number of correct attempts.
  final int correctAttempts;

  /// When the last attempt was made.
  final DateTime? lastAttemptDate;

  /// Historical score progression.
  final List<MasteryHistoryPoint> scoreHistory;

  /// The current mastery level.
  MasteryLevel get level => MasteryLevel.fromScore(currentScore);

  /// Progress within the current level (0.0 to 1.0).
  double get progressInLevel => level.progressInLevel(currentScore);

  /// Overall accuracy rate.
  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return correctAttempts / totalAttempts;
  }

  /// Points needed to reach the next level.
  double? get pointsToNextLevel {
    if (level == MasteryLevel.expert) return null;
    final nextLevel = MasteryLevel.values[level.value + 1];
    return nextLevel.minThreshold - currentScore;
  }

  /// Creates a copy with the given fields replaced.
  MasteryProgress copyWith({
    String? topicId,
    String? topicName,
    double? currentScore,
    int? totalAttempts,
    int? correctAttempts,
    DateTime? lastAttemptDate,
    List<MasteryHistoryPoint>? scoreHistory,
  }) {
    return MasteryProgress(
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      currentScore: currentScore ?? this.currentScore,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      lastAttemptDate: lastAttemptDate ?? this.lastAttemptDate,
      scoreHistory: scoreHistory ?? this.scoreHistory,
    );
  }

  /// Creates from JSON.
  factory MasteryProgress.fromJson(Map<String, dynamic> json) {
    return MasteryProgress(
      topicId: json['topicId'] as String,
      topicName: json['topicName'] as String,
      currentScore: (json['currentScore'] as num).toDouble(),
      totalAttempts: json['totalAttempts'] as int,
      correctAttempts: json['correctAttempts'] as int,
      lastAttemptDate: json['lastAttemptDate'] != null
          ? DateTime.parse(json['lastAttemptDate'] as String)
          : null,
      scoreHistory: (json['scoreHistory'] as List<dynamic>?)
              ?.map(
                (e) => MasteryHistoryPoint.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'topicId': topicId,
      'topicName': topicName,
      'currentScore': currentScore,
      'totalAttempts': totalAttempts,
      'correctAttempts': correctAttempts,
      'lastAttemptDate': lastAttemptDate?.toIso8601String(),
      'scoreHistory': scoreHistory.map((p) => p.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'MasteryProgress(topic: $topicName, level: ${level.displayName}, score: ${(currentScore * 100).toStringAsFixed(1)}%)';
  }
}

/// A single point in mastery score history.
class MasteryHistoryPoint {
  /// Creates a new [MasteryHistoryPoint].
  const MasteryHistoryPoint({
    required this.date,
    required this.score,
  });

  /// When this score was recorded.
  final DateTime date;

  /// The score at this point in time (0.0 to 1.0).
  final double score;

  /// The mastery level at this point.
  MasteryLevel get level => MasteryLevel.fromScore(score);

  /// Creates from JSON.
  factory MasteryHistoryPoint.fromJson(Map<String, dynamic> json) {
    return MasteryHistoryPoint(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'score': score,
    };
  }
}
