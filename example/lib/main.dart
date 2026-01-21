import 'package:flutter/material.dart';
import 'package:flutter_learning_analytics/flutter_learning_analytics.dart';

void main() {
  runApp(const LearningAnalyticsExampleApp());
}

class LearningAnalyticsExampleApp extends StatelessWidget {
  const LearningAnalyticsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Analytics Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ChartsExamplePage(),
    const WidgetsExamplePage(),
    const DashboardExamplePage(),
    const CalculatorsExamplePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LearningAnalyticsTheme(
      data: LearningAnalyticsThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Learning Analytics Demo'),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Charts',
            ),
            NavigationDestination(
              icon: Icon(Icons.widgets),
              label: 'Widgets',
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate),
              label: 'Calculators',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Charts Example Page
// ============================================================================

class ChartsExamplePage extends StatelessWidget {
  const ChartsExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle(context, 'Accuracy Pie Chart'),
        const SizedBox(height: 8),
        const SizedBox(
          height: 250,
          child: AccuracyPieChart(
            correct: 75,
            wrong: 15,
            skipped: 10,
            showPercentages: true,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Performance Bar Chart'),
        const SizedBox(height: 8),
        PerformanceBarChart(
          data: {
            'Math': 85,
            'Science': 72,
            'History': 65,
            'English': 90,
            'Art': 78,
          },
          showValues: true,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Progress Line Chart'),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ProgressLineChart(
            data: _generateProgressPoints(),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Time Line Chart'),
        const SizedBox(height: 8),
        const SizedBox(
          height: 200,
          child: TimeLineChart(
            times: [
              Duration(seconds: 45),
              Duration(seconds: 30),
              Duration(seconds: 60),
              Duration(seconds: 25),
              Duration(seconds: 50),
              Duration(seconds: 35),
              Duration(seconds: 40),
              Duration(seconds: 55),
            ],
            threshold: Duration(seconds: 45),
            showAverage: true,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Retention Curve Chart'),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: RetentionCurveChart(
            data: RetentionData(
              itemId: 'example-item',
              createdAt: DateTime.now().subtract(const Duration(days: 7)),
              stability: 7.0,
            ),
            targetRetention: 0.9,
            showOptimalReviewTimes: true,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Radar Skill Chart'),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: RadarSkillChart(
            skills: {
              'Problem Solving': 0.85,
              'Critical Thinking': 0.72,
              'Memory': 0.65,
              'Speed': 0.90,
              'Accuracy': 0.78,
            },
            showAverage: true,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Heatmap Calendar'),
        const SizedBox(height: 8),
        HeatmapCalendar(
          data: _generateActivityData(),
          colorScheme: HeatmapColorScheme.green,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Streak Calendar'),
        const SizedBox(height: 8),
        StreakCalendar(
          streakData: _generateStreakData(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  static List<ProgressPoint> _generateProgressPoints() {
    final now = DateTime.now();
    return List.generate(10, (index) {
      return ProgressPoint(
        date: now.subtract(Duration(days: 9 - index)),
        value: 50 + (index * 5.0) + (index % 2 == 0 ? 2 : -1),
        label: 'Day ${index + 1}',
      );
    });
  }

  static Map<DateTime, int> _generateActivityData() {
    final data = <DateTime, int>{};
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      // Generate activity based on date
      final activity = (date.day + date.month) % 5;
      if (activity > 0) {
        data[DateTime(date.year, date.month, date.day)] = activity;
      }
    }
    return data;
  }

  static StreakData _generateStreakData() {
    final now = DateTime.now();
    final weekday = now.weekday;

    // Create weekly activity - active for past days this week
    final weeklyActivity = <int, bool>{};
    for (int i = 1; i <= 7; i++) {
      weeklyActivity[i] = i <= weekday;
    }

    return StreakData(
      currentStreak: 7,
      longestStreak: 15,
      totalActiveDays: 20,
      lastActivityDate: now,
      weeklyActivity: weeklyActivity,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

// ============================================================================
// Widgets Example Page
// ============================================================================

class WidgetsExamplePage extends StatelessWidget {
  const WidgetsExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle(context, 'Score Card'),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(
              child: ScoreCard(
                score: 85,
                maxScore: 100,
                label: 'Quiz Score',
                showGrade: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ScoreCard(
                score: 72,
                maxScore: 100,
                label: 'Test Score',
                showGrade: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Mastery Indicator'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            MasteryIndicator.fromScore(0.15),
            MasteryIndicator.fromScore(0.35),
            MasteryIndicator.fromScore(0.55),
            MasteryIndicator.fromScore(0.75),
            MasteryIndicator.fromScore(0.95),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Progress Ring'),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ProgressRing(
              value: 0.75,
              size: 80,
              strokeWidth: 8,
              showPercentage: true,
            ),
            LabeledProgressRing(
              value: 0.85,
              size: 80,
              title: 'Math',
              subtitle: '85%',
            ),
            ProgressRing(
              value: 0.45,
              size: 80,
              strokeWidth: 8,
              showPercentage: true,
              foregroundColor: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Stat Tiles'),
        const SizedBox(height: 8),
        const StatTileRow(
          tiles: [
            StatTileData(
              label: 'Total Questions',
              value: '1,234',
              icon: Icons.quiz,
              iconColor: Colors.blue,
            ),
            StatTileData(
              label: 'Accuracy',
              value: '85%',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              trend: '+5.2%',
              trendPositive: true,
            ),
            StatTileData(
              label: 'Streak',
              value: '7 days',
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Comparison Card'),
        const SizedBox(height: 8),
        const ComparisonCard(
          currentValue: 85,
          targetValue: 90,
          title: 'Quiz Performance',
          showDifference: true,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Recommendation Cards'),
        const SizedBox(height: 8),
        RecommendationList(
          recommendations: [
            Recommendation(
              id: '1',
              type: RecommendationType.subjectFocus,
              title: 'Review Algebra',
              description:
                  'Your accuracy in Algebra has dropped. Consider reviewing the basics.',
              priority: RecommendationPriority.high,
              relatedTopicId: 'algebra',
            ),
            Recommendation(
              id: '2',
              type: RecommendationType.retention,
              title: 'Practice Geometry',
              description: "You haven't practiced Geometry in 5 days.",
              priority: RecommendationPriority.medium,
              relatedTopicId: 'geometry',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Achievement Badges'),
        const SizedBox(height: 8),
        const AchievementGrid(
          achievements: [
            AchievementData(
              id: '1',
              title: 'First Quiz',
              description: 'Complete your first quiz',
              icon: Icons.emoji_events,
              color: Colors.amber,
              isUnlocked: true,
            ),
            AchievementData(
              id: '2',
              title: 'Perfect Score',
              description: 'Get 100% on any quiz',
              icon: Icons.star,
              color: Colors.purple,
              isUnlocked: true,
            ),
            AchievementData(
              id: '3',
              title: '7 Day Streak',
              description: 'Study for 7 days in a row',
              icon: Icons.local_fire_department,
              color: Colors.orange,
              isUnlocked: true,
            ),
            AchievementData(
              id: '4',
              title: '30 Day Streak',
              description: 'Study for 30 days in a row',
              icon: Icons.whatshot,
              color: Colors.red,
              isUnlocked: false,
              progress: 0.23,
            ),
            AchievementData(
              id: '5',
              title: 'Speed Demon',
              description: 'Answer 10 questions under 30s',
              icon: Icons.flash_on,
              color: Colors.blue,
              isUnlocked: false,
              progress: 0.7,
            ),
            AchievementData(
              id: '6',
              title: 'Knowledge Master',
              description: 'Reach expert level in any topic',
              icon: Icons.psychology,
              color: Colors.teal,
              isUnlocked: false,
              progress: 0.85,
            ),
          ],
          crossAxisCount: 3,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

// ============================================================================
// Dashboard Example Page
// ============================================================================

class DashboardExamplePage extends StatelessWidget {
  const DashboardExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnalyticsDashboard(
      data: _generateDashboardData(),
    );
  }

  static LearningAnalyticsData _generateDashboardData() {
    final now = DateTime.now();

    // Generate sessions
    final sessions = List.generate(10, (index) {
      final date = now.subtract(Duration(days: index));
      return LearningSession(
        id: 'session-$index',
        startTime: date.subtract(const Duration(hours: 1)),
        endTime: date,
        questionsAttempted: 20 + index,
        correctAnswers: 15 + (index % 5),
        wrongAnswers: 3 + (index % 3),
        skippedQuestions: 2,
        subjectId: 'math',
        topicId: 'algebra',
        xpEarned: 100 + (index * 10),
      );
    });

    // Generate quizzes
    final quizzes = List.generate(5, (index) {
      return QuizAnalytics(
        quizId: 'quiz-$index',
        totalQuestions: 20,
        correctAnswers: 15 + index,
        wrongAnswers: 3 - (index % 2),
        skippedQuestions: 2 - (index % 2),
        timeTaken: Duration(minutes: 15 + index),
        completedAt: now.subtract(Duration(days: index)),
        topicBreakdown: {
          'Algebra': 0.85,
          'Geometry': 0.72,
          'Calculus': 0.65,
        },
        difficultyBreakdown: {
          'Easy': 0.95,
          'Medium': 0.80,
          'Hard': 0.60,
        },
      );
    });

    // Generate streak data
    final weeklyActivity = <int, bool>{};
    for (int i = 1; i <= 7; i++) {
      weeklyActivity[i] = i <= 5;
    }

    final streakData = StreakData(
      currentStreak: 7,
      longestStreak: 15,
      totalActiveDays: 20,
      lastActivityDate: now,
      weeklyActivity: weeklyActivity,
    );

    // Generate mastery data
    final masteryData = [
      MasteryProgress(
        topicId: 'algebra',
        topicName: 'Algebra',
        currentScore: 0.85,
        totalAttempts: 50,
        correctAttempts: 42,
        lastAttemptDate: now,
      ),
      MasteryProgress(
        topicId: 'geometry',
        topicName: 'Geometry',
        currentScore: 0.65,
        totalAttempts: 30,
        correctAttempts: 20,
        lastAttemptDate: now.subtract(const Duration(days: 2)),
      ),
      MasteryProgress(
        topicId: 'calculus',
        topicName: 'Calculus',
        currentScore: 0.45,
        totalAttempts: 15,
        correctAttempts: 7,
        lastAttemptDate: now.subtract(const Duration(days: 5)),
      ),
    ];

    // Generate recommendations
    final recommendations = [
      Recommendation(
        id: '1',
        type: RecommendationType.reviewDifficult,
        title: 'Review Calculus',
        description:
            'Your mastery in Calculus is below target. Consider reviewing the basics.',
        priority: RecommendationPriority.high,
        relatedTopicId: 'calculus',
      ),
      Recommendation(
        id: '2',
        type: RecommendationType.retention,
        title: 'Practice Geometry',
        description: "You haven't practiced Geometry in 2 days.",
        priority: RecommendationPriority.medium,
        relatedTopicId: 'geometry',
      ),
    ];

    return LearningAnalyticsData(
      sessions: sessions,
      quizzes: quizzes,
      streakData: streakData,
      masteryProgress: masteryData,
      recommendations: recommendations,
      totalXp: 1500,
      currentLevel: 5,
    );
  }
}

// ============================================================================
// Calculators Example Page
// ============================================================================

class CalculatorsExamplePage extends StatefulWidget {
  const CalculatorsExamplePage({super.key});

  @override
  State<CalculatorsExamplePage> createState() => _CalculatorsExamplePageState();
}

class _CalculatorsExamplePageState extends State<CalculatorsExamplePage> {
  final _masteryCalculator = const MasteryCalculator();
  final _retentionCalculator = const RetentionCalculator();
  final _streakCalculator = const StreakCalculator();

  double _masteryScore = 0.5;
  int _attempts = 5;
  double _stability = 7.0;
  int _daysSinceReview = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle(context, 'Mastery Calculator'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Current Score: ${(_masteryScore * 100).toStringAsFixed(1)}%'),
                Text('Total Attempts: $_attempts'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _attempts++;
                          _masteryScore = _masteryCalculator.calculateNewScore(
                            currentScore: _masteryScore,
                            wasCorrect: true,
                            totalAttempts: _attempts,
                          );
                        });
                      },
                      icon: const Icon(Icons.check, color: Colors.green),
                      label: const Text('Correct'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _attempts++;
                          _masteryScore = _masteryCalculator.calculateNewScore(
                            currentScore: _masteryScore,
                            wasCorrect: false,
                            totalAttempts: _attempts,
                          );
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Wrong'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _masteryScore = 0.5;
                          _attempts = 5;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Mastery Level: ${_masteryCalculator.getLevelForScore(_masteryScore).displayName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _masteryCalculator
                        .getLevelForScore(_masteryScore)
                        .defaultColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Retention Calculator'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stability: ${_stability.toStringAsFixed(1)} days'),
                Slider(
                  value: _stability,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '${_stability.toStringAsFixed(1)} days',
                  onChanged: (value) {
                    setState(() {
                      _stability = value;
                    });
                  },
                ),
                Text('Days Since Review: $_daysSinceReview'),
                Slider(
                  value: _daysSinceReview.toDouble(),
                  min: 0,
                  max: 30,
                  divisions: 30,
                  label: '$_daysSinceReview days',
                  onChanged: (value) {
                    setState(() {
                      _daysSinceReview = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final retention =
                        _retentionCalculator.calculateRetrievability(
                      daysSinceReview: _daysSinceReview.toDouble(),
                      stability: _stability,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retention: ${(retention * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: retention,
                          backgroundColor: Colors.grey.shade200,
                          color: retention > 0.9
                              ? Colors.green
                              : retention > 0.7
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Formula: R = e^(-t/S) = e^(-$_daysSinceReview/${_stability.toStringAsFixed(1)})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Streak Calculator'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Activity History (last 14 days):'),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final now = DateTime.now();
                    final activityDates = <DateTime>{};

                    // Simulate activity pattern
                    for (int i = 0; i < 14; i++) {
                      final date = DateTime(now.year, now.month, now.day)
                          .subtract(Duration(days: i));
                      if (i < 7 || (i > 8 && i < 12)) {
                        activityDates.add(date);
                      }
                    }

                    final currentStreak =
                        _streakCalculator.calculateCurrentStreak(activityDates);
                    final longestStreak =
                        _streakCalculator.calculateLongestStreak(activityDates);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: List.generate(14, (index) {
                            final date = DateTime(now.year, now.month, now.day)
                                .subtract(Duration(days: 13 - index));
                            final isActive = activityDates.contains(date);
                            return Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        Text('Current Streak: $currentStreak days'),
                        Text('Longest Streak: $longestStreak days'),
                        Text('Total Active Days: ${activityDates.length}'),
                        Text(
                            'Streak Active: ${currentStreak > 0 ? "Yes" : "No"}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
