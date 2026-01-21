import 'package:flutter/material.dart';

/// A card widget for displaying scores with letter grades.
///
/// Shows a prominent score value with an optional letter grade,
/// label, and visual styling based on performance.
class ScoreCard extends StatelessWidget {
  /// Creates a new [ScoreCard].
  const ScoreCard({
    required this.score,
    super.key,
    this.maxScore = 100,
    this.label,
    this.showGrade = true,
    this.showPercentage = true,
    this.gradeThresholds,
    this.size = ScoreCardSize.medium,
    this.style,
  });

  /// The score value (0 to maxScore).
  final double score;

  /// Maximum possible score.
  final double maxScore;

  /// Optional label to display below the score.
  final String? label;

  /// Whether to show the letter grade.
  final bool showGrade;

  /// Whether to show the percentage.
  final bool showPercentage;

  /// Custom grade thresholds.
  /// Key: minimum percentage (0-100), Value: (grade letter, color)
  final Map<double, (String, Color)>? gradeThresholds;

  /// Size variant of the card.
  final ScoreCardSize size;

  /// Optional custom style.
  final ScoreCardStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (score / maxScore).clamp(0.0, 1.0) * 100;
    final gradeInfo = _getGradeInfo(percentage, theme);

    final cardStyle = style ?? ScoreCardStyle.fromTheme(theme);
    final dimensions = _getDimensions(size);

    return Container(
      width: dimensions.width,
      padding: dimensions.padding,
      decoration: BoxDecoration(
        color: cardStyle.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        border: Border.all(
          color: gradeInfo.color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: gradeInfo.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGrade) ...[
            Container(
              width: dimensions.gradeSize,
              height: dimensions.gradeSize,
              decoration: BoxDecoration(
                color: gradeInfo.color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  gradeInfo.grade,
                  style: TextStyle(
                    fontSize: dimensions.gradeFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: dimensions.spacing),
          ],
          if (showPercentage)
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: dimensions.scoreFontSize,
                fontWeight: FontWeight.bold,
                color: gradeInfo.color,
              ),
            ),
          if (!showPercentage)
            Text(
              '${score.toStringAsFixed(0)}/${maxScore.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: dimensions.scoreFontSize,
                fontWeight: FontWeight.bold,
                color: gradeInfo.color,
              ),
            ),
          if (label != null) ...[
            SizedBox(height: dimensions.spacing / 2),
            Text(
              label!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  _GradeInfo _getGradeInfo(double percentage, ThemeData theme) {
    if (gradeThresholds != null) {
      final sortedThresholds = gradeThresholds!.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));

      for (final threshold in sortedThresholds) {
        if (percentage >= threshold.key) {
          return _GradeInfo(
            grade: threshold.value.$1,
            color: threshold.value.$2,
          );
        }
      }
    }

    // Default grade thresholds
    if (percentage >= 90) {
      return const _GradeInfo(grade: 'A', color: Color(0xFF4CAF50));
    } else if (percentage >= 80) {
      return const _GradeInfo(grade: 'B', color: Color(0xFF8BC34A));
    } else if (percentage >= 70) {
      return const _GradeInfo(grade: 'C', color: Color(0xFFFFC107));
    } else if (percentage >= 60) {
      return const _GradeInfo(grade: 'D', color: Color(0xFFFF9800));
    } else {
      return const _GradeInfo(grade: 'F', color: Color(0xFFF44336));
    }
  }

  _CardDimensions _getDimensions(ScoreCardSize size) {
    switch (size) {
      case ScoreCardSize.small:
        return const _CardDimensions(
          width: 80,
          padding: EdgeInsets.all(12),
          borderRadius: 12,
          gradeSize: 32,
          gradeFontSize: 16,
          scoreFontSize: 18,
          spacing: 8,
        );
      case ScoreCardSize.medium:
        return const _CardDimensions(
          width: 120,
          padding: EdgeInsets.all(16),
          borderRadius: 16,
          gradeSize: 48,
          gradeFontSize: 24,
          scoreFontSize: 24,
          spacing: 12,
        );
      case ScoreCardSize.large:
        return const _CardDimensions(
          width: 160,
          padding: EdgeInsets.all(20),
          borderRadius: 20,
          gradeSize: 64,
          gradeFontSize: 32,
          scoreFontSize: 32,
          spacing: 16,
        );
    }
  }
}

/// Size variants for [ScoreCard].
enum ScoreCardSize {
  /// Small size.
  small,

  /// Medium size (default).
  medium,

  /// Large size.
  large,
}

/// Custom style for [ScoreCard].
class ScoreCardStyle {
  /// Creates a new [ScoreCardStyle].
  const ScoreCardStyle({
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  /// Creates a style from the theme.
  factory ScoreCardStyle.fromTheme(ThemeData theme) {
    return ScoreCardStyle(
      backgroundColor: theme.colorScheme.surface,
      textColor: theme.colorScheme.onSurface,
    );
  }

  /// Background color.
  final Color? backgroundColor;

  /// Text color.
  final Color? textColor;

  /// Border color.
  final Color? borderColor;
}

class _GradeInfo {
  const _GradeInfo({required this.grade, required this.color});

  final String grade;
  final Color color;
}

class _CardDimensions {
  const _CardDimensions({
    required this.width,
    required this.padding,
    required this.borderRadius,
    required this.gradeSize,
    required this.gradeFontSize,
    required this.scoreFontSize,
    required this.spacing,
  });

  final double width;
  final EdgeInsets padding;
  final double borderRadius;
  final double gradeSize;
  final double gradeFontSize;
  final double scoreFontSize;
  final double spacing;
}
