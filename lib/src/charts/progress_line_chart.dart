import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/progress_point.dart';

/// A line chart for visualizing progress over time.
///
/// Displays progress data points with date-based X axis and
/// customizable styling options.
class ProgressLineChart extends StatefulWidget {
  /// Creates a new [ProgressLineChart].
  const ProgressLineChart({
    required this.data,
    super.key,
    this.title,
    this.maxValue = 100,
    this.minValue = 0,
    this.showDots = true,
    this.showGrid = true,
    this.showTarget = false,
    this.targetValue,
    this.animate = true,
    this.lineColor,
    this.targetColor,
    this.fillGradient = true,
    this.curved = true,
    this.dateFormat,
    this.onPointTap,
  });

  /// Progress data points to display.
  final List<ProgressPoint> data;

  /// Optional chart title.
  final String? title;

  /// Maximum value for Y axis.
  final double maxValue;

  /// Minimum value for Y axis.
  final double minValue;

  /// Whether to show dots at data points.
  final bool showDots;

  /// Whether to show grid lines.
  final bool showGrid;

  /// Whether to show the target line.
  final bool showTarget;

  /// Target value for the horizontal line.
  final double? targetValue;

  /// Whether to animate the chart.
  final bool animate;

  /// Color for the main line.
  final Color? lineColor;

  /// Color for the target line.
  final Color? targetColor;

  /// Whether to fill below the line with a gradient.
  final bool fillGradient;

  /// Whether to use curved lines.
  final bool curved;

  /// Custom date format string.
  final String? dateFormat;

  /// Callback when a data point is tapped.
  final void Function(ProgressPoint point)? onPointTap;

  @override
  State<ProgressLineChart> createState() => _ProgressLineChartState();
}

class _ProgressLineChartState extends State<ProgressLineChart> {
  int _touchedIndex = -1;

  List<ProgressPoint> get _sortedData {
    final sorted = List<ProgressPoint>.from(widget.data)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.data.isEmpty) {
      return _buildEmptyState(theme);
    }

    final lineColor = widget.lineColor ?? theme.colorScheme.primary;
    final targetColor = widget.targetColor ?? theme.colorScheme.tertiary;
    final dateFormatter = DateFormat(widget.dateFormat ?? 'MMM d');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.lineBarSpots == null ||
                        response.lineBarSpots!.isEmpty) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.lineBarSpots!.first.spotIndex;

                    if (event is FlTapUpEvent && widget.onPointTap != null) {
                      if (_touchedIndex >= 0 &&
                          _touchedIndex < _sortedData.length) {
                        widget.onPointTap!(_sortedData[_touchedIndex]);
                      }
                    }
                  });
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final point = _sortedData[spot.spotIndex];
                      final dateStr = dateFormatter.format(point.date);
                      final valueStr = point.value.toStringAsFixed(1);
                      final label = point.label ?? '';

                      return LineTooltipItem(
                        '$dateStr\n$valueStr%${label.isNotEmpty ? '\n$label' : ''}',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: widget.showGrid,
                horizontalInterval: (widget.maxValue - widget.minValue) / 4,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: _calculateXInterval(),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= _sortedData.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          dateFormatter.format(_sortedData[index].date),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: (widget.maxValue - widget.minValue) / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (_sortedData.length - 1).toDouble(),
              minY: widget.minValue,
              maxY: widget.maxValue,
              extraLinesData: widget.showTarget && widget.targetValue != null
                  ? ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: widget.targetValue!,
                          color: targetColor,
                          strokeWidth: 2,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            labelResolver: (_) =>
                                'Target: ${widget.targetValue!.toInt()}%',
                            style: TextStyle(
                              color: targetColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
              lineBarsData: [
                LineChartBarData(
                  spots: _sortedData.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.value,
                    );
                  }).toList(),
                  isCurved: widget.curved,
                  curveSmoothness: 0.3,
                  color: lineColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: widget.showDots,
                    getDotPainter: (spot, percent, bar, index) {
                      final isTouched = index == _touchedIndex;
                      return FlDotCirclePainter(
                        radius: isTouched ? 6 : 4,
                        color: lineColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: widget.fillGradient
                      ? BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              lineColor.withOpacity(0.3),
                              lineColor.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            duration: widget.animate
                ? const Duration(milliseconds: 800)
                : Duration.zero,
            curve: Curves.easeOutCubic,
          ),
        ),
        if (_sortedData.length >= 2) ...[
          const SizedBox(height: 16),
          _buildTrendIndicator(theme),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No progress data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(ThemeData theme) {
    final firstValue = _sortedData.first.value;
    final lastValue = _sortedData.last.value;
    final change = lastValue - firstValue;
    final isPositive = change > 0;
    final isNeutral = change.abs() < 0.5;

    final color = isNeutral
        ? theme.colorScheme.outline
        : isPositive
            ? const Color(0xFF4CAF50)
            : const Color(0xFFF44336);

    final icon = isNeutral
        ? Icons.remove
        : isPositive
            ? Icons.trending_up
            : Icons.trending_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(
          isNeutral
              ? 'Stable'
              : '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'over ${_calculateDateRange()}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  double _calculateXInterval() {
    final length = _sortedData.length;
    if (length <= 5) return 1;
    if (length <= 10) return 2;
    if (length <= 20) return 5;
    return (length / 5).ceil().toDouble();
  }

  String _calculateDateRange() {
    if (_sortedData.length < 2) return '';

    final first = _sortedData.first.date;
    final last = _sortedData.last.date;
    final days = last.difference(first).inDays;

    if (days < 7) return '$days days';
    if (days < 30) return '${(days / 7).ceil()} weeks';
    if (days < 365) return '${(days / 30).ceil()} months';
    return '${(days / 365).toStringAsFixed(1)} years';
  }
}
