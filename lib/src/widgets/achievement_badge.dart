import 'package:flutter/material.dart';

/// Types of achievements.
enum AchievementType {
  /// Streak-related achievement.
  streak,

  /// Accuracy-related achievement.
  accuracy,

  /// Completion-related achievement.
  completion,

  /// Time-related achievement.
  speed,

  /// Milestone achievement.
  milestone,

  /// Special achievement.
  special,
}

/// A badge widget for displaying achievements.
class AchievementBadge extends StatelessWidget {
  /// Creates a new [AchievementBadge].
  const AchievementBadge({
    required this.title,
    super.key,
    this.description,
    this.type = AchievementType.special,
    this.isUnlocked = true,
    this.progress,
    this.icon,
    this.customColor,
    this.size = AchievementBadgeSize.medium,
    this.showProgress = true,
    this.onTap,
  });

  /// Achievement title.
  final String title;

  /// Optional description.
  final String? description;

  /// Type of achievement.
  final AchievementType type;

  /// Whether the achievement is unlocked.
  final bool isUnlocked;

  /// Progress toward unlocking (0.0 to 1.0).
  final double? progress;

  /// Custom icon (overrides type icon).
  final IconData? icon;

  /// Custom color (overrides type color).
  final Color? customColor;

  /// Size variant.
  final AchievementBadgeSize size;

  /// Whether to show progress indicator.
  final bool showProgress;

  /// Tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = customColor ?? _getTypeColor(type);
    final badgeIcon = icon ?? _getTypeIcon(type);
    final dimensions = _getDimensions(size);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(dimensions.borderRadius),
      child: Container(
        width: dimensions.width,
        padding: dimensions.padding,
        decoration: BoxDecoration(
          color: isUnlocked
              ? color.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          border: Border.all(
            color: isUnlocked ? color.withOpacity(0.3) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: dimensions.iconContainerSize,
                  height: dimensions.iconContainerSize,
                  decoration: BoxDecoration(
                    color: isUnlocked ? color : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      badgeIcon,
                      size: dimensions.iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!isUnlocked && showProgress && progress != null)
                  SizedBox(
                    width: dimensions.iconContainerSize + 8,
                    height: dimensions.iconContainerSize + 8,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                if (!isUnlocked && progress == null)
                  Container(
                    width: dimensions.iconContainerSize,
                    height: dimensions.iconContainerSize,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        size: dimensions.iconSize * 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: dimensions.spacing),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: dimensions.titleFontSize,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? null : theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Description
            if (description != null && size != AchievementBadgeSize.small) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Progress text
            if (!isUnlocked && showProgress && progress != null) ...[
              const SizedBox(height: 4),
              Text(
                '${(progress! * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return const Color(0xFFFF5722);
      case AchievementType.accuracy:
        return const Color(0xFF4CAF50);
      case AchievementType.completion:
        return const Color(0xFF2196F3);
      case AchievementType.speed:
        return const Color(0xFF9C27B0);
      case AchievementType.milestone:
        return const Color(0xFFFFC107);
      case AchievementType.special:
        return const Color(0xFFE91E63);
    }
  }

  IconData _getTypeIcon(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.accuracy:
        return Icons.check_circle;
      case AchievementType.completion:
        return Icons.flag;
      case AchievementType.speed:
        return Icons.speed;
      case AchievementType.milestone:
        return Icons.star;
      case AchievementType.special:
        return Icons.emoji_events;
    }
  }

  _BadgeDimensions _getDimensions(AchievementBadgeSize size) {
    switch (size) {
      case AchievementBadgeSize.small:
        return const _BadgeDimensions(
          width: 80,
          padding: EdgeInsets.all(8),
          borderRadius: 12,
          iconContainerSize: 40,
          iconSize: 20,
          titleFontSize: 11,
          spacing: 6,
        );
      case AchievementBadgeSize.medium:
        return const _BadgeDimensions(
          width: 120,
          padding: EdgeInsets.all(12),
          borderRadius: 16,
          iconContainerSize: 56,
          iconSize: 28,
          titleFontSize: 13,
          spacing: 8,
        );
      case AchievementBadgeSize.large:
        return const _BadgeDimensions(
          width: 160,
          padding: EdgeInsets.all(16),
          borderRadius: 20,
          iconContainerSize: 72,
          iconSize: 36,
          titleFontSize: 15,
          spacing: 12,
        );
    }
  }
}

/// Size variants for [AchievementBadge].
enum AchievementBadgeSize {
  /// Small size.
  small,

  /// Medium size (default).
  medium,

  /// Large size.
  large,
}

class _BadgeDimensions {
  const _BadgeDimensions({
    required this.width,
    required this.padding,
    required this.borderRadius,
    required this.iconContainerSize,
    required this.iconSize,
    required this.titleFontSize,
    required this.spacing,
  });

  final double width;
  final EdgeInsets padding;
  final double borderRadius;
  final double iconContainerSize;
  final double iconSize;
  final double titleFontSize;
  final double spacing;
}

/// A grid of achievement badges.
class AchievementGrid extends StatelessWidget {
  /// Creates a new [AchievementGrid].
  const AchievementGrid({
    required this.achievements,
    super.key,
    this.crossAxisCount = 3,
    this.spacing = 12,
    this.badgeSize = AchievementBadgeSize.medium,
    this.onAchievementTap,
  });

  /// List of achievement data.
  final List<AchievementData> achievements;

  /// Number of columns.
  final int crossAxisCount;

  /// Spacing between items.
  final double spacing;

  /// Badge size.
  final AchievementBadgeSize badgeSize;

  /// Callback when an achievement is tapped.
  final void Function(AchievementData)? onAchievementTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: achievements.map((achievement) {
        return AchievementBadge(
          title: achievement.title,
          description: achievement.description,
          type: achievement.type,
          isUnlocked: achievement.isUnlocked,
          progress: achievement.progress,
          icon: achievement.icon,
          customColor: achievement.color,
          size: badgeSize,
          onTap: onAchievementTap != null
              ? () => onAchievementTap!(achievement)
              : null,
        );
      }).toList(),
    );
  }
}

/// Data for an achievement.
class AchievementData {
  /// Creates a new [AchievementData].
  const AchievementData({
    required this.id,
    required this.title,
    this.description,
    this.type = AchievementType.special,
    this.isUnlocked = false,
    this.progress,
    this.icon,
    this.color,
  });

  /// Unique identifier.
  final String id;

  /// Title.
  final String title;

  /// Description.
  final String? description;

  /// Type.
  final AchievementType type;

  /// Whether unlocked.
  final bool isUnlocked;

  /// Progress (0.0 to 1.0).
  final double? progress;

  /// Custom icon.
  final IconData? icon;

  /// Custom color.
  final Color? color;
}
