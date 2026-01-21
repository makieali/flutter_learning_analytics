import 'package:intl/intl.dart';

/// Utility class for formatting values in learning analytics.
class AnalyticsFormatters {
  AnalyticsFormatters._();

  /// Formats a percentage value.
  static String percentage(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Formats a score value.
  static String score(double value, {int decimals = 0}) {
    return value.toStringAsFixed(decimals);
  }

  /// Formats a duration in human-readable format.
  static String duration(Duration duration, {bool short = false}) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (short) {
        return '${hours}h${minutes > 0 ? ' ${minutes}m' : ''}';
      }
      return minutes > 0 ? '$hours hr $minutes min' : '$hours hr';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      if (short) {
        return '${minutes}m${seconds > 0 ? ' ${seconds}s' : ''}';
      }
      return seconds > 0 ? '$minutes min $seconds sec' : '$minutes min';
    } else {
      final seconds = duration.inSeconds;
      return short ? '${seconds}s' : '$seconds sec';
    }
  }

  /// Formats a date.
  static String date(DateTime date, {String? pattern}) {
    final formatter = DateFormat(pattern ?? 'MMM d, yyyy');
    return formatter.format(date);
  }

  /// Formats a date relative to now (e.g., "2 days ago").
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  /// Formats a large number with abbreviations (e.g., 1.5K, 2.3M).
  static String compactNumber(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  /// Formats XP value.
  static String xp(int value) {
    return compactNumber(value);
  }

  /// Gets letter grade for a percentage.
  static String grade(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  /// Formats streak count.
  static String streak(int days) {
    if (days == 0) return 'No streak';
    if (days == 1) return '1 day';
    return '$days days';
  }

  /// Formats retention percentage.
  static String retention(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  /// Formats stability in days.
  static String stability(double days) {
    if (days < 1) {
      return '${(days * 24).toStringAsFixed(0)} hours';
    } else if (days < 7) {
      return '${days.toStringAsFixed(1)} days';
    } else if (days < 30) {
      final weeks = days / 7;
      return '${weeks.toStringAsFixed(1)} weeks';
    } else {
      final months = days / 30;
      return '${months.toStringAsFixed(1)} months';
    }
  }
}

/// Extension methods for formatting.
extension DurationFormatting on Duration {
  /// Formats the duration.
  String format({bool short = false}) {
    return AnalyticsFormatters.duration(this, short: short);
  }
}

extension DateTimeFormatting on DateTime {
  /// Formats the date.
  String format({String? pattern}) {
    return AnalyticsFormatters.date(this, pattern: pattern);
  }

  /// Formats as relative date.
  String toRelativeString() {
    return AnalyticsFormatters.relativeDate(this);
  }
}

extension DoubleFormatting on double {
  /// Formats as percentage.
  String toPercentageString({int decimals = 0}) {
    return AnalyticsFormatters.percentage(this, decimals: decimals);
  }

  /// Gets letter grade.
  String toGrade() {
    return AnalyticsFormatters.grade(this);
  }
}
