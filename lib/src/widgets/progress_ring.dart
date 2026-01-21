import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular progress indicator widget.
///
/// Displays progress as a ring/donut chart with customizable
/// styling and optional center content.
class ProgressRing extends StatelessWidget {
  /// Creates a new [ProgressRing].
  const ProgressRing({
    required this.value,
    super.key,
    this.size = 100,
    this.strokeWidth = 10,
    this.backgroundColor,
    this.foregroundColor,
    this.gradientColors,
    this.showPercentage = true,
    this.centerWidget,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.startAngle = -90,
    this.label,
  });

  /// Progress value (0.0 to 1.0).
  final double value;

  /// Size of the ring.
  final double size;

  /// Width of the ring stroke.
  final double strokeWidth;

  /// Background color of the ring track.
  final Color? backgroundColor;

  /// Foreground color of the progress.
  final Color? foregroundColor;

  /// Gradient colors for the progress (overrides foregroundColor).
  final List<Color>? gradientColors;

  /// Whether to show the percentage in the center.
  final bool showPercentage;

  /// Custom widget to display in the center.
  final Widget? centerWidget;

  /// Whether to animate the progress.
  final bool animate;

  /// Animation duration.
  final Duration animationDuration;

  /// Start angle in degrees (-90 = top).
  final double startAngle;

  /// Optional label below the percentage.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final fgColor = foregroundColor ?? theme.colorScheme.primary;
    final clampedValue = value.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: bgColor,
              strokeWidth: strokeWidth,
              startAngle: startAngle,
            ),
          ),
          // Progress ring
          animate
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: clampedValue),
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, child) {
                    return CustomPaint(
                      size: Size(size, size),
                      painter: _RingPainter(
                        progress: animatedValue,
                        color: fgColor,
                        gradientColors: gradientColors,
                        strokeWidth: strokeWidth,
                        startAngle: startAngle,
                      ),
                    );
                  },
                )
              : CustomPaint(
                  size: Size(size, size),
                  painter: _RingPainter(
                    progress: clampedValue,
                    color: fgColor,
                    gradientColors: gradientColors,
                    strokeWidth: strokeWidth,
                    startAngle: startAngle,
                  ),
                ),
          // Center content
          if (centerWidget != null)
            centerWidget!
          else if (showPercentage)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                animate
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: clampedValue * 100),
                        duration: animationDuration,
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedValue, child) {
                          return Text(
                            '${animatedValue.toInt()}%',
                            style: TextStyle(
                              fontSize: size * 0.2,
                              fontWeight: FontWeight.bold,
                              color: fgColor,
                            ),
                          );
                        },
                      )
                    : Text(
                        '${(clampedValue * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: size * 0.2,
                          fontWeight: FontWeight.bold,
                          color: fgColor,
                        ),
                      ),
                if (label != null)
                  Text(
                    label!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    this.gradientColors,
  });

  final double progress;
  final Color color;
  final List<Color>? gradientColors;
  final double strokeWidth;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradientColors != null && gradientColors!.length >= 2) {
      paint.shader = SweepGradient(
        colors: gradientColors!,
        startAngle: startAngle * math.pi / 180,
        endAngle: (startAngle + 360) * math.pi / 180,
      ).createShader(rect);
    } else {
      paint.color = color;
    }

    final sweepAngle = progress * 2 * math.pi;
    final startRad = startAngle * math.pi / 180;

    canvas.drawArc(rect, startRad, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// A simple progress ring with label.
class LabeledProgressRing extends StatelessWidget {
  /// Creates a new [LabeledProgressRing].
  const LabeledProgressRing({
    required this.value,
    required this.title,
    super.key,
    this.size = 80,
    this.strokeWidth = 8,
    this.color,
    this.subtitle,
  });

  /// Progress value (0.0 to 1.0).
  final double value;

  /// Title displayed below the ring.
  final String title;

  /// Size of the ring.
  final double size;

  /// Stroke width.
  final double strokeWidth;

  /// Progress color.
  final Color? color;

  /// Optional subtitle.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressRing(
          value: value,
          size: size,
          strokeWidth: strokeWidth,
          foregroundColor: color,
          showPercentage: true,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
