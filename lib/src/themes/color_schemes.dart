import 'package:flutter/material.dart';

/// Pre-defined color schemes for learning analytics.
class AnalyticsColorSchemes {
  AnalyticsColorSchemes._();

  /// Default color scheme.
  static const defaultColors = AnalyticsColors(
    primary: Color(0xFF2196F3),
    correct: Color(0xFF4CAF50),
    incorrect: Color(0xFFF44336),
    skipped: Color(0xFFFF9800),
    streak: Color(0xFFFF5722),
    novice: Color(0xFF9E9E9E),
    beginner: Color(0xFFFF9800),
    intermediate: Color(0xFFFFC107),
    advanced: Color(0xFF4CAF50),
    expert: Color(0xFF2196F3),
  );

  /// Ocean-inspired color scheme.
  static const ocean = AnalyticsColors(
    primary: Color(0xFF006064),
    correct: Color(0xFF00897B),
    incorrect: Color(0xFFD84315),
    skipped: Color(0xFF0097A7),
    streak: Color(0xFF00BCD4),
    novice: Color(0xFF90A4AE),
    beginner: Color(0xFF26C6DA),
    intermediate: Color(0xFF00ACC1),
    advanced: Color(0xFF0097A7),
    expert: Color(0xFF006064),
  );

  /// Forest-inspired color scheme.
  static const forest = AnalyticsColors(
    primary: Color(0xFF2E7D32),
    correct: Color(0xFF43A047),
    incorrect: Color(0xFFD32F2F),
    skipped: Color(0xFF795548),
    streak: Color(0xFFFFC107),
    novice: Color(0xFFBCAAA4),
    beginner: Color(0xFF8D6E63),
    intermediate: Color(0xFF66BB6A),
    advanced: Color(0xFF43A047),
    expert: Color(0xFF2E7D32),
  );

  /// Sunset-inspired color scheme.
  static const sunset = AnalyticsColors(
    primary: Color(0xFFE65100),
    correct: Color(0xFF7CB342),
    incorrect: Color(0xFFC62828),
    skipped: Color(0xFFFFA000),
    streak: Color(0xFFFF6F00),
    novice: Color(0xFFBDBDBD),
    beginner: Color(0xFFFFCA28),
    intermediate: Color(0xFFFFA726),
    advanced: Color(0xFFFF7043),
    expert: Color(0xFFE65100),
  );

  /// Monochrome color scheme.
  static const monochrome = AnalyticsColors(
    primary: Color(0xFF424242),
    correct: Color(0xFF616161),
    incorrect: Color(0xFF212121),
    skipped: Color(0xFF9E9E9E),
    streak: Color(0xFF424242),
    novice: Color(0xFFE0E0E0),
    beginner: Color(0xFFBDBDBD),
    intermediate: Color(0xFF9E9E9E),
    advanced: Color(0xFF757575),
    expert: Color(0xFF424242),
  );

  /// Neon-inspired color scheme.
  static const neon = AnalyticsColors(
    primary: Color(0xFF651FFF),
    correct: Color(0xFF00E676),
    incorrect: Color(0xFFFF1744),
    skipped: Color(0xFFFFEA00),
    streak: Color(0xFFFF9100),
    novice: Color(0xFF90A4AE),
    beginner: Color(0xFF40C4FF),
    intermediate: Color(0xFF7C4DFF),
    advanced: Color(0xFF536DFE),
    expert: Color(0xFF651FFF),
  );
}

/// Color palette for analytics widgets.
class AnalyticsColors {
  /// Creates a new [AnalyticsColors].
  const AnalyticsColors({
    required this.primary,
    required this.correct,
    required this.incorrect,
    required this.skipped,
    required this.streak,
    required this.novice,
    required this.beginner,
    required this.intermediate,
    required this.advanced,
    required this.expert,
  });

  /// Primary/accent color.
  final Color primary;

  /// Color for correct answers.
  final Color correct;

  /// Color for incorrect answers.
  final Color incorrect;

  /// Color for skipped items.
  final Color skipped;

  /// Color for streak indicators.
  final Color streak;

  /// Color for novice mastery level.
  final Color novice;

  /// Color for beginner mastery level.
  final Color beginner;

  /// Color for intermediate mastery level.
  final Color intermediate;

  /// Color for advanced mastery level.
  final Color advanced;

  /// Color for expert mastery level.
  final Color expert;

  /// Gets the color for accuracy display.
  List<Color> get accuracyColors => [correct, incorrect, skipped];

  /// Gets mastery level colors in order.
  List<Color> get masteryColors => [
        novice,
        beginner,
        intermediate,
        advanced,
        expert,
      ];

  /// Creates a gradient from the primary color.
  LinearGradient primaryGradient({
    double opacity = 0.3,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [
        primary.withOpacity(opacity),
        primary.withOpacity(0),
      ],
      begin: begin,
      end: end,
    );
  }
}

/// Heatmap color options.
class HeatmapColors {
  HeatmapColors._();

  /// Green heatmap (GitHub-style).
  static const green = [
    Color(0xFFEBEDF0),
    Color(0xFF9BE9A8),
    Color(0xFF40C463),
    Color(0xFF30A14E),
    Color(0xFF216E39),
  ];

  /// Blue heatmap.
  static const blue = [
    Color(0xFFEBEDF0),
    Color(0xFFBBDEFB),
    Color(0xFF64B5F6),
    Color(0xFF2196F3),
    Color(0xFF1565C0),
  ];

  /// Purple heatmap.
  static const purple = [
    Color(0xFFEBEDF0),
    Color(0xFFE1BEE7),
    Color(0xFFBA68C8),
    Color(0xFF9C27B0),
    Color(0xFF6A1B9A),
  ];

  /// Orange heatmap.
  static const orange = [
    Color(0xFFEBEDF0),
    Color(0xFFFFE0B2),
    Color(0xFFFFB74D),
    Color(0xFFFF9800),
    Color(0xFFE65100),
  ];

  /// Red heatmap.
  static const red = [
    Color(0xFFEBEDF0),
    Color(0xFFFFCDD2),
    Color(0xFFE57373),
    Color(0xFFF44336),
    Color(0xFFC62828),
  ];
}

/// Grade color mapping.
class GradeColors {
  GradeColors._();

  /// Default grade colors.
  static Color forGrade(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
      case 'A+':
      case 'A-':
        return const Color(0xFF4CAF50);
      case 'B':
      case 'B+':
      case 'B-':
        return const Color(0xFF8BC34A);
      case 'C':
      case 'C+':
      case 'C-':
        return const Color(0xFFFFC107);
      case 'D':
      case 'D+':
      case 'D-':
        return const Color(0xFFFF9800);
      case 'F':
      default:
        return const Color(0xFFF44336);
    }
  }

  /// Gets color for a percentage score.
  static Color forPercentage(double percentage) {
    if (percentage >= 90) return const Color(0xFF4CAF50);
    if (percentage >= 80) return const Color(0xFF8BC34A);
    if (percentage >= 70) return const Color(0xFFFFC107);
    if (percentage >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}
