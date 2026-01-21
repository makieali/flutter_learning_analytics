import 'package:flutter/material.dart';

/// Theme data for the learning analytics widgets.
///
/// Provides consistent styling across all analytics components.
class LearningAnalyticsThemeData {
  /// Creates a new [LearningAnalyticsThemeData].
  const LearningAnalyticsThemeData({
    this.primaryColor,
    this.correctColor,
    this.incorrectColor,
    this.skippedColor,
    this.streakColor,
    this.backgroundColors,
    this.chartStyle = ChartStyle.rounded,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
  });

  /// Primary accent color.
  final Color? primaryColor;

  /// Color for correct answers/positive outcomes.
  final Color? correctColor;

  /// Color for incorrect answers/negative outcomes.
  final Color? incorrectColor;

  /// Color for skipped items.
  final Color? skippedColor;

  /// Color for streak-related elements.
  final Color? streakColor;

  /// Background color palette.
  final AnalyticsBackgroundColors? backgroundColors;

  /// Chart visual style.
  final ChartStyle chartStyle;

  /// Default animation duration.
  final Duration animationDuration;

  /// Default animation curve.
  final Curve animationCurve;

  /// Creates a copy with the given fields replaced.
  LearningAnalyticsThemeData copyWith({
    Color? primaryColor,
    Color? correctColor,
    Color? incorrectColor,
    Color? skippedColor,
    Color? streakColor,
    AnalyticsBackgroundColors? backgroundColors,
    ChartStyle? chartStyle,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return LearningAnalyticsThemeData(
      primaryColor: primaryColor ?? this.primaryColor,
      correctColor: correctColor ?? this.correctColor,
      incorrectColor: incorrectColor ?? this.incorrectColor,
      skippedColor: skippedColor ?? this.skippedColor,
      streakColor: streakColor ?? this.streakColor,
      backgroundColors: backgroundColors ?? this.backgroundColors,
      chartStyle: chartStyle ?? this.chartStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  /// Creates default light theme.
  factory LearningAnalyticsThemeData.light() {
    return LearningAnalyticsThemeData(
      primaryColor: const Color(0xFF2196F3),
      correctColor: const Color(0xFF4CAF50),
      incorrectColor: const Color(0xFFF44336),
      skippedColor: const Color(0xFFFF9800),
      streakColor: const Color(0xFFFF5722),
      backgroundColors: const AnalyticsBackgroundColors(
        card: Color(0xFFFFFFFF),
        surface: Color(0xFFF5F5F5),
        chart: Color(0xFFEEEEEE),
      ),
    );
  }

  /// Creates default dark theme.
  factory LearningAnalyticsThemeData.dark() {
    return LearningAnalyticsThemeData(
      primaryColor: const Color(0xFF64B5F6),
      correctColor: const Color(0xFF81C784),
      incorrectColor: const Color(0xFFE57373),
      skippedColor: const Color(0xFFFFB74D),
      streakColor: const Color(0xFFFF8A65),
      backgroundColors: const AnalyticsBackgroundColors(
        card: Color(0xFF1E1E1E),
        surface: Color(0xFF121212),
        chart: Color(0xFF2C2C2C),
      ),
    );
  }

  /// Creates a colorful theme.
  factory LearningAnalyticsThemeData.colorful() {
    return LearningAnalyticsThemeData(
      primaryColor: const Color(0xFF6200EE),
      correctColor: const Color(0xFF00C853),
      incorrectColor: const Color(0xFFFF1744),
      skippedColor: const Color(0xFFFFAB00),
      streakColor: const Color(0xFFFF6D00),
      backgroundColors: const AnalyticsBackgroundColors(
        card: Color(0xFFFFFFFF),
        surface: Color(0xFFFAFAFA),
        chart: Color(0xFFEDE7F6),
      ),
    );
  }

  /// Resolves colors with fallbacks to theme.
  _ResolvedColors resolve(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return _ResolvedColors(
      primary: primaryColor ?? colorScheme.primary,
      correct: correctColor ?? const Color(0xFF4CAF50),
      incorrect: incorrectColor ?? const Color(0xFFF44336),
      skipped: skippedColor ?? const Color(0xFFFF9800),
      streak: streakColor ?? const Color(0xFFFF5722),
      cardBackground:
          backgroundColors?.card ?? colorScheme.surface,
      surfaceBackground:
          backgroundColors?.surface ?? colorScheme.surfaceContainerLow,
      chartBackground: backgroundColors?.chart ??
          colorScheme.surfaceContainerHighest,
    );
  }
}

/// Resolved color values.
class _ResolvedColors {
  const _ResolvedColors({
    required this.primary,
    required this.correct,
    required this.incorrect,
    required this.skipped,
    required this.streak,
    required this.cardBackground,
    required this.surfaceBackground,
    required this.chartBackground,
  });

  final Color primary;
  final Color correct;
  final Color incorrect;
  final Color skipped;
  final Color streak;
  final Color cardBackground;
  final Color surfaceBackground;
  final Color chartBackground;
}

/// Background color options.
class AnalyticsBackgroundColors {
  /// Creates a new [AnalyticsBackgroundColors].
  const AnalyticsBackgroundColors({
    required this.card,
    required this.surface,
    required this.chart,
  });

  /// Card background color.
  final Color card;

  /// Surface background color.
  final Color surface;

  /// Chart background color.
  final Color chart;
}

/// Visual style options for charts.
enum ChartStyle {
  /// Rounded edges and smooth curves.
  rounded,

  /// Sharp edges and straight lines.
  sharp,

  /// Minimal styling.
  minimal,
}

/// Inherited widget for providing analytics theme to descendants.
class LearningAnalyticsTheme extends InheritedWidget {
  /// Creates a new [LearningAnalyticsTheme].
  const LearningAnalyticsTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The theme data.
  final LearningAnalyticsThemeData data;

  /// Gets the theme from context.
  static LearningAnalyticsThemeData of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<LearningAnalyticsTheme>();
    return widget?.data ?? LearningAnalyticsThemeData.light();
  }

  /// Gets the theme from context, or null if not found.
  static LearningAnalyticsThemeData? maybeOf(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<LearningAnalyticsTheme>();
    return widget?.data;
  }

  @override
  bool updateShouldNotify(LearningAnalyticsTheme oldWidget) {
    return data != oldWidget.data;
  }
}

/// Extension for easy access to analytics theme.
extension LearningAnalyticsThemeExtension on BuildContext {
  /// Gets the learning analytics theme.
  LearningAnalyticsThemeData get analyticsTheme => LearningAnalyticsTheme.of(this);

  /// Gets the resolved colors for the current theme.
  _ResolvedColors get analyticsColors {
    final theme = Theme.of(this);
    return analyticsTheme.resolve(theme);
  }
}
