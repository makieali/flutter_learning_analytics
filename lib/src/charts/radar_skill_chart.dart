import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A radar chart for comparing multiple skills or metrics.
///
/// Displays skill values in a spider/radar chart format, with optional
/// comparison overlays and interactive features.
class RadarSkillChart extends StatefulWidget {
  /// Creates a new [RadarSkillChart].
  const RadarSkillChart({
    required this.skills,
    super.key,
    this.targetSkills,
    this.showTarget = true,
    this.showAverage = false,
    this.showLabels = true,
    this.showValues = true,
    this.animate = true,
    this.primaryColor,
    this.targetColor,
    this.averageColor,
    this.borderColor,
    this.tickCount = 4,
    this.onSkillTap,
  });

  /// Map of skill names to values (0.0 to 1.0).
  final Map<String, double> skills;

  /// Optional target values for comparison.
  final Map<String, double>? targetSkills;

  /// Whether to show target overlay.
  final bool showTarget;

  /// Whether to show average line.
  final bool showAverage;

  /// Whether to show skill labels.
  final bool showLabels;

  /// Whether to show values at each point.
  final bool showValues;

  /// Whether to animate the chart.
  final bool animate;

  /// Color for the primary data.
  final Color? primaryColor;

  /// Color for the target data.
  final Color? targetColor;

  /// Color for the average line.
  final Color? averageColor;

  /// Color for the chart border.
  final Color? borderColor;

  /// Number of tick marks on each axis.
  final int tickCount;

  /// Callback when a skill point is tapped.
  final void Function(String skill, double value)? onSkillTap;

  @override
  State<RadarSkillChart> createState() => _RadarSkillChartState();
}

class _RadarSkillChartState extends State<RadarSkillChart> {
  int _touchedIndex = -1;

  List<String> get _skillNames => widget.skills.keys.toList();
  List<double> get _skillValues => widget.skills.values.toList();

  double get _average {
    if (_skillValues.isEmpty) return 0;
    return _skillValues.reduce((a, b) => a + b) / _skillValues.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.skills.isEmpty) {
      return _buildEmptyState(theme);
    }

    if (widget.skills.length < 3) {
      return _buildInsufficientDataState(theme);
    }

    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final targetColor = widget.targetColor ?? theme.colorScheme.tertiary;
    final borderColor =
        widget.borderColor ?? theme.colorScheme.outline.withOpacity(0.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: RadarChart(
            RadarChartData(
              radarTouchData: RadarTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSpot == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSpot!.touchedRadarEntryIndex;

                    if (event is FlTapUpEvent && widget.onSkillTap != null) {
                      if (_touchedIndex >= 0 &&
                          _touchedIndex < _skillNames.length) {
                        widget.onSkillTap!(
                          _skillNames[_touchedIndex],
                          _skillValues[_touchedIndex],
                        );
                      }
                    }
                  });
                },
              ),
              dataSets: _buildDataSets(primaryColor, targetColor, theme),
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: BorderSide(color: borderColor, width: 1),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                if (!widget.showLabels || index >= _skillNames.length) {
                  return const RadarChartTitle(text: '');
                }
                final skillName = _skillNames[index];
                final value = _skillValues[index];

                String displayText = skillName.length > 10
                    ? '${skillName.substring(0, 8)}...'
                    : skillName;

                if (widget.showValues) {
                  displayText += '\n${(value * 100).toInt()}%';
                }

                return RadarChartTitle(
                  text: displayText,
                  angle: angle,
                  positionPercentageOffset: 0.1,
                );
              },
              tickCount: widget.tickCount,
              ticksTextStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              tickBorderData: BorderSide(
                color: borderColor,
                width: 1,
              ),
              gridBorderData: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            swapAnimationDuration: widget.animate
                ? const Duration(milliseconds: 500)
                : Duration.zero,
            swapAnimationCurve: Curves.easeOutCubic,
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(theme, primaryColor, targetColor),
        if (widget.showAverage) ...[
          const SizedBox(height: 8),
          _buildAverageIndicator(theme),
        ],
      ],
    );
  }

  List<RadarDataSet> _buildDataSets(
    Color primaryColor,
    Color targetColor,
    ThemeData theme,
  ) {
    final dataSets = <RadarDataSet>[];

    // Target data set (rendered first, so it appears behind)
    if (widget.showTarget && widget.targetSkills != null) {
      final targetValues = _skillNames
          .map((name) => widget.targetSkills![name] ?? 0.0)
          .toList();

      dataSets.add(RadarDataSet(
        dataEntries: targetValues
            .map((value) => RadarEntry(value: value))
            .toList(),
        fillColor: targetColor.withOpacity(0.1),
        borderColor: targetColor.withOpacity(0.5),
        borderWidth: 2,
        entryRadius: 0,
      ));
    }

    // Primary data set
    dataSets.add(RadarDataSet(
      dataEntries: _skillValues
          .map((value) => RadarEntry(value: value))
          .toList(),
      fillColor: primaryColor.withOpacity(0.2),
      borderColor: primaryColor,
      borderWidth: 3,
      entryRadius: 4,
    ));

    return dataSets;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.radar,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No skill data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsufficientDataState(ThemeData theme) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'At least 3 skills required for radar chart',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme, Color primaryColor, Color targetColor) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(
          color: primaryColor,
          label: 'Current',
          filled: true,
        ),
        if (widget.showTarget && widget.targetSkills != null)
          _LegendItem(
            color: targetColor,
            label: 'Target',
            filled: false,
          ),
      ],
    );
  }

  Widget _buildAverageIndicator(ThemeData theme) {
    final averageColor = widget.averageColor ?? const Color(0xFF4CAF50);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: averageColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Average: ${(_average * 100).toStringAsFixed(0)}%',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: averageColor,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.filled,
  });

  final Color color;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: filled ? color.withOpacity(0.3) : Colors.transparent,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
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
