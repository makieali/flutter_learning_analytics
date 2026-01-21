import 'package:flutter/material.dart';

/// A card widget for comparing two values (e.g., your score vs target).
class ComparisonCard extends StatelessWidget {
  /// Creates a new [ComparisonCard].
  const ComparisonCard({
    required this.currentValue,
    required this.targetValue,
    super.key,
    this.currentLabel = 'You',
    this.targetLabel = 'Target',
    this.maxValue = 100,
    this.title,
    this.showDifference = true,
    this.currentColor,
    this.targetColor,
    this.formatValue,
  });

  /// Current/user's value.
  final double currentValue;

  /// Target/comparison value.
  final double targetValue;

  /// Label for current value.
  final String currentLabel;

  /// Label for target value.
  final String targetLabel;

  /// Maximum value for percentage calculation.
  final double maxValue;

  /// Optional title.
  final String? title;

  /// Whether to show the difference.
  final bool showDifference;

  /// Color for current value bar.
  final Color? currentColor;

  /// Color for target value bar.
  final Color? targetColor;

  /// Custom value formatter.
  final String Function(double)? formatValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difference = currentValue - targetValue;
    final isAboveTarget = difference >= 0;

    final currentCol = currentColor ?? theme.colorScheme.primary;
    final targetCol = targetColor ?? theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Current value bar
          _ComparisonBar(
            value: currentValue,
            maxValue: maxValue,
            label: currentLabel,
            color: currentCol,
            formatValue: formatValue,
          ),
          const SizedBox(height: 12),
          // Target value bar
          _ComparisonBar(
            value: targetValue,
            maxValue: maxValue,
            label: targetLabel,
            color: targetCol,
            formatValue: formatValue,
            isDashed: true,
          ),
          if (showDifference) ...[
            const SizedBox(height: 16),
            _buildDifferenceIndicator(
              theme: theme,
              difference: difference,
              isAboveTarget: isAboveTarget,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDifferenceIndicator({
    required ThemeData theme,
    required double difference,
    required bool isAboveTarget,
  }) {
    final color = isAboveTarget
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);

    final formattedDiff = formatValue != null
        ? formatValue!(difference.abs())
        : difference.abs().toStringAsFixed(0);

    return Row(
      children: [
        Icon(
          isAboveTarget ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${isAboveTarget ? '+' : '-'}$formattedDiff',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isAboveTarget ? 'above target' : 'below target',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  const _ComparisonBar({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
    this.formatValue,
    this.isDashed = false,
  });

  final double value;
  final double maxValue;
  final String label;
  final Color color;
  final String Function(double)? formatValue;
  final bool isDashed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final displayValue = formatValue?.call(value) ?? value.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              displayValue,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth * percentage;
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  width: barWidth,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDashed ? null : color,
                    gradient: isDashed
                        ? null
                        : LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isDashed
                      ? CustomPaint(
                          painter: _DashedBarPainter(color: color),
                        )
                      : null,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DashedBarPainter extends CustomPainter {
  const _DashedBarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
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
