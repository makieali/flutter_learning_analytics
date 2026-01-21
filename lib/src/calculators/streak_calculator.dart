import '../models/streak_data.dart';

/// Calculator for managing learning streaks.
///
/// Tracks consecutive days of learning activity and provides
/// streak-related calculations and updates.
class StreakCalculator {
  /// Creates a new [StreakCalculator].
  const StreakCalculator({
    this.freezeDays = 0,
    this.gracePeriodHours = 0,
  });

  /// Number of "freeze" days allowed (streak protection).
  final int freezeDays;

  /// Grace period in hours past midnight before streak breaks.
  final int gracePeriodHours;

  /// Calculates the updated streak data when activity is recorded.
  ///
  /// [currentData] - Current streak data
  /// [activityDate] - When the activity occurred (defaults to now)
  StreakData recordActivity({
    required StreakData currentData,
    DateTime? activityDate,
  }) {
    final now = activityDate ?? DateTime.now();
    final today = _normalizeDate(now);
    final lastActivity = _normalizeDate(currentData.lastActivityDate);

    final daysDifference = today.difference(lastActivity).inDays;

    int newStreak;
    int newLongest = currentData.longestStreak;
    List<StreakPeriod> newHistory = List.from(currentData.streakHistory);

    if (daysDifference == 0) {
      // Same day - no change to streak
      newStreak = currentData.currentStreak;
    } else if (daysDifference == 1) {
      // Consecutive day - increment streak
      newStreak = currentData.currentStreak + 1;
    } else if (daysDifference <= 1 + freezeDays) {
      // Within freeze period - maintain streak but don't increment
      newStreak = currentData.currentStreak;
    } else {
      // Streak broken - save old streak to history and start new
      if (currentData.currentStreak > 1) {
        final streakStart = lastActivity.subtract(
          Duration(days: currentData.currentStreak - 1),
        );
        newHistory = [
          ...newHistory,
          StreakPeriod(
            startDate: streakStart,
            endDate: lastActivity,
            length: currentData.currentStreak,
          ),
        ];
      }
      newStreak = 1;
    }

    if (newStreak > newLongest) {
      newLongest = newStreak;
    }

    // Update weekly activity
    final weekDay = now.weekday;
    final newWeeklyActivity = Map<int, bool>.from(currentData.weeklyActivity);
    newWeeklyActivity[weekDay] = true;

    // Update monthly activity
    final dayOfMonth = now.day;
    final newMonthlyActivity = Map<int, int>.from(currentData.monthlyActivity);
    newMonthlyActivity[dayOfMonth] =
        (newMonthlyActivity[dayOfMonth] ?? 0) + 1;

    return currentData.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastActivityDate: now,
      totalActiveDays: currentData.totalActiveDays + (daysDifference > 0 ? 1 : 0),
      weeklyActivity: newWeeklyActivity,
      monthlyActivity: newMonthlyActivity,
      streakHistory: newHistory,
    );
  }

  /// Checks if the streak is still valid.
  ///
  /// [lastActivityDate] - When the last activity occurred
  /// [currentDate] - Current date (defaults to now)
  bool isStreakValid({
    required DateTime lastActivityDate,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final today = _normalizeDate(now);
    final lastActivity = _normalizeDate(lastActivityDate);

    final daysDifference = today.difference(lastActivity).inDays;

    // Account for grace period
    if (daysDifference == 1 && gracePeriodHours > 0) {
      final hoursPastMidnight = now.hour;
      if (hoursPastMidnight < gracePeriodHours) {
        return true;
      }
    }

    return daysDifference <= 1 + freezeDays;
  }

  /// Calculates how many hours until the streak breaks.
  ///
  /// Returns null if the streak is already broken.
  Duration? timeUntilStreakBreaks({
    required DateTime lastActivityDate,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final today = _normalizeDate(now);
    final lastActivity = _normalizeDate(lastActivityDate);

    final daysDifference = today.difference(lastActivity).inDays;

    if (daysDifference > 1 + freezeDays) {
      // Already broken
      return null;
    }

    // Calculate deadline (end of next day + grace period)
    final deadline = lastActivity
        .add(Duration(days: 2 + freezeDays))
        .add(Duration(hours: gracePeriodHours));

    final remaining = deadline.difference(now);
    return remaining.isNegative ? null : remaining;
  }

  /// Generates weekly activity grid for display.
  ///
  /// [activityDates] - Set of dates with activity
  /// [weekStartDate] - Start of the week to display
  List<DailyActivityStatus> generateWeekGrid({
    required Set<DateTime> activityDates,
    DateTime? weekStartDate,
  }) {
    final normalizedDates =
        activityDates.map((d) => _normalizeDate(d)).toSet();

    final startDate = weekStartDate ?? _getWeekStart(DateTime.now());
    final grid = <DailyActivityStatus>[];

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final hasActivity = normalizedDates.contains(date);
      final isToday = _normalizeDate(DateTime.now()) == date;
      final isFuture = date.isAfter(DateTime.now());

      grid.add(DailyActivityStatus(
        date: date,
        dayOfWeek: date.weekday,
        hasActivity: hasActivity,
        isToday: isToday,
        isFuture: isFuture,
      ));
    }

    return grid;
  }

  /// Generates activity data for a heatmap calendar.
  ///
  /// [activityCounts] - Map of dates to activity counts
  /// [startDate] - Start date for the calendar
  /// [endDate] - End date for the calendar
  List<HeatmapDay> generateHeatmapData({
    required Map<DateTime, int> activityCounts,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final normalizedCounts = <DateTime, int>{};
    for (final entry in activityCounts.entries) {
      normalizedCounts[_normalizeDate(entry.key)] = entry.value;
    }

    final days = <HeatmapDay>[];
    var current = _normalizeDate(startDate);
    final end = _normalizeDate(endDate);

    while (!current.isAfter(end)) {
      final count = normalizedCounts[current] ?? 0;
      days.add(HeatmapDay(
        date: current,
        count: count,
        level: _getIntensityLevel(count),
      ));
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  /// Calculates the longest streak from a set of activity dates.
  int calculateLongestStreak(Set<DateTime> activityDates) {
    if (activityDates.isEmpty) return 0;

    final sortedDates = activityDates.map(_normalizeDate).toList()..sort();

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final daysDiff =
          sortedDates[i].difference(sortedDates[i - 1]).inDays;

      if (daysDiff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (daysDiff > 1) {
        currentStreak = 1;
      }
      // daysDiff == 0 means duplicate date, skip
    }

    return longestStreak;
  }

  /// Calculates the current streak from a set of activity dates.
  int calculateCurrentStreak(Set<DateTime> activityDates) {
    if (activityDates.isEmpty) return 0;

    final sortedDates = activityDates.map(_normalizeDate).toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    final today = _normalizeDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if the most recent activity was today or yesterday
    if (sortedDates.first != today && sortedDates.first != yesterday) {
      return 0; // Streak is broken
    }

    int streak = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final daysDiff =
          sortedDates[i - 1].difference(sortedDates[i]).inDays;

      if (daysDiff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _getWeekStart(DateTime date) {
    final normalized = _normalizeDate(date);
    final daysToSubtract = normalized.weekday - 1; // Monday = 1
    return normalized.subtract(Duration(days: daysToSubtract));
  }

  int _getIntensityLevel(int count) {
    if (count == 0) return 0;
    if (count <= 2) return 1;
    if (count <= 5) return 2;
    if (count <= 10) return 3;
    return 4;
  }
}

/// Status for a single day in the weekly grid.
class DailyActivityStatus {
  /// Creates a new [DailyActivityStatus].
  const DailyActivityStatus({
    required this.date,
    required this.dayOfWeek,
    required this.hasActivity,
    this.isToday = false,
    this.isFuture = false,
  });

  /// The date.
  final DateTime date;

  /// Day of week (1 = Monday, 7 = Sunday).
  final int dayOfWeek;

  /// Whether there was activity on this day.
  final bool hasActivity;

  /// Whether this is today.
  final bool isToday;

  /// Whether this day is in the future.
  final bool isFuture;

  /// Short day name.
  String get shortDayName {
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return names[dayOfWeek - 1];
  }
}

/// Data for a single day in a heatmap.
class HeatmapDay {
  /// Creates a new [HeatmapDay].
  const HeatmapDay({
    required this.date,
    required this.count,
    required this.level,
  });

  /// The date.
  final DateTime date;

  /// Activity count on this day.
  final int count;

  /// Intensity level (0-4).
  final int level;
}
