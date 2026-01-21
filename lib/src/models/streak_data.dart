/// Data model for tracking learning streaks.
///
/// A streak represents consecutive days of learning activity.
class StreakData {
  /// Creates a new [StreakData].
  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    this.totalActiveDays = 0,
    this.weeklyActivity = const {},
    this.monthlyActivity = const {},
    this.streakHistory = const [],
  });

  /// Current consecutive day streak.
  final int currentStreak;

  /// Longest streak ever achieved.
  final int longestStreak;

  /// The last date with recorded activity.
  final DateTime lastActivityDate;

  /// Total number of days with activity.
  final int totalActiveDays;

  /// Activity for the current week (day of week -> bool).
  /// 1 = Monday, 7 = Sunday
  final Map<int, bool> weeklyActivity;

  /// Activity for the current month (day number -> activity count).
  final Map<int, int> monthlyActivity;

  /// History of past streaks.
  final List<StreakPeriod> streakHistory;

  /// Whether the streak is still active (activity today or yesterday).
  bool get isStreakActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );
    final difference = today.difference(lastDay).inDays;
    return difference <= 1;
  }

  /// Whether activity has been recorded today.
  bool get hasActivityToday {
    final now = DateTime.now();
    return lastActivityDate.year == now.year &&
        lastActivityDate.month == now.month &&
        lastActivityDate.day == now.day;
  }

  /// Days until the streak breaks (0 if already broken, 1 if today is last chance).
  int get daysUntilStreakBreaks {
    if (!isStreakActive) return 0;
    if (hasActivityToday) return 2; // Today done, tomorrow is safe
    return 1; // Must do today
  }

  /// Gets the activity status for a specific day this week.
  bool dayHasActivity(int dayOfWeek) {
    return weeklyActivity[dayOfWeek] ?? false;
  }

  /// Gets the number of active days this week.
  int get activeDaysThisWeek {
    return weeklyActivity.values.where((active) => active).length;
  }

  /// Creates a copy with the given fields replaced.
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    int? totalActiveDays,
    Map<int, bool>? weeklyActivity,
    Map<int, int>? monthlyActivity,
    List<StreakPeriod>? streakHistory,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      totalActiveDays: totalActiveDays ?? this.totalActiveDays,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      monthlyActivity: monthlyActivity ?? this.monthlyActivity,
      streakHistory: streakHistory ?? this.streakHistory,
    );
  }

  /// Creates an empty [StreakData].
  factory StreakData.empty() {
    return StreakData(
      currentStreak: 0,
      longestStreak: 0,
      lastActivityDate: DateTime.now().subtract(const Duration(days: 2)),
    );
  }

  /// Creates from JSON.
  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastActivityDate: DateTime.parse(json['lastActivityDate'] as String),
      totalActiveDays: json['totalActiveDays'] as int? ?? 0,
      weeklyActivity: (json['weeklyActivity'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v as bool),
          ) ??
          const {},
      monthlyActivity: (json['monthlyActivity'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v as int),
          ) ??
          const {},
      streakHistory: (json['streakHistory'] as List<dynamic>?)
              ?.map((e) => StreakPeriod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'totalActiveDays': totalActiveDays,
      'weeklyActivity':
          weeklyActivity.map((k, v) => MapEntry(k.toString(), v)),
      'monthlyActivity':
          monthlyActivity.map((k, v) => MapEntry(k.toString(), v)),
      'streakHistory': streakHistory.map((p) => p.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'StreakData(current: $currentStreak days, longest: $longestStreak days)';
  }
}

/// Represents a period when a streak was maintained.
class StreakPeriod {
  /// Creates a new [StreakPeriod].
  const StreakPeriod({
    required this.startDate,
    required this.endDate,
    required this.length,
  });

  /// When the streak started.
  final DateTime startDate;

  /// When the streak ended.
  final DateTime endDate;

  /// Length of the streak in days.
  final int length;

  /// Creates from JSON.
  factory StreakPeriod.fromJson(Map<String, dynamic> json) {
    return StreakPeriod(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      length: json['length'] as int,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'length': length,
    };
  }
}

/// Represents daily activity data.
class DailyActivity {
  /// Creates a new [DailyActivity].
  const DailyActivity({
    required this.date,
    required this.activityCount,
    this.minutesSpent = 0,
    this.questionsAnswered = 0,
    this.xpEarned = 0,
  });

  /// The date of the activity.
  final DateTime date;

  /// Number of activities (sessions, reviews, etc.).
  final int activityCount;

  /// Minutes spent learning.
  final int minutesSpent;

  /// Number of questions answered.
  final int questionsAnswered;

  /// XP earned on this day.
  final int xpEarned;

  /// Whether there was any activity.
  bool get hasActivity => activityCount > 0;

  /// Activity intensity level (0-4).
  int get intensityLevel {
    if (activityCount == 0) return 0;
    if (activityCount <= 2) return 1;
    if (activityCount <= 5) return 2;
    if (activityCount <= 10) return 3;
    return 4;
  }

  /// Creates from JSON.
  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      date: DateTime.parse(json['date'] as String),
      activityCount: json['activityCount'] as int,
      minutesSpent: json['minutesSpent'] as int? ?? 0,
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'activityCount': activityCount,
      'minutesSpent': minutesSpent,
      'questionsAnswered': questionsAnswered,
      'xpEarned': xpEarned,
    };
  }
}
