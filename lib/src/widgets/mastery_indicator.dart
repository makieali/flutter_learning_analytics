import 'package:flutter/material.dart';

import '../models/mastery_level.dart';

/// A visual indicator for mastery level.
///
/// Displays the current mastery level with icon, color, and
/// optional progress bar showing progress within the level.
class MasteryIndicator extends StatelessWidget {
  /// Creates a new [MasteryIndicator].
  const MasteryIndicator({
    required this.level,
    super.key,
    this.progressInLevel,
    this.showLabel = true,
    this.showProgress = true,
    this.showIcon = true,
    this.size = MasteryIndicatorSize.medium,
    this.customColors,
  });

  /// Creates from a score (0.0 to 1.0).
  factory MasteryIndicator.fromScore(
    double score, {
    Key? key,
    bool showLabel = true,
    bool showProgress = true,
    bool showIcon = true,
    MasteryIndicatorSize size = MasteryIndicatorSize.medium,
    Map<MasteryLevel, Color>? customColors,
  }) {
    final level = MasteryLevel.fromScore(score);
    return MasteryIndicator(
      key: key,
      level: level,
      progressInLevel: level.progressInLevel(score),
      showLabel: showLabel,
      showProgress: showProgress,
      showIcon: showIcon,
      size: size,
      customColors: customColors,
    );
  }

  /// The mastery level to display.
  final MasteryLevel level;

  /// Progress within the current level (0.0 to 1.0).
  final double? progressInLevel;

  /// Whether to show the level label.
  final bool showLabel;

  /// Whether to show the progress bar.
  final bool showProgress;

  /// Whether to show the icon.
  final bool showIcon;

  /// Size variant.
  final MasteryIndicatorSize size;

  /// Custom colors for each level.
  final Map<MasteryLevel, Color>? customColors;

  @override
  Widget build(BuildContext context) {
    final color = customColors?[level] ?? level.defaultColor;
    final dimensions = _getDimensions(size);

    return Container(
      padding: dimensions.padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              level.icon,
              size: dimensions.iconSize,
              color: color,
            ),
            SizedBox(width: dimensions.spacing),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLabel)
                Text(
                  level.displayName,
                  style: TextStyle(
                    fontSize: dimensions.fontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              if (showProgress && progressInLevel != null) ...[
                SizedBox(height: dimensions.spacing / 2),
                SizedBox(
                  width: dimensions.progressWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressInLevel!,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _IndicatorDimensions _getDimensions(MasteryIndicatorSize size) {
    switch (size) {
      case MasteryIndicatorSize.small:
        return const _IndicatorDimensions(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          borderRadius: 8,
          iconSize: 16,
          fontSize: 12,
          spacing: 4,
          progressWidth: 50,
        );
      case MasteryIndicatorSize.medium:
        return const _IndicatorDimensions(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: 12,
          iconSize: 20,
          fontSize: 14,
          spacing: 8,
          progressWidth: 80,
        );
      case MasteryIndicatorSize.large:
        return const _IndicatorDimensions(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 16,
          iconSize: 28,
          fontSize: 18,
          spacing: 12,
          progressWidth: 120,
        );
    }
  }
}

/// Size variants for [MasteryIndicator].
enum MasteryIndicatorSize {
  /// Small size.
  small,

  /// Medium size (default).
  medium,

  /// Large size.
  large,
}

class _IndicatorDimensions {
  const _IndicatorDimensions({
    required this.padding,
    required this.borderRadius,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
    required this.progressWidth,
  });

  final EdgeInsets padding;
  final double borderRadius;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final double progressWidth;
}

/// A badge widget showing mastery level.
class MasteryBadge extends StatelessWidget {
  /// Creates a new [MasteryBadge].
  const MasteryBadge({
    required this.level,
    super.key,
    this.size = 40,
    this.showLabel = false,
  });

  /// Creates from a score.
  factory MasteryBadge.fromScore(double score, {Key? key, double size = 40}) {
    return MasteryBadge(
      key: key,
      level: MasteryLevel.fromScore(score),
      size: size,
    );
  }

  /// The mastery level.
  final MasteryLevel level;

  /// Badge size.
  final double size;

  /// Whether to show label below badge.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final color = level.defaultColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              level.icon,
              size: size * 0.5,
              color: Colors.white,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            level.displayName,
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}
