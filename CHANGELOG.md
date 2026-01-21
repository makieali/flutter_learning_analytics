# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-21

### Added

#### Charts
- `AccuracyPieChart` - Interactive pie chart for correct/wrong/skipped distribution
- `PerformanceBarChart` - Horizontal and vertical bar charts for topic comparison
- `ProgressLineChart` - Line chart for progress over time with trend indicators
- `TimeLineChart` - Time spent visualization with thresholds and averages
- `RetentionCurveChart` - Forgetting curve (Ebbinghaus) visualization
- `RadarSkillChart` - Multi-dimensional skill comparison radar chart
- `HeatmapCalendar` - GitHub-style activity heatmap
- `StreakCalendar` - Weekly streak grid with indicators

#### Widgets
- `ScoreCard` - Score display with automatic grade calculation
- `MasteryIndicator` - Mastery level badge with progress bar
- `MasteryBadge` - Compact mastery level indicator
- `ProgressRing` - Circular progress indicator with animation
- `LabeledProgressRing` - Progress ring with label and sublabel
- `StatTile` - Single metric display with optional trend
- `StatTileRow` - Row of multiple stat tiles
- `ComparisonCard` - Your score vs target comparison
- `RecommendationCard` - AI recommendation display
- `RecommendationList` - List of recommendations
- `AchievementBadge` - Gamification badge with unlock status
- `AchievementGrid` - Grid of achievement badges

#### Calculators
- `MasteryCalculator` - Exponential Moving Average (EMA) mastery calculation
- `RetentionCalculator` - Ebbinghaus forgetting curve implementation
- `StreakCalculator` - Consecutive day tracking with freeze support
- `RecommendationEngine` - Smart learning recommendation generation

#### Models
- `LearningSession` - Learning session data model
- `QuizAnalytics` - Quiz performance data model
- `MasteryLevel` - Mastery level enumeration (novice to expert)
- `MasteryProgress` - Topic mastery progress tracking
- `StreakData` - Streak information model
- `DailyActivity` - Daily activity record
- `RetentionData` - Forgetting curve data model
- `Recommendation` - Learning recommendation model
- `ProgressPoint` - Progress data point
- `LearningAnalyticsData` - Comprehensive analytics data model

#### Screens
- `AnalyticsDashboard` - Complete pre-built analytics dashboard

#### Theming
- `LearningAnalyticsTheme` - InheritedWidget for theming
- `LearningAnalyticsThemeData` - Theme configuration
- Pre-built themes: light, dark, colorful
- `AnalyticsColorSchemes` - Pre-built color schemes
- `HeatmapColorScheme` - Heatmap color configurations

#### Utilities
- `AnalyticsFormatters` - Number, duration, date, and grade formatting
- Extensions for `List<LearningSession>`, `List<QuizAnalytics>`, `DateTime`
