import 'package:flutter/material.dart';

/// A tile widget for displaying a single statistic.
///
/// Shows an icon, value, and label in a compact card format.
class StatTile extends StatelessWidget {
  /// Creates a new [StatTile].
  const StatTile({
    required this.value,
    required this.label,
    super.key,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.subtitle,
    this.trend,
    this.trendPositive = true,
    this.onTap,
    this.compact = false,
  });

  /// The main value to display.
  final String value;

  /// Label describing the statistic.
  final String label;

  /// Optional icon.
  final IconData? icon;

  /// Color for the icon.
  final Color? iconColor;

  /// Color for the value.
  final Color? valueColor;

  /// Optional subtitle or additional info.
  final String? subtitle;

  /// Optional trend value (e.g., "+5%", "-3").
  final String? trend;

  /// Whether the trend is positive (affects color).
  final bool trendPositive;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: compact ? _buildCompactLayout(theme) : _buildFullLayout(theme),
      ),
    );
  }

  Widget _buildFullLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.colorScheme.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: valueColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trend != null) ...[
                        const SizedBox(width: 8),
                        _buildTrendBadge(theme),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLayout(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: iconColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (trend != null) ...[
          const SizedBox(width: 8),
          _buildTrendBadge(theme),
        ],
      ],
    );
  }

  Widget _buildTrendBadge(ThemeData theme) {
    final trendColor = trendPositive
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendPositive ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: trendColor,
          ),
          const SizedBox(width: 2),
          Text(
            trend!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of stat tiles.
class StatTileRow extends StatelessWidget {
  /// Creates a new [StatTileRow].
  const StatTileRow({
    required this.tiles,
    super.key,
    this.spacing = 12,
    this.compact = false,
  });

  /// List of stat tile data.
  final List<StatTileData> tiles;

  /// Spacing between tiles.
  final double spacing;

  /// Use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tiles.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? spacing / 2 : 0,
              right: index < tiles.length - 1 ? spacing / 2 : 0,
            ),
            child: StatTile(
              value: data.value,
              label: data.label,
              icon: data.icon,
              iconColor: data.iconColor,
              valueColor: data.valueColor,
              trend: data.trend,
              trendPositive: data.trendPositive,
              compact: compact,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Data for a [StatTile].
class StatTileData {
  /// Creates a new [StatTileData].
  const StatTileData({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.trend,
    this.trendPositive = true,
  });

  /// The main value.
  final String value;

  /// Label.
  final String label;

  /// Icon.
  final IconData? icon;

  /// Icon color.
  final Color? iconColor;

  /// Value color.
  final Color? valueColor;

  /// Trend value.
  final String? trend;

  /// Whether trend is positive.
  final bool trendPositive;
}
