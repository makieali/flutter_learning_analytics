import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A pie chart widget for displaying accuracy distribution.
///
/// Shows the distribution of correct, wrong, and skipped answers
/// in an interactive pie chart format.
class AccuracyPieChart extends StatefulWidget {
  /// Creates a new [AccuracyPieChart].
  const AccuracyPieChart({
    required this.correct,
    required this.wrong,
    super.key,
    this.skipped = 0,
    this.correctColor,
    this.wrongColor,
    this.skippedColor,
    this.showPercentages = true,
    this.showLabels = true,
    this.showLegend = true,
    this.centerWidget,
    this.radius = 100,
    this.innerRadius = 60,
    this.animationDuration = const Duration(milliseconds: 800),
    this.onSectionTap,
  });

  /// Number of correct answers.
  final int correct;

  /// Number of wrong answers.
  final int wrong;

  /// Number of skipped questions.
  final int skipped;

  /// Color for correct section.
  final Color? correctColor;

  /// Color for wrong section.
  final Color? wrongColor;

  /// Color for skipped section.
  final Color? skippedColor;

  /// Whether to show percentages on sections.
  final bool showPercentages;

  /// Whether to show labels on sections.
  final bool showLabels;

  /// Whether to show the legend.
  final bool showLegend;

  /// Optional widget to display in the center of the chart.
  final Widget? centerWidget;

  /// Radius of the pie chart.
  final double radius;

  /// Inner radius for donut chart style.
  final double innerRadius;

  /// Animation duration.
  final Duration animationDuration;

  /// Callback when a section is tapped.
  final void Function(int sectionIndex, String sectionName)? onSectionTap;

  @override
  State<AccuracyPieChart> createState() => _AccuracyPieChartState();
}

class _AccuracyPieChartState extends State<AccuracyPieChart> {
  int _touchedIndex = -1;

  int get _total => widget.correct + widget.wrong + widget.skipped;

  double get _correctPercentage =>
      _total > 0 ? (widget.correct / _total) * 100 : 0;
  double get _wrongPercentage =>
      _total > 0 ? (widget.wrong / _total) * 100 : 0;
  double get _skippedPercentage =>
      _total > 0 ? (widget.skipped / _total) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final correctColor =
        widget.correctColor ?? const Color(0xFF4CAF50); // Green
    final wrongColor = widget.wrongColor ?? const Color(0xFFF44336); // Red
    final skippedColor =
        widget.skippedColor ?? const Color(0xFFFF9800); // Orange

    if (_total == 0) {
      return _buildEmptyState(theme);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.radius * 2 + 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;

                        if (event is FlTapUpEvent && widget.onSectionTap != null) {
                          final names = ['Correct', 'Wrong', 'Skipped'];
                          if (_touchedIndex >= 0 && _touchedIndex < names.length) {
                            widget.onSectionTap!(_touchedIndex, names[_touchedIndex]);
                          }
                        }
                      });
                    },
                  ),
                  sections: _buildSections(
                    correctColor: correctColor,
                    wrongColor: wrongColor,
                    skippedColor: skippedColor,
                    theme: theme,
                  ),
                  centerSpaceRadius: widget.innerRadius,
                  sectionsSpace: 2,
                ),
                swapAnimationDuration: widget.animationDuration,
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
              if (widget.centerWidget != null) widget.centerWidget!,
            ],
          ),
        ),
        if (widget.showLegend) ...[
          const SizedBox(height: 16),
          _buildLegend(
            correctColor: correctColor,
            wrongColor: wrongColor,
            skippedColor: skippedColor,
            theme: theme,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: widget.radius * 2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
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

  List<PieChartSectionData> _buildSections({
    required Color correctColor,
    required Color wrongColor,
    required Color skippedColor,
    required ThemeData theme,
  }) {
    final sections = <PieChartSectionData>[];

    if (widget.correct > 0) {
      sections.add(_buildSection(
        index: 0,
        value: widget.correct.toDouble(),
        percentage: _correctPercentage,
        color: correctColor,
        title: 'Correct',
        theme: theme,
      ));
    }

    if (widget.wrong > 0) {
      sections.add(_buildSection(
        index: sections.length,
        value: widget.wrong.toDouble(),
        percentage: _wrongPercentage,
        color: wrongColor,
        title: 'Wrong',
        theme: theme,
      ));
    }

    if (widget.skipped > 0) {
      sections.add(_buildSection(
        index: sections.length,
        value: widget.skipped.toDouble(),
        percentage: _skippedPercentage,
        color: skippedColor,
        title: 'Skipped',
        theme: theme,
      ));
    }

    return sections;
  }

  PieChartSectionData _buildSection({
    required int index,
    required double value,
    required double percentage,
    required Color color,
    required String title,
    required ThemeData theme,
  }) {
    final isTouched = index == _touchedIndex;
    final radius = isTouched ? widget.radius + 10 : widget.radius;
    final fontSize = isTouched ? 16.0 : 14.0;

    String titleText = '';
    if (widget.showPercentages) {
      titleText = '${percentage.toStringAsFixed(1)}%';
    }
    if (widget.showLabels && isTouched) {
      titleText = '$title\n${value.toInt()}';
    }

    return PieChartSectionData(
      value: value,
      title: titleText,
      color: color,
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: const [
          Shadow(blurRadius: 2, color: Colors.black38),
        ],
      ),
      titlePositionPercentageOffset: 0.55,
      badgeWidget: isTouched
          ? null
          : null, // Can add badges here
      badgePositionPercentageOffset: 0.98,
    );
  }

  Widget _buildLegend({
    required Color correctColor,
    required Color wrongColor,
    required Color skippedColor,
    required ThemeData theme,
  }) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (widget.correct > 0)
          _LegendItem(
            color: correctColor,
            label: 'Correct',
            value: widget.correct,
            percentage: _correctPercentage,
          ),
        if (widget.wrong > 0)
          _LegendItem(
            color: wrongColor,
            label: 'Wrong',
            value: widget.wrong,
            percentage: _wrongPercentage,
          ),
        if (widget.skipped > 0)
          _LegendItem(
            color: skippedColor,
            label: 'Skipped',
            value: widget.skipped,
            percentage: _skippedPercentage,
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
  });

  final Color color;
  final String label;
  final int value;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value (${percentage.toStringAsFixed(1)}%)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
