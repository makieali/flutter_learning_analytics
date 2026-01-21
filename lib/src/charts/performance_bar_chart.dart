import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A horizontal bar chart for comparing performance across topics/subjects.
///
/// Each bar represents performance in a specific topic, with optional
/// target lines and color coding based on performance levels.
class PerformanceBarChart extends StatefulWidget {
  /// Creates a new [PerformanceBarChart].
  const PerformanceBarChart({
    required this.data,
    super.key,
    this.maxValue = 100,
    this.targetValue,
    this.showValues = true,
    this.showTarget = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.barHeight = 24,
    this.spacing = 12,
    this.borderRadius = 6,
    this.colorThresholds,
    this.defaultBarColor,
    this.targetColor,
    this.backgroundColor,
    this.onBarTap,
  });

  /// Map of topic names to performance values.
  final Map<String, double> data;

  /// Maximum value for the scale.
  final double maxValue;

  /// Optional target value to display as a reference line.
  final double? targetValue;

  /// Whether to show value labels on bars.
  final bool showValues;

  /// Whether to show the target line.
  final bool showTarget;

  /// Whether to animate the chart.
  final bool animate;

  /// Animation duration.
  final Duration animationDuration;

  /// Height of each bar.
  final double barHeight;

  /// Spacing between bars.
  final double spacing;

  /// Border radius for bars.
  final double borderRadius;

  /// Color thresholds for dynamic coloring.
  /// Map of threshold value to color (e.g., {0.6: red, 0.8: yellow, 1.0: green})
  final Map<double, Color>? colorThresholds;

  /// Default bar color when not using thresholds.
  final Color? defaultBarColor;

  /// Color for the target line.
  final Color? targetColor;

  /// Background color for the bar track.
  final Color? backgroundColor;

  /// Callback when a bar is tapped.
  final void Function(String topic, double value)? onBarTap;

  @override
  State<PerformanceBarChart> createState() => _PerformanceBarChartState();
}

class _PerformanceBarChartState extends State<PerformanceBarChart> {
  int _touchedIndex = -1;

  List<MapEntry<String, double>> get _sortedData {
    final entries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.data.isEmpty) {
      return _buildEmptyState(theme);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _sortedData.length; i++) ...[
              _buildBar(
                index: i,
                entry: _sortedData[i],
                theme: theme,
                maxWidth: chartWidth,
              ),
              if (i < _sortedData.length - 1) SizedBox(height: widget.spacing),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar({
    required int index,
    required MapEntry<String, double> entry,
    required ThemeData theme,
    required double maxWidth,
  }) {
    final isTouched = index == _touchedIndex;
    final percentage = (entry.value / widget.maxValue).clamp(0.0, 1.0);
    final color = _getColorForValue(entry.value / widget.maxValue, theme);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTapDown: (_) => setState(() => _touchedIndex = index),
      onTapUp: (_) {
        widget.onBarTap?.call(entry.key, entry.value);
        setState(() => _touchedIndex = -1);
      },
      onTapCancel: () => setState(() => _touchedIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(isTouched ? 1.02 : 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.showValues)
                  Text(
                    '${entry.value.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Stack(
              children: [
                // Background track
                Container(
                  height: widget.barHeight,
                  width: maxWidth,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                ),
                // Value bar
                AnimatedContainer(
                  duration: widget.animate
                      ? widget.animationDuration
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
                  height: widget.barHeight,
                  width: maxWidth * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: isTouched
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
                // Target line
                if (widget.showTarget && widget.targetValue != null)
                  Positioned(
                    left: maxWidth * (widget.targetValue! / widget.maxValue) - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: widget.targetColor ?? theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForValue(double normalizedValue, ThemeData theme) {
    if (widget.colorThresholds != null) {
      final sortedThresholds = widget.colorThresholds!.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      for (final threshold in sortedThresholds) {
        if (normalizedValue <= threshold.key) {
          return threshold.value;
        }
      }
      return sortedThresholds.last.value;
    }

    if (widget.defaultBarColor != null) {
      return widget.defaultBarColor!;
    }

    // Default color scheme based on performance
    if (normalizedValue >= 0.8) {
      return const Color(0xFF4CAF50); // Green
    } else if (normalizedValue >= 0.6) {
      return const Color(0xFFFFC107); // Amber
    } else if (normalizedValue >= 0.4) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }
}

/// Vertical bar chart variant using fl_chart.
class PerformanceBarChartVertical extends StatefulWidget {
  /// Creates a new [PerformanceBarChartVertical].
  const PerformanceBarChartVertical({
    required this.data,
    super.key,
    this.maxValue = 100,
    this.targetValue,
    this.showValues = true,
    this.animate = true,
    this.barWidth = 20,
    this.groupSpacing = 12,
    this.defaultBarColor,
    this.colorThresholds,
    this.onBarTap,
  });

  /// Map of topic names to performance values.
  final Map<String, double> data;

  /// Maximum value for the Y axis.
  final double maxValue;

  /// Optional target value to display as a horizontal line.
  final double? targetValue;

  /// Whether to show value labels on bars.
  final bool showValues;

  /// Whether to animate the chart.
  final bool animate;

  /// Width of each bar.
  final double barWidth;

  /// Spacing between bar groups.
  final double groupSpacing;

  /// Default bar color.
  final Color? defaultBarColor;

  /// Color thresholds for dynamic coloring.
  final Map<double, Color>? colorThresholds;

  /// Callback when a bar is tapped.
  final void Function(String topic, double value)? onBarTap;

  @override
  State<PerformanceBarChartVertical> createState() =>
      _PerformanceBarChartVerticalState();
}

class _PerformanceBarChartVerticalState
    extends State<PerformanceBarChartVertical> {
  int _touchedIndex = -1;

  List<MapEntry<String, double>> get _entries => widget.data.entries.toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.spot == null) {
                  _touchedIndex = -1;
                  return;
                }
                _touchedIndex = response.spot!.touchedBarGroupIndex;

                if (event is FlTapUpEvent && widget.onBarTap != null) {
                  if (_touchedIndex >= 0 && _touchedIndex < _entries.length) {
                    final entry = _entries[_touchedIndex];
                    widget.onBarTap!(entry.key, entry.value);
                  }
                }
              });
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.inverseSurface,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entry = _entries[groupIndex];
                return BarTooltipItem(
                  '${entry.key}\n${entry.value.toStringAsFixed(1)}%',
                  TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < _entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _truncateLabel(_entries[index].key),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: widget.maxValue / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
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
          gridData: FlGridData(
            show: true,
            horizontalInterval: widget.maxValue / 4,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          extraLinesData: widget.targetValue != null
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: widget.targetValue!,
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (_) => 'Target',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          maxY: widget.maxValue,
          barGroups: _buildBarGroups(theme),
        ),
        swapAnimationDuration:
            widget.animate ? const Duration(milliseconds: 800) : Duration.zero,
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(ThemeData theme) {
    return _entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;
      final color = _getColorForValue(data.value / widget.maxValue, theme);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value,
            color: color,
            width: widget.barWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: widget.maxValue,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  Color _getColorForValue(double normalizedValue, ThemeData theme) {
    if (widget.colorThresholds != null) {
      final sortedThresholds = widget.colorThresholds!.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      for (final threshold in sortedThresholds) {
        if (normalizedValue <= threshold.key) {
          return threshold.value;
        }
      }
      return sortedThresholds.last.value;
    }

    if (widget.defaultBarColor != null) {
      return widget.defaultBarColor!;
    }

    if (normalizedValue >= 0.8) {
      return const Color(0xFF4CAF50);
    } else if (normalizedValue >= 0.6) {
      return const Color(0xFFFFC107);
    } else if (normalizedValue >= 0.4) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFFF44336);
    }
  }

  String _truncateLabel(String label) {
    if (label.length <= 8) return label;
    return '${label.substring(0, 6)}...';
  }
}
