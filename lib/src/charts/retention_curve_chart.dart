import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../calculators/retention_calculator.dart';
import '../models/retention_data.dart';

/// A chart for visualizing the Ebbinghaus forgetting curve.
///
/// Shows memory retention decay over time with optional review markers
/// and optimal review time indicators.
class RetentionCurveChart extends StatefulWidget {
  /// Creates a new [RetentionCurveChart].
  const RetentionCurveChart({
    required this.data,
    super.key,
    this.targetRetention = 0.9,
    this.showOptimalReviewTimes = true,
    this.showReviewMarkers = true,
    this.showPrediction = true,
    this.predictDays = 30,
    this.animate = true,
    this.curveColor,
    this.targetColor,
    this.reviewMarkerColor,
    this.predictionColor,
    this.onOptimalReviewTap,
  });

  /// Retention data to display.
  final RetentionData data;

  /// Target retention level (0.0 to 1.0).
  final double targetRetention;

  /// Whether to show optimal review time indicators.
  final bool showOptimalReviewTimes;

  /// Whether to show review markers on the chart.
  final bool showReviewMarkers;

  /// Whether to show predicted future retention.
  final bool showPrediction;

  /// Number of days to show in prediction.
  final int predictDays;

  /// Whether to animate the chart.
  final bool animate;

  /// Color for the retention curve.
  final Color? curveColor;

  /// Color for the target retention line.
  final Color? targetColor;

  /// Color for review markers.
  final Color? reviewMarkerColor;

  /// Color for the prediction area.
  final Color? predictionColor;

  /// Callback when optimal review time is tapped.
  final VoidCallback? onOptimalReviewTap;

  @override
  State<RetentionCurveChart> createState() => _RetentionCurveChartState();
}

class _RetentionCurveChartState extends State<RetentionCurveChart> {
  late List<RetentionCurvePoint> _curvePoints;
  late double _optimalReviewDay;

  @override
  void initState() {
    super.initState();
    _calculateCurve();
  }

  @override
  void didUpdateWidget(RetentionCurveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.predictDays != widget.predictDays) {
      _calculateCurve();
    }
  }

  void _calculateCurve() {
    const calculator = RetentionCalculator();
    _curvePoints = calculator.generateForgettingCurve(
      stability: widget.data.stability,
      days: widget.predictDays,
      pointsPerDay: 4,
    );

    _optimalReviewDay = calculator.daysUntilThreshold(
      stability: widget.data.stability,
      threshold: widget.targetRetention,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final curveColor = widget.curveColor ?? theme.colorScheme.primary;
    final targetColor = widget.targetColor ?? const Color(0xFF4CAF50);
    final reviewMarkerColor =
        widget.reviewMarkerColor ?? theme.colorScheme.secondary;
    final predictionColor = widget.predictionColor ?? curveColor.withOpacity(0.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.6,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final day = spot.x;
                      final retention = spot.y;
                      return LineTooltipItem(
                        'Day ${day.toStringAsFixed(1)}\n'
                        'Retention: ${(retention * 100).toStringAsFixed(0)}%',
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
                horizontalInterval: 0.2,
                verticalInterval: widget.predictDays / 5,
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
                  axisNameWidget: Text(
                    'Days since last review',
                    style: theme.textTheme.bodySmall,
                  ),
                  axisNameSize: 24,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: widget.predictDays / 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Retention',
                    style: theme.textTheme.bodySmall,
                  ),
                  axisNameSize: 24,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    interval: 0.2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value * 100).toInt()}%',
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
              maxX: widget.predictDays.toDouble(),
              minY: 0,
              maxY: 1,
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: widget.targetRetention,
                    color: targetColor,
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      labelResolver: (_) =>
                          'Target: ${(widget.targetRetention * 100).toInt()}%',
                      style: TextStyle(
                        color: targetColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                verticalLines: widget.showOptimalReviewTimes
                    ? [
                        VerticalLine(
                          x: _optimalReviewDay,
                          color: reviewMarkerColor,
                          strokeWidth: 2,
                          dashArray: [4, 4],
                          label: VerticalLineLabel(
                            show: true,
                            alignment: Alignment.topCenter,
                            labelResolver: (_) =>
                                'Review: Day ${_optimalReviewDay.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: reviewMarkerColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    : [],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: _curvePoints.map((point) {
                    return FlSpot(point.day, point.retention);
                  }).toList(),
                  isCurved: true,
                  curveSmoothness: 0.2,
                  color: curveColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: widget.showPrediction
                      ? BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              predictionColor,
                              predictionColor.withOpacity(0),
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
        const SizedBox(height: 16),
        _buildInfoCards(
          theme: theme,
          curveColor: curveColor,
          targetColor: targetColor,
          reviewMarkerColor: reviewMarkerColor,
        ),
      ],
    );
  }

  Widget _buildInfoCards({
    required ThemeData theme,
    required Color curveColor,
    required Color targetColor,
    required Color reviewMarkerColor,
  }) {
    final currentRetention = widget.data.calculateRetrievability();
    final isReviewDue = currentRetention < widget.targetRetention;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InfoChip(
          icon: Icons.psychology,
          label: 'Current',
          value: '${(currentRetention * 100).toStringAsFixed(0)}%',
          color: currentRetention >= widget.targetRetention
              ? const Color(0xFF4CAF50)
              : const Color(0xFFF44336),
        ),
        _InfoChip(
          icon: Icons.timer,
          label: 'Stability',
          value: '${widget.data.stability.toStringAsFixed(1)} days',
          color: theme.colorScheme.primary,
        ),
        _InfoChip(
          icon: Icons.event,
          label: 'Next Review',
          value: isReviewDue
              ? 'Now'
              : 'Day ${_optimalReviewDay.toStringAsFixed(0)}',
          color: isReviewDue ? const Color(0xFFF44336) : reviewMarkerColor,
          onTap: widget.onOptimalReviewTap,
        ),
        _InfoChip(
          icon: Icons.repeat,
          label: 'Reviews',
          value: '${widget.data.reviewCount}',
          color: theme.colorScheme.tertiary,
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
