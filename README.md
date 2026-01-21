# flutter_learning_analytics

A comprehensive learning analytics and progress visualization package for Flutter educational apps. Build beautiful dashboards with charts, widgets, and smart insights to help learners track their progress.

[![pub package](https://img.shields.io/pub/v/flutter_learning_analytics.svg)](https://pub.dev/packages/flutter_learning_analytics)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **Charts**: Accuracy pie charts, performance bar charts, progress line charts, time analysis, retention curves, radar skill charts, heatmap calendars, and streak calendars
- **Widgets**: Score cards, mastery indicators, progress rings, stat tiles, comparison cards, recommendation cards, and achievement badges
- **Calculators**: Mastery calculation (EMA), streak tracking, retention/forgetting curve (Ebbinghaus), and recommendation engine
- **Pre-built Screens**: Complete analytics dashboard ready to use
- **Theming**: Comprehensive theming system with pre-built color schemes

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_learning_analytics: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter_learning_analytics/flutter_learning_analytics.dart';

// Simple accuracy chart
AccuracyPieChart(
  correct: 75,
  wrong: 20,
  skipped: 5,
)

// Full dashboard
AnalyticsDashboard(
  data: LearningAnalyticsData(
    sessions: mySessions,
    quizzes: myQuizzes,
    streakData: myStreaks,
  ),
)
```

## Charts

### AccuracyPieChart

Display correct/wrong/skipped distribution with an interactive pie chart.

```dart
AccuracyPieChart(
  correct: 75,
  wrong: 15,
  skipped: 10,
  showPercentages: true,
  animate: true,
  correctColor: Colors.green,
  wrongColor: Colors.red,
  skippedColor: Colors.orange,
)
```

### PerformanceBarChart

Compare performance across topics with horizontal or vertical bars.

```dart
PerformanceBarChart(
  data: {
    'Math': 0.85,
    'Science': 0.72,
    'History': 0.65,
    'English': 0.90,
  },
  horizontal: true,
  showValues: true,
  goodThreshold: 0.7,
  excellentThreshold: 0.9,
)
```

### ProgressLineChart

Track progress over time with trend indicators.

```dart
ProgressLineChart(
  points: [
    ProgressPoint(date: DateTime(2024, 1, 1), value: 0.5),
    ProgressPoint(date: DateTime(2024, 1, 2), value: 0.55),
    ProgressPoint(date: DateTime(2024, 1, 3), value: 0.62),
    // ...
  ],
  showTrend: true,
  showArea: true,
)
```

### TimeLineChart

Visualize time spent per question with thresholds and averages.

```dart
TimeLineChart(
  times: [
    Duration(seconds: 45),
    Duration(seconds: 30),
    Duration(seconds: 60),
    // ...
  ],
  threshold: Duration(seconds: 45),
  showAverage: true,
)
```

### RetentionCurveChart

Visualize the forgetting curve (Ebbinghaus) with optimal review indicators.

```dart
RetentionCurveChart(
  stability: 7.0, // days
  days: 14,
  targetRetention: 0.9,
  showOptimalReview: true,
)
```

### RadarSkillChart

Multi-dimensional skill comparison with radar visualization.

```dart
RadarSkillChart(
  skills: {
    'Problem Solving': 0.85,
    'Critical Thinking': 0.72,
    'Memory': 0.65,
    'Speed': 0.90,
    'Accuracy': 0.78,
  },
  showAverage: true,
)
```

### HeatmapCalendar

GitHub-style activity heatmap for visualizing learning patterns.

```dart
HeatmapCalendar(
  data: activityMap, // Map<DateTime, int>
  colorScheme: HeatmapColorScheme.green,
  startDate: DateTime.now().subtract(Duration(days: 365)),
  showLegend: true,
  onDayTap: (date, count) => print('$date: $count activities'),
)
```

### StreakCalendar

Weekly streak grid showing consecutive learning days.

```dart
StreakCalendar(
  data: streakData,
  showLegend: true,
)
```

## Widgets

### ScoreCard

Display score with automatic grade calculation.

```dart
ScoreCard(
  score: 85,
  maxScore: 100,
  title: 'Quiz Score',
  showGrade: true, // Shows 'A', 'B', 'C', etc.
)
```

### MasteryIndicator

Show mastery level with progress visualization.

```dart
MasteryIndicator(
  level: MasteryLevel.advanced,
  score: 0.75,
  showProgress: true,
)
```

Available mastery levels:
- `MasteryLevel.novice` (0-19%)
- `MasteryLevel.beginner` (20-39%)
- `MasteryLevel.intermediate` (40-59%)
- `MasteryLevel.advanced` (60-79%)
- `MasteryLevel.expert` (80-100%)

### ProgressRing

Circular progress indicator with animation.

```dart
ProgressRing(
  progress: 0.75,
  size: 80,
  strokeWidth: 8,
  showPercentage: true,
  animate: true,
)

// With label
LabeledProgressRing(
  progress: 0.85,
  size: 80,
  label: 'Math',
  sublabel: '85%',
)
```

### StatTile

Single metric display with optional trend indicator.

```dart
StatTile(
  title: 'Accuracy',
  value: '85%',
  icon: Icons.check_circle,
  color: Colors.green,
  trend: 5.2, // Optional: shows +5.2% badge
)

// Multiple tiles in a row
StatTileRow(
  tiles: [
    StatTileData(title: 'Questions', value: '1,234', icon: Icons.quiz),
    StatTileData(title: 'Accuracy', value: '85%', icon: Icons.check_circle, trend: 5.2),
    StatTileData(title: 'Streak', value: '7 days', icon: Icons.local_fire_department),
  ],
)
```

### ComparisonCard

Compare user score against a target or average.

```dart
ComparisonCard(
  yourScore: 0.85,
  targetScore: 0.90,
  label: 'Quiz Performance',
  showDifference: true,
)
```

### RecommendationCard

Display AI-powered learning recommendations.

```dart
RecommendationCard(
  recommendation: Recommendation(
    id: '1',
    type: RecommendationType.reviewTopic,
    title: 'Review Algebra',
    description: 'Your accuracy has dropped. Consider reviewing.',
    priority: RecommendationPriority.high,
  ),
)

// Multiple recommendations
RecommendationList(
  recommendations: recommendations,
)
```

### AchievementBadge

Gamification badges with unlock status and progress.

```dart
AchievementBadge(
  achievement: AchievementData(
    id: '1',
    title: 'Perfect Score',
    description: 'Get 100% on any quiz',
    icon: Icons.star,
    color: Colors.amber,
    isUnlocked: true,
    unlockedAt: DateTime.now(),
  ),
)

// Grid of achievements
AchievementGrid(
  achievements: achievements,
  crossAxisCount: 3,
)
```

## Calculators

### MasteryCalculator

Calculate mastery using Exponential Moving Average (EMA).

```dart
const calculator = MasteryCalculator();

// Calculate new score after an attempt
final newScore = calculator.calculateNewScore(
  currentScore: 0.6,
  wasCorrect: true,
  totalAttempts: 10,
);

// Get mastery level for a score
final level = calculator.getLevelForScore(newScore);

// Calculate from a batch of attempts
final score = calculator.calculateFromBatch([true, true, false, true, true]);

// Apply time-based decay
final decayedScore = calculator.calculateDecay(
  currentScore: 0.8,
  lastAttemptDate: DateTime.now().subtract(Duration(days: 14)),
);
```

### RetentionCalculator

Implement the Ebbinghaus forgetting curve (R = e^(-t/S)).

```dart
const calculator = RetentionCalculator();

// Calculate current retention
final retention = calculator.calculateRetrievability(
  daysSinceReview: 7,
  stability: 14.0,
);

// Calculate days until retention drops below threshold
final daysUntil = calculator.daysUntilThreshold(
  stability: 7.0,
  threshold: 0.9,
);

// Calculate next optimal review date
final nextReview = calculator.calculateNextReviewDate(
  lastReviewDate: DateTime.now(),
  stability: 7.0,
  threshold: 0.9,
);

// Generate forgetting curve data points
final curve = calculator.generateForgettingCurve(
  stability: 7.0,
  days: 30,
);

// Calculate new stability after review
final newStability = calculator.calculateNewStability(
  currentStability: 7.0,
  rating: 3, // 1=Again, 2=Hard, 3=Good, 4=Easy
);
```

### StreakCalculator

Track consecutive learning days with freeze support.

```dart
const calculator = StreakCalculator();

// Calculate streak from activity map
final streak = calculator.calculateStreak(
  activities: {
    DateTime(2024, 1, 1): true,
    DateTime(2024, 1, 2): true,
    DateTime(2024, 1, 3): false,
    // ...
  },
  freezeDays: {DateTime(2024, 1, 3)}, // Days that don't break streak
);

print(streak.currentStreak); // 2
print(streak.longestStreak); // 5
print(streak.isStreakActive); // true/false

// Generate heatmap data
final heatmapDays = calculator.generateHeatmapDays(
  activities: activities,
  startDate: DateTime.now().subtract(Duration(days: 365)),
);
```

### RecommendationEngine

Generate smart learning recommendations.

```dart
const engine = RecommendationEngine();

final recommendations = engine.generateRecommendations(
  sessions: recentSessions,
  quizzes: recentQuizzes,
  masteryData: masteryProgress,
  config: RecommendationConfig(
    accuracyThreshold: 0.7,
    skipThreshold: 0.2,
    timeThreshold: Duration(seconds: 90),
    inactivityDays: 7,
  ),
);

// Recommendation types:
// - RecommendationType.reviewTopic
// - RecommendationType.practiceMore
// - RecommendationType.slowDown
// - RecommendationType.speedUp
// - RecommendationType.focusOnWeakAreas
// - RecommendationType.maintainStreak
// - RecommendationType.celebrateProgress
```

## Pre-built Screens

### AnalyticsDashboard

Complete analytics dashboard with all widgets.

```dart
AnalyticsDashboard(
  data: LearningAnalyticsData(
    sessions: sessions,
    quizzes: quizzes,
    streakData: streakData,
    masteryData: masteryData,
    recommendations: recommendations,
    totalXp: 1500,
    currentLevel: 5,
    xpToNextLevel: 500,
  ),
  showHeader: true,
  showStreak: true,
  showRecommendations: true,
  showRecentActivity: true,
)
```

## Theming

### LearningAnalyticsTheme

Apply consistent theming across all widgets.

```dart
LearningAnalyticsTheme(
  data: LearningAnalyticsThemeData(
    primaryColor: Colors.blue,
    correctColor: Colors.green,
    incorrectColor: Colors.red,
    skippedColor: Colors.orange,
    chartStyle: ChartStyle.rounded,
    animationDuration: Duration(milliseconds: 300),
  ),
  child: AnalyticsDashboard(...),
)
```

### Pre-built Themes

```dart
// Light theme (default)
LearningAnalyticsThemeData.light()

// Dark theme
LearningAnalyticsThemeData.dark()

// Colorful theme
LearningAnalyticsThemeData.colorful()

// Access theme in widgets
final theme = LearningAnalyticsTheme.of(context);
```

### Color Schemes

```dart
// Pre-built heatmap color schemes
HeatmapColorScheme.green  // GitHub-style
HeatmapColorScheme.blue
HeatmapColorScheme.purple
HeatmapColorScheme.orange
HeatmapColorScheme.red

// Analytics color schemes
AnalyticsColorSchemes.defaultScheme
AnalyticsColorSchemes.ocean
AnalyticsColorSchemes.forest
AnalyticsColorSchemes.sunset
AnalyticsColorSchemes.neon
```

## Data Models

### LearningSession

```dart
LearningSession(
  id: 'session-1',
  startTime: DateTime.now().subtract(Duration(hours: 1)),
  endTime: DateTime.now(),
  questionsAttempted: 20,
  correctAnswers: 15,
  wrongAnswers: 3,
  skippedQuestions: 2,
  subjectId: 'math',
  topicId: 'algebra',
  xpEarned: 150,
)
```

### QuizAnalytics

```dart
QuizAnalytics(
  id: 'quiz-1',
  title: 'Algebra Quiz',
  totalQuestions: 20,
  correctAnswers: 17,
  wrongAnswers: 2,
  skippedQuestions: 1,
  totalTime: Duration(minutes: 15),
  averageTimePerQuestion: Duration(seconds: 45),
  completedAt: DateTime.now(),
  topicBreakdown: {'Equations': 0.9, 'Inequalities': 0.7},
  difficultyBreakdown: {'Easy': 1.0, 'Medium': 0.8, 'Hard': 0.6},
)
```

### StreakData

```dart
StreakData(
  currentStreak: 7,
  longestStreak: 15,
  totalActiveDays: 45,
  lastActiveDate: DateTime.now(),
  streakStartDate: DateTime.now().subtract(Duration(days: 6)),
  activities: activities,
  freezeDaysUsed: 2,
  freezeDaysAvailable: 3,
)
```

## Utilities

### Formatters

```dart
// Format percentages
AnalyticsFormatters.formatPercentage(0.856); // "85.6%"
AnalyticsFormatters.formatPercentage(0.856, decimals: 0); // "86%"

// Format durations
AnalyticsFormatters.formatDuration(Duration(minutes: 5, seconds: 30)); // "5:30"
AnalyticsFormatters.formatDurationLong(Duration(hours: 1, minutes: 30)); // "1h 30m"

// Format dates
AnalyticsFormatters.formatDate(DateTime.now()); // "Jan 21, 2024"
AnalyticsFormatters.formatRelativeDate(DateTime.now().subtract(Duration(days: 1))); // "Yesterday"

// Format grades
AnalyticsFormatters.formatGrade(0.92); // "A"
AnalyticsFormatters.formatGrade(0.85); // "B"
```

### Extensions

```dart
// List<LearningSession> extensions
sessions.totalQuestions; // Sum of all questions
sessions.totalCorrect; // Sum of correct answers
sessions.overallAccuracy; // Combined accuracy
sessions.totalDuration; // Combined duration

// List<QuizAnalytics> extensions
quizzes.averageAccuracy;
quizzes.averageTime;
quizzes.bestQuiz;
quizzes.worstQuiz;

// DateTime extensions
date.isToday;
date.isYesterday;
date.startOfDay;
date.endOfDay;
date.startOfWeek;
```

## Example

See the [example](example/) directory for a complete demo app showcasing all features.

```bash
cd example
flutter run
```

## Dependencies

- [fl_chart](https://pub.dev/packages/fl_chart) - Beautiful charts
- [intl](https://pub.dev/packages/intl) - Date and number formatting

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by learning analytics best practices from educational research
- Forgetting curve implementation based on Ebbinghaus's research
- Mastery calculation inspired by spaced repetition systems (FSRS, SM-2)
