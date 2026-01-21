/// A comprehensive learning analytics and progress visualization package
/// for Flutter educational apps.
///
/// This package provides:
/// - **Data Models**: Learning sessions, quiz analytics, mastery tracking,
///   streak data, retention data, and recommendations
/// - **Calculators**: Mastery calculation (EMA), streak tracking, retention
///   (forgetting curve), and recommendation engine
/// - **Chart Widgets**: Accuracy pie charts, performance bar charts,
///   time line charts, progress charts, retention curves, radar skill charts,
///   heatmap calendars, and streak calendars
/// - **Stat Widgets**: Score cards, mastery indicators, progress rings,
///   stat tiles, comparison cards, recommendation cards, and achievement badges
/// - **Pre-built Screens**: Complete analytics dashboard
/// - **Theming**: Comprehensive theming system with pre-built color schemes
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_learning_analytics/flutter_learning_analytics.dart';
///
/// // Simple accuracy chart
/// AccuracyPieChart(
///   correct: 75,
///   wrong: 20,
///   skipped: 5,
/// )
///
/// // Full dashboard
/// AnalyticsDashboard(
///   data: LearningAnalyticsData(
///     sessions: mySessions,
///     quizzes: myQuizzes,
///     streakData: myStreaks,
///   ),
/// )
/// ```
///
/// ## Features
///
/// ### Charts
/// - [AccuracyPieChart] - Show correct/wrong/skipped distribution
/// - [PerformanceBarChart] - Compare performance across topics
/// - [TimeLineChart] - Time spent per question/session
/// - [ProgressLineChart] - Progress over time
/// - [RetentionCurveChart] - Forgetting curve visualization
/// - [RadarSkillChart] - Multi-dimensional skill comparison
/// - [HeatmapCalendar] - GitHub-style activity heatmap
/// - [StreakCalendar] - Weekly streak grid
///
/// ### Widgets
/// - [ScoreCard] - Display score with grade
/// - [MasteryIndicator] - Show mastery level badge
/// - [ProgressRing] - Circular progress indicator
/// - [StatTile] - Single metric display
/// - [ComparisonCard] - Your score vs target
/// - [RecommendationCard] - AI recommendation display
/// - [AchievementBadge] - Gamification badges
///
/// ### Calculators
/// - [MasteryCalculator] - Exponential moving average mastery
/// - [StreakCalculator] - Consecutive day tracking
/// - [RetentionCalculator] - Ebbinghaus forgetting curve
/// - [RecommendationEngine] - Smart recommendation generation
///
/// ### Screens
/// - [AnalyticsDashboard] - Complete analytics dashboard
library flutter_learning_analytics;

// Models
export 'src/models/models.dart';

// Calculators
export 'src/calculators/calculators.dart';

// Charts
export 'src/charts/charts.dart';

// Widgets
export 'src/widgets/widgets.dart';

// Screens
export 'src/screens/screens.dart';

// Themes
export 'src/themes/themes.dart';

// Utils
export 'src/utils/utils.dart';
