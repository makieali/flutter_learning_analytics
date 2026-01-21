import 'package:flutter/material.dart';

import '../charts/accuracy_pie_chart.dart';
import '../charts/heatmap_calendar.dart';
import '../charts/performance_bar_chart.dart';
import '../charts/progress_line_chart.dart';
import '../charts/streak_calendar.dart';
import '../models/learning_analytics_data.dart';
import '../widgets/progress_ring.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/stat_tile.dart';

/// A complete analytics dashboard screen.
///
/// Displays comprehensive learning analytics with charts, stats,
/// recommendations, and progress indicators.
class AnalyticsDashboard extends StatelessWidget {
  /// Creates a new [AnalyticsDashboard].
  const AnalyticsDashboard({
    required this.data,
    super.key,
    this.title = 'Learning Analytics',
    this.showHeader = true,
    this.showStats = true,
    this.showAccuracyChart = true,
    this.showProgressChart = true,
    this.showPerformanceChart = true,
    this.showStreak = true,
    this.showHeatmap = true,
    this.showRecommendations = true,
    this.sections,
    this.padding = const EdgeInsets.all(16),
    this.sectionSpacing = 24,
    this.onRecommendationTap,
    this.onSectionTap,
  });

  /// Analytics data to display.
  final LearningAnalyticsData data;

  /// Dashboard title.
  final String title;

  /// Whether to show the header section.
  final bool showHeader;

  /// Whether to show the stats overview.
  final bool showStats;

  /// Whether to show the accuracy pie chart.
  final bool showAccuracyChart;

  /// Whether to show the progress line chart.
  final bool showProgressChart;

  /// Whether to show the performance bar chart.
  final bool showPerformanceChart;

  /// Whether to show the streak calendar.
  final bool showStreak;

  /// Whether to show the activity heatmap.
  final bool showHeatmap;

  /// Whether to show recommendations.
  final bool showRecommendations;

  /// Custom sections to display (overrides default sections).
  final List<DashboardSection>? sections;

  /// Padding around the dashboard.
  final EdgeInsets padding;

  /// Spacing between sections.
  final double sectionSpacing;

  /// Callback when a recommendation is tapped.
  final void Function(dynamic recommendation)? onRecommendationTap;

  /// Callback when a section header is tapped.
  final void Function(String sectionId)? onSectionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            _buildHeader(theme),
            SizedBox(height: sectionSpacing),
          ],
          if (showStats) ...[
            _buildStatsSection(theme),
            SizedBox(height: sectionSpacing),
          ],
          if (showStreak && data.streakData != null) ...[
            _buildStreakSection(theme),
            SizedBox(height: sectionSpacing),
          ],
          if (showAccuracyChart && data.totalQuestionsAnswered > 0) ...[
            _buildAccuracySection(theme),
            SizedBox(height: sectionSpacing),
          ],
          if (showProgressChart && data.progressHistory.isNotEmpty) ...[
            _buildProgressSection(theme),
            SizedBox(height: sectionSpacing),
          ],
          if (showPerformanceChart && data.masteryProgress.isNotEmpty) ...[
            _buildPerformanceSection(theme),
            SizedBox(height: sectionSpacing),
          ],
          if (showHeatmap && data.activityMap.isNotEmpty) ...[
            _buildHeatmapSection(theme),
            SizedBox(height: sectionSpacing),
          ],
          if (showRecommendations && data.recommendations.isNotEmpty) ...[
            _buildRecommendationsSection(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your learning progress and improve your skills',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Overview',
          icon: Icons.dashboard,
          onTap: onSectionTap != null ? () => onSectionTap!('overview') : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ProgressRing(
                value: data.overallAccuracy,
                size: 100,
                label: 'Accuracy',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  StatTileRow(
                    tiles: [
                      StatTileData(
                        value: '${data.totalQuestionsAnswered}',
                        label: 'Questions',
                        icon: Icons.quiz,
                      ),
                      StatTileData(
                        value: '${data.sessions.length}',
                        label: 'Sessions',
                        icon: Icons.timer,
                      ),
                    ],
                    compact: true,
                  ),
                  const SizedBox(height: 8),
                  StatTileRow(
                    tiles: [
                      StatTileData(
                        value: '${data.totalXp}',
                        label: 'XP',
                        icon: Icons.star,
                      ),
                      StatTileData(
                        value: 'Lvl ${data.currentLevel}',
                        label: 'Level',
                        icon: Icons.emoji_events,
                      ),
                    ],
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Streak',
          icon: Icons.local_fire_department,
          onTap: onSectionTap != null ? () => onSectionTap!('streak') : null,
        ),
        const SizedBox(height: 12),
        Center(
          child: StreakCalendar(
            streakData: data.streakData!,
          ),
        ),
      ],
    );
  }

  Widget _buildAccuracySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Answer Distribution',
          icon: Icons.pie_chart,
          onTap: onSectionTap != null ? () => onSectionTap!('accuracy') : null,
        ),
        const SizedBox(height: 12),
        Center(
          child: AccuracyPieChart(
            correct: data.totalCorrectAnswers,
            wrong: data.totalWrongAnswers,
            skipped: data.totalSkippedQuestions,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Progress Over Time',
          icon: Icons.show_chart,
          onTap: onSectionTap != null ? () => onSectionTap!('progress') : null,
        ),
        const SizedBox(height: 12),
        ProgressLineChart(
          data: data.progressHistory,
          showTarget: true,
          targetValue: 80,
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(ThemeData theme) {
    final topicPerformance = <String, double>{};
    for (final progress in data.masteryProgress.take(5)) {
      topicPerformance[progress.topicName] = progress.currentScore * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Topic Performance',
          icon: Icons.bar_chart,
          onTap:
              onSectionTap != null ? () => onSectionTap!('performance') : null,
        ),
        const SizedBox(height: 12),
        PerformanceBarChart(
          data: topicPerformance,
          targetValue: 80,
        ),
      ],
    );
  }

  Widget _buildHeatmapSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Activity',
          icon: Icons.calendar_today,
          onTap: onSectionTap != null ? () => onSectionTap!('heatmap') : null,
        ),
        const SizedBox(height: 12),
        HeatmapCalendar(
          data: data.activityMap,
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Recommendations',
          icon: Icons.lightbulb,
          onTap: onSectionTap != null
              ? () => onSectionTap!('recommendations')
              : null,
        ),
        const SizedBox(height: 12),
        RecommendationList(
          recommendations: data.recommendations,
          maxItems: 3,
          onTap: onRecommendationTap,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.outline,
            ),
        ],
      ),
    );
  }
}

/// A custom dashboard section.
class DashboardSection {
  /// Creates a new [DashboardSection].
  const DashboardSection({
    required this.id,
    required this.title,
    required this.builder,
    this.icon,
  });

  /// Section identifier.
  final String id;

  /// Section title.
  final String title;

  /// Icon for the section.
  final IconData? icon;

  /// Builder function for the section content.
  final Widget Function(BuildContext context, LearningAnalyticsData data)
      builder;
}
