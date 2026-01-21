import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A line chart for visualizing time spent per question or session.
///
/// Displays time data as a line chart with optional threshold indicators
/// and interactive touch features.
class TimeLineChart extends StatefulWidget {
  /// Creates a new [TimeLineChart].
  const TimeLineChart({
    required this.times,
    super.key,
    this.labels,
    this.threshold,
    this.showThreshold = true,
    this.showAverage = true,
    this.showDots = true,
    this.animate = true,
    this.lineColor,
    this.thresholdColor,
    this.averageColor,
    this.fillGradient = true,
    this.onPointTap,
  });

  /// List of time durations to display.
  final List<Duration> times;

  /// Optional labels for each data point.
  final List<String>? labels;

  /// Threshold duration for reference.
  final Duration? threshold;

  /// Whether to show the threshold line.
  final bool showThreshold;

  /// Whether to show the average line.
  final bool showAverage;

  /// Whether to show dots at data points.
  final bool showDots;

  /// Whether to animate the chart.
  final bool animate;

  /// Color for the main line.
  final Color? lineColor;

  /// Color for the threshold line.
  final Color? thresholdColor;

  /// Color for the average line.
  final Color? averageColor;

  /// Whether to fill below the line with a gradient.
  final bool fillGradient;

  /// Callback when a data point is tapped.
  final void Function(int index, Duration time)? onPointTap;

  @override
  State<TimeLineChart> createState() => _TimeLineChartState();
}

class _TimeLineChartState extends State<TimeLineChart> {
  int _touchedIndex = -1;

  double get _maxSeconds {
    if (widget.times.isEmpty) return 60;
    final maxTime = widget.times
        .map((t) => t.inSeconds.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final thresholdSeconds = widget.threshold?.inSeconds.toDouble() ?? 0;
    return (maxTime > thresholdSeconds ? maxTime : thresholdSeconds) * 1.2;
  }

  double get _averageSeconds {
    if (widget.times.isEmpty) return 0;
    final total = widget.times.fold<int>(0, (sum, t) => sum + t.inSeconds);
    return total / widget.times.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.times.isEmpty) {
      return _buildEmptyState(theme);
    }

    final lineColor = widget.lineColor ?? theme.colorScheme.primary;
    final thresholdColor =
        widget.thresholdColor ?? const Color(0xFFF44336); // Red
    final averageColor = widget.averageColor ?? const Color(0xFF4CAF50); // Green

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                          _touchedIndex < widget.times.length) {
                        widget.onPointTap!(
                          _touchedIndex,
                          widget.times[_touchedIndex],
                        );
                      }
                    }
                  });
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final seconds = spot.y.toInt();
                      final label = widget.labels != null &&
                              spot.spotIndex < widget.labels!.length
                          ? '${widget.labels![spot.spotIndex]}\n'
                          : 'Q${spot.spotIndex + 1}\n';
                      return LineTooltipItem(
                        '$label${_formatDuration(Duration(seconds: seconds))}',
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
                show: true,
                horizontalInterval: _maxSeconds / 4,
                verticalInterval: widget.times.length > 10
                    ? (widget.times.length / 5).ceil().toDouble()
                    : 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: widget.times.length > 10
                        ? (widget.times.length / 5).ceil().toDouble()
                        : 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= widget.times.length) {
                        return const SizedBox.shrink();
                      }
                      final label = widget.labels != null &&
                              index < widget.labels!.length
                          ? widget.labels![index]
                          : 'Q${index + 1}';
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label.length > 5 ? '${label.substring(0, 4)}...' : label,
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    interval: _maxSeconds / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatDuration(Duration(seconds: value.toInt())),
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
              maxX: (widget.times.length - 1).toDouble(),
              minY: 0,
              maxY: _maxSeconds,
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  if (widget.showThreshold && widget.threshold != null)
                    HorizontalLine(
                      y: widget.threshold!.inSeconds.toDouble(),
                      color: thresholdColor,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (_) => 'Threshold',
                        style: TextStyle(
                          color: thresholdColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (widget.showAverage)
                    HorizontalLine(
                      y: _averageSeconds,
                      color: averageColor,
                      strokeWidth: 2,
                      dashArray: [3, 3],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topLeft,
                        labelResolver: (_) => 'Avg',
                        style: TextStyle(
                          color: averageColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: widget.times.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.inSeconds.toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
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
        if (widget.showThreshold || widget.showAverage) ...[
          const SizedBox(height: 16),
          _buildLegend(
            theme: theme,
            lineColor: lineColor,
            thresholdColor: thresholdColor,
            averageColor: averageColor,
          ),
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
              Icons.timeline,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No time data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend({
    required ThemeData theme,
    required Color lineColor,
    required Color thresholdColor,
    required Color averageColor,
  }) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: lineColor, label: 'Time per question'),
        if (widget.showThreshold && widget.threshold != null)
          _LegendItem(
            color: thresholdColor,
            label: 'Threshold (${_formatDuration(widget.threshold!)})',
            isDashed: true,
          ),
        if (widget.showAverage)
          _LegendItem(
            color: averageColor,
            label: 'Average (${_formatDuration(Duration(seconds: _averageSeconds.toInt()))})',
            isDashed: true,
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      final mins = duration.inMinutes;
      final secs = duration.inSeconds % 60;
      return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
    }
    return '${duration.inSeconds}s';
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.isDashed = false,
  });

  final Color color;
  final String label;
  final bool isDashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDashed)
          CustomPaint(
            size: const Size(20, 2),
            painter: _DashedLinePainter(color: color),
          )
        else
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashWidth = 4.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
