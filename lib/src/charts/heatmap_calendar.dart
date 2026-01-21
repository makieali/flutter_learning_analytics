import 'package:flutter/material.dart';

/// Color schemes for the heatmap calendar.
enum HeatmapColorScheme {
  /// Green color scheme (GitHub-style).
  green,

  /// Blue color scheme.
  blue,

  /// Purple color scheme.
  purple,

  /// Orange color scheme.
  orange,
}

/// A GitHub-style activity heatmap calendar.
///
/// Displays activity data over time with color intensity based on
/// activity count for each day.
class HeatmapCalendar extends StatelessWidget {
  /// Creates a new [HeatmapCalendar].
  const HeatmapCalendar({
    required this.data,
    super.key,
    this.startDate,
    this.endDate,
    this.colorScheme = HeatmapColorScheme.green,
    this.customColors,
    this.cellSize = 12,
    this.cellSpacing = 2,
    this.cellBorderRadius = 2,
    this.showDayLabels = true,
    this.showMonthLabels = true,
    this.showLegend = true,
    this.scrollable = true,
    this.onDayTap,
  });

  /// Map of dates to activity counts.
  final Map<DateTime, int> data;

  /// Start date for the calendar (defaults to 1 year ago).
  final DateTime? startDate;

  /// End date for the calendar (defaults to today).
  final DateTime? endDate;

  /// Color scheme to use.
  final HeatmapColorScheme colorScheme;

  /// Custom colors for intensity levels (overrides colorScheme).
  /// Should contain 5 colors: [empty, level1, level2, level3, level4]
  final List<Color>? customColors;

  /// Size of each cell.
  final double cellSize;

  /// Spacing between cells.
  final double cellSpacing;

  /// Border radius for cells.
  final double cellBorderRadius;

  /// Whether to show day labels (M, W, F).
  final bool showDayLabels;

  /// Whether to show month labels.
  final bool showMonthLabels;

  /// Whether to show the legend.
  final bool showLegend;

  /// Whether the calendar is horizontally scrollable.
  final bool scrollable;

  /// Callback when a day is tapped.
  final void Function(DateTime date, int count)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);

    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 365));

    // Normalize dates
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    final normalizedStart = DateTime(start.year, start.month, start.day);

    // Normalize data keys
    final normalizedData = <DateTime, int>{};
    for (final entry in data.entries) {
      final normalizedDate = DateTime(
        entry.key.year,
        entry.key.month,
        entry.key.day,
      );
      normalizedData[normalizedDate] = entry.value;
    }

    // Build weeks
    final weeks = _buildWeeks(normalizedStart, normalizedEnd, normalizedData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMonthLabels) _buildMonthLabels(theme, normalizedStart, weeks),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDayLabels) _buildDayLabels(theme),
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: _buildGrid(weeks, colors, theme),
                    )
                  : _buildGrid(weeks, colors, theme),
            ),
          ],
        ),
        if (showLegend) ...[
          const SizedBox(height: 12),
          _buildLegend(colors, theme),
        ],
      ],
    );
  }

  List<Color> _getColors(ThemeData theme) {
    if (customColors != null && customColors!.length >= 5) {
      return customColors!;
    }

    final emptyColor = theme.colorScheme.surfaceContainerHighest;

    switch (colorScheme) {
      case HeatmapColorScheme.green:
        return [
          emptyColor,
          const Color(0xFF9BE9A8),
          const Color(0xFF40C463),
          const Color(0xFF30A14E),
          const Color(0xFF216E39),
        ];
      case HeatmapColorScheme.blue:
        return [
          emptyColor,
          const Color(0xFFBBDEFB),
          const Color(0xFF64B5F6),
          const Color(0xFF2196F3),
          const Color(0xFF1565C0),
        ];
      case HeatmapColorScheme.purple:
        return [
          emptyColor,
          const Color(0xFFE1BEE7),
          const Color(0xFFBA68C8),
          const Color(0xFF9C27B0),
          const Color(0xFF6A1B9A),
        ];
      case HeatmapColorScheme.orange:
        return [
          emptyColor,
          const Color(0xFFFFE0B2),
          const Color(0xFFFFB74D),
          const Color(0xFFFF9800),
          const Color(0xFFE65100),
        ];
    }
  }

  List<List<_DayData>> _buildWeeks(
    DateTime start,
    DateTime end,
    Map<DateTime, int> normalizedData,
  ) {
    final weeks = <List<_DayData>>[];
    var currentWeek = <_DayData>[];

    // Start from the beginning of the week containing start date
    var current = start.subtract(Duration(days: start.weekday % 7));

    while (!current.isAfter(end)) {
      final count = normalizedData[current] ?? 0;
      final isInRange = !current.isBefore(start) && !current.isAfter(end);

      currentWeek.add(_DayData(
        date: current,
        count: count,
        level: _getLevel(count),
        isInRange: isInRange,
      ));

      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }

      current = current.add(const Duration(days: 1));
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return weeks;
  }

  int _getLevel(int count) {
    if (count == 0) return 0;
    if (count <= 2) return 1;
    if (count <= 5) return 2;
    if (count <= 10) return 3;
    return 4;
  }

  Widget _buildMonthLabels(
    ThemeData theme,
    DateTime start,
    List<List<_DayData>> weeks,
  ) {
    final months = <_MonthLabel>[];
    String? currentMonth;

    for (int i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      // Use the first day of the week for month determination
      final firstDay = week.first.date;
      final monthStr = _getMonthAbbr(firstDay.month);

      if (monthStr != currentMonth) {
        months.add(_MonthLabel(
          month: monthStr,
          weekIndex: i,
        ));
        currentMonth = monthStr;
      }
    }

    final labelWidth = cellSize + cellSpacing;

    return Padding(
      padding: EdgeInsets.only(
        left: showDayLabels ? 28 : 0,
        bottom: 4,
      ),
      child: SizedBox(
        height: 16,
        child: scrollable
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: _buildMonthLabelRow(months, labelWidth, weeks.length, theme),
              )
            : _buildMonthLabelRow(months, labelWidth, weeks.length, theme),
      ),
    );
  }

  Widget _buildMonthLabelRow(
    List<_MonthLabel> months,
    double labelWidth,
    int totalWeeks,
    ThemeData theme,
  ) {
    return SizedBox(
      width: totalWeeks * labelWidth,
      child: Stack(
        children: months.map((label) {
          return Positioned(
            left: label.weekIndex * labelWidth,
            child: Text(
              label.month,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayLabels(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: cellSize + cellSpacing), // Mon
          Text('M', style: _dayLabelStyle(theme)),
          SizedBox(height: cellSize + cellSpacing), // Tue
          SizedBox(height: cellSize + cellSpacing), // Wed
          Text('W', style: _dayLabelStyle(theme)),
          SizedBox(height: cellSize + cellSpacing), // Thu
          SizedBox(height: cellSize + cellSpacing), // Fri
          Text('F', style: _dayLabelStyle(theme)),
          SizedBox(height: cellSize + cellSpacing), // Sat (if visible)
        ],
      ),
    );
  }

  TextStyle? _dayLabelStyle(ThemeData theme) {
    return theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.outline,
      height: 1,
    );
  }

  Widget _buildGrid(
    List<List<_DayData>> weeks,
    List<Color> colors,
    ThemeData theme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks.map((week) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: week.map((day) {
            return Padding(
              padding: EdgeInsets.all(cellSpacing / 2),
              child: _buildCell(day, colors, theme),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildCell(_DayData day, List<Color> colors, ThemeData theme) {
    final color = day.isInRange ? colors[day.level] : Colors.transparent;

    return Tooltip(
      message: day.isInRange
          ? '${_formatDate(day.date)}: ${day.count} activities'
          : '',
      child: InkWell(
        onTap: day.isInRange && onDayTap != null
            ? () => onDayTap!(day.date, day.count)
            : null,
        borderRadius: BorderRadius.circular(cellBorderRadius),
        child: Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(cellBorderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(List<Color> colors, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Less',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(width: 4),
        ...colors.map((color) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(cellBorderRadius),
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          'More',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${_getMonthAbbr(date.month)} ${date.day}, ${date.year}';
  }
}

class _DayData {
  const _DayData({
    required this.date,
    required this.count,
    required this.level,
    required this.isInRange,
  });

  final DateTime date;
  final int count;
  final int level;
  final bool isInRange;
}

class _MonthLabel {
  const _MonthLabel({
    required this.month,
    required this.weekIndex,
  });

  final String month;
  final int weekIndex;
}
