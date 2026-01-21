import 'package:flutter/material.dart';

import '../models/recommendation.dart';

/// A card widget for displaying a recommendation.
class RecommendationCard extends StatelessWidget {
  /// Creates a new [RecommendationCard].
  const RecommendationCard({
    required this.recommendation,
    super.key,
    this.onTap,
    this.onDismiss,
    this.showIcon = true,
    this.showPriority = true,
    this.compact = false,
  });

  /// The recommendation to display.
  final Recommendation recommendation;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is dismissed.
  final VoidCallback? onDismiss;

  /// Whether to show the type icon.
  final bool showIcon;

  /// Whether to show the priority indicator.
  final bool showPriority;

  /// Use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = recommendation.color;

    if (compact) {
      return _buildCompact(theme, color);
    }

    return Dismissible(
      key: ValueKey(recommendation.id),
      direction: onDismiss != null
          ? DismissDirection.horizontal
          : DismissDirection.none,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        color: Colors.green,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showIcon)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      recommendation.icon,
                      size: 20,
                      color: color,
                    ),
                  ),
                ),
              if (showIcon) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recommendation.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (showPriority) _buildPriorityBadge(theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recommendation.actionLabel != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          foregroundColor: color,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          recommendation.actionLabel!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(ThemeData theme, Color color) {
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
            if (showIcon) ...[
              Icon(recommendation.icon, size: 16, color: color),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                recommendation.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(ThemeData theme) {
    Color badgeColor;
    String label;

    switch (recommendation.priority) {
      case RecommendationPriority.critical:
        badgeColor = const Color(0xFFF44336);
        label = 'Critical';
      case RecommendationPriority.high:
        badgeColor = const Color(0xFFFF9800);
        label = 'High';
      case RecommendationPriority.medium:
        badgeColor = const Color(0xFFFFC107);
        label = 'Medium';
      case RecommendationPriority.low:
        badgeColor = const Color(0xFF4CAF50);
        label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }
}

/// A list of recommendation cards.
class RecommendationList extends StatelessWidget {
  /// Creates a new [RecommendationList].
  const RecommendationList({
    required this.recommendations,
    super.key,
    this.onTap,
    this.onDismiss,
    this.maxItems,
    this.showEmpty = true,
    this.emptyMessage = 'No recommendations',
    this.compact = false,
  });

  /// List of recommendations.
  final List<Recommendation> recommendations;

  /// Callback when a recommendation is tapped.
  final void Function(Recommendation)? onTap;

  /// Callback when a recommendation is dismissed.
  final void Function(Recommendation)? onDismiss;

  /// Maximum number of items to show.
  final int? maxItems;

  /// Whether to show empty state.
  final bool showEmpty;

  /// Empty state message.
  final String emptyMessage;

  /// Use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recommendations.isEmpty && showEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                emptyMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = maxItems != null
        ? recommendations.take(maxItems!).toList()
        : recommendations;

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final rec = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < items.length - 1 ? (compact ? 8 : 12) : 0,
          ),
          child: RecommendationCard(
            recommendation: rec,
            onTap: onTap != null ? () => onTap!(rec) : null,
            onDismiss: onDismiss != null ? () => onDismiss!(rec) : null,
            compact: compact,
          ),
        );
      }).toList(),
    );
  }
}
