import 'package:flutter/material.dart';

import '../models/streak_data.dart';

/// A weekly streak grid calendar widget.
///
/// Displays the current week's activity with visual indicators
/// for completed days and the current day.
class StreakCalendar extends StatelessWidget {
  /// Creates a new [StreakCalendar].
  const StreakCalendar({
    required this.streakData,
    super.key,
    this.activeColor,
    this.inactiveColor,
    this.todayBorderColor,
    this.cellSize = 36,
    this.spacing = 8,
    this.showDayNames = true,
    this.showStreak = true,
    this.compact = false,
    this.onDayTap,
  });

  /// Streak data to display.
  final StreakData streakData;

  /// Color for active (completed) days.
  final Color? activeColor;

  /// Color for inactive days.
  final Color? inactiveColor;

  /// Border color for today's cell.
  final Color? todayBorderColor;

  /// Size of each day cell.
  final double cellSize;

  /// Spacing between cells.
  final double spacing;

  /// Whether to show day names below cells.
  final bool showDayNames;

  /// Whether to show streak counter.
  final bool showStreak;

  /// Whether to use compact layout.
  final bool compact;

  /// Callback when a day is tapped.
  final void Function(int dayOfWeek, bool hasActivity)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeCol = activeColor ?? const Color(0xFF4CAF50);
    final inactiveCol =
        inactiveColor ?? theme.colorScheme.surfaceContainerHighest;
    final todayBorderCol = todayBorderColor ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStreak && !compact) ...[
          _buildStreakHeader(theme),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final dayOfWeek = index + 1; // 1 = Monday
            final hasActivity = streakData.weeklyActivity[dayOfWeek] ?? false;
            final isToday = DateTime.now().weekday == dayOfWeek;
            final isFuture = dayOfWeek > DateTime.now().weekday;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: _DayCell(
                dayOfWeek: dayOfWeek,
                hasActivity: hasActivity,
                isToday: isToday,
                isFuture: isFuture,
                size: cellSize,
                activeColor: activeCol,
                inactiveColor: inactiveCol,
                todayBorderColor: todayBorderCol,
                showDayName: showDayNames,
                onTap: onDayTap != null
                    ? () => onDayTap!(dayOfWeek, hasActivity)
                    : null,
              ),
            );
          }),
        ),
        if (showStreak && compact) ...[
          const SizedBox(height: 8),
          _buildCompactStreak(theme),
        ],
      ],
    );
  }

  Widget _buildStreakHeader(ThemeData theme) {
    final isActive = streakData.isStreakActive;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: 28,
          color: isActive ? const Color(0xFFFF5722) : theme.colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${streakData.currentStreak} Day Streak',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive ? null : theme.colorScheme.outline,
              ),
            ),
            Text(
              isActive
                  ? streakData.hasActivityToday
                      ? 'Completed today!'
                      : 'Complete today to keep it going'
                  : 'Start a new streak today',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStreak(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: 16,
          color: streakData.isStreakActive
              ? const Color(0xFFFF5722)
              : theme.colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          '${streakData.currentStreak}',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayOfWeek,
    required this.hasActivity,
    required this.isToday,
    required this.isFuture,
    required this.size,
    required this.activeColor,
    required this.inactiveColor,
    required this.todayBorderColor,
    required this.showDayName,
    this.onTap,
  });

  final int dayOfWeek;
  final bool hasActivity;
  final bool isToday;
  final bool isFuture;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Color todayBorderColor;
  final bool showDayName;
  final VoidCallback? onTap;

  String get _dayName {
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return names[dayOfWeek - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cellColor = isFuture
        ? inactiveColor.withOpacity(0.3)
        : hasActivity
            ? activeColor
            : inactiveColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 4),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(size / 4),
              border: isToday
                  ? Border.all(
                      color: todayBorderColor,
                      width: 2,
                    )
                  : null,
              boxShadow: hasActivity && !isFuture
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: hasActivity && !isFuture
                  ? Icon(
                      Icons.check,
                      size: size * 0.5,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
        if (showDayName) ...[
          const SizedBox(height: 4),
          Text(
            _dayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }
}

/// A compact streak indicator widget.
///
/// Shows the current streak with a fire icon.
class StreakIndicator extends StatelessWidget {
  /// Creates a new [StreakIndicator].
  const StreakIndicator({
    required this.currentStreak,
    super.key,
    this.isActive = true,
    this.size = 24,
    this.showLabel = true,
  });

  /// Current streak count.
  final int currentStreak;

  /// Whether the streak is currently active.
  final bool isActive;

  /// Size of the indicator.
  final double size;

  /// Whether to show the "day streak" label.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? const Color(0xFFFF5722) : theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: size,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          currentStreak.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            currentStreak == 1 ? 'day' : 'days',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
