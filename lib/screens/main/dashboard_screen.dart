import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../models/activity.dart';
import 'package:intl/intl.dart';
import 'log_activity_screen.dart';
import '../../widgets/weekly_chart.dart';
import '../../services/pedometer_service.dart';
import '../../constants/quote_constants.dart';
import 'notifications_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late PedometerService _pedometerService;
  final String _quote = QuoteConstants.getRandomQuote();

  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    _pedometerService = PedometerService(
      onStepCount: (steps) => activityProvider.updateLiveSteps(steps),
    );
    _pedometerService.start();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOutCubic,
    );
    _ringController.forward();
  }

  @override
  void dispose() {
    _pedometerService.stop();
    _ringController.dispose();
    super.dispose();
  }

  /// Returns an icon and color appropriate for a given activity type.
  (IconData, Color) _getActivityIconAndColor(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return (Icons.directions_run_rounded, const Color(0xFF3D5AFE));
      case 'walking':
        return (Icons.directions_walk_rounded, Colors.teal);
      case 'cycling':
        return (Icons.directions_bike_rounded, Colors.orange);
      case 'gym':
        return (Icons.fitness_center_rounded, Colors.purple);
      case 'swimming':
        return (Icons.pool_rounded, Colors.cyan);
      default:
        return (Icons.sports_rounded, Colors.blueGrey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider?>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 720;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.directions_run_rounded,
                color: Color(0xFF3D5AFE), size: 30),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${activityProvider?.displayName ?? 'User'}!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: isWideScreen ? 22 : 18,
                  ),
                ),
                Text(
                  _quote,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded,
                color: Theme.of(context).colorScheme.onSurface),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.directions_run, color: Color(0xFF3D5AFE)),
            tooltip: 'Simulate Step (Testing)',
            onPressed: () {
              if (activityProvider != null) {
                _pedometerService.simulateStep(activityProvider.liveSteps);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: activityProvider == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isWideScreen ? 30 : 18),
              child: isWideScreen
                  ? _buildWideLayout(context, activityProvider)
                  : _buildNarrowLayout(context, activityProvider),
            ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Log New Activity',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogActivityScreen()),
          );
        },
        backgroundColor: const Color(0xFF3D5AFE),
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Log Activity', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // === WIDE LAYOUT (Tablets / Desktop) ===
  Widget _buildWideLayout(
      BuildContext context, ActivityProvider activityProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Quote + Ring + Stats
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildQuoteCard(context),
              const SizedBox(height: 24),
              _buildGoalRingCard(context, activityProvider),
              const SizedBox(height: 20),
              _buildSummaryRow(context, activityProvider),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right column: Chart + Activities
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Weekly Progress'),
              const SizedBox(height: 12),
              WeeklyChart(data: activityProvider.weeklyCalorieData),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Recent Activities'),
              const SizedBox(height: 12),
              _buildActivitiesList(context, activityProvider),
            ],
          ),
        ),
      ],
    );
  }

  // === NARROW LAYOUT (Mobile / Small screens) ===
  Widget _buildNarrowLayout(
      BuildContext context, ActivityProvider activityProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuoteCard(context),
        const SizedBox(height: 24),
        _buildGoalRingCard(context, activityProvider),
        const SizedBox(height: 20),
        _buildSummaryRow(context, activityProvider),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Weekly Progress'),
        const SizedBox(height: 12),
        WeeklyChart(data: activityProvider.weeklyCalorieData),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Recent Activities'),
        const SizedBox(height: 12),
        _buildActivitiesList(context, activityProvider),
        const SizedBox(height: 80), // FAB spacing
      ],
    );
  }

  // === GOAL RING CARD ===
  Widget _buildGoalRingCard(
      BuildContext context, ActivityProvider activityProvider) {
    final steps = activityProvider.totalSteps;
    final goal = activityProvider.stepGoal.toDouble();
    final progress = (steps / goal).clamp(0.0, 1.0);
    final isGoalMet = steps >= goal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGoalMet
              ? [const Color(0xFF00C853), const Color(0xFF00E5FF)]
              : [const Color(0xFF3D5AFE), const Color(0xFF00B0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isGoalMet ? Colors.green : const Color(0xFF3D5AFE))
                .withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isGoalMet ? '🎉 Goal Reached!' : 'Daily Step Goal',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _ringAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(160, 160),
                painter: _RingPainter(
                    progress: progress * _ringAnimation.value,
                    isGoalMet: isGoalMet),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          steps.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'steps',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            '${(progress * 100).toInt()}% of ${NumberFormat('#,###').format(goal.toInt())} goal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // === SUMMARY ROW (Steps + Calories) ===
  Widget _buildSummaryRow(
      BuildContext context, ActivityProvider activityProvider) {
    return Row(
      children: [
        _buildSummaryCard(
          context,
          'Steps',
          activityProvider.totalSteps.toInt().toString(),
          Icons.directions_walk_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 15),
        _buildSummaryCard(
          context,
          'Calories',
          '${activityProvider.totalCaloriesBurned.toInt()} kcal',
          Icons.local_fire_department_rounded,
          Colors.redAccent,
        ),
      ],
    );
  }

  // === QUOTE CARD (Vibrant Gradient) ===
  Widget _buildQuoteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D5AFE).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY MOTIVATION',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _quote,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === SECTION TITLE ===
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  // === ACTIVITIES LIST with Swipe-to-Delete ===
  Widget _buildActivitiesList(
      BuildContext context, ActivityProvider activityProvider) {
    if (activityProvider.activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.inbox_rounded,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.2)),
              const SizedBox(height: 12),
              Text(
                'No activities logged yet.\nTap the button below to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activityProvider.activities.length,
      itemBuilder: (context, index) {
        final activity = activityProvider.activities[index];
        return Dismissible(
          key: Key(activity.id ?? index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.85),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Activity'),
                content: const Text(
                    'Are you sure you want to delete this activity?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
          },
          onDismissed: (_) {
            if (activity.id != null) {
              activityProvider.deleteActivity(activity.id!);
            }
          },
          child: _buildActivityTile(context, activity),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, Activity activity) {
    final (icon, color) = _getActivityIconAndColor(activity.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(activity.timestamp),
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${activity.value.toInt()} ${activity.unit}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14),
              ),
              Text(
                '${activity.caloriesBurned.toInt()} kcal',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// === CIRCULAR RING PAINTER ===
class _RingPainter extends CustomPainter {
  final double progress;
  final bool isGoalMet;

  _RingPainter({required this.progress, required this.isGoalMet});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 12.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: isGoalMet
            ? [Colors.white, Colors.greenAccent]
            : [Colors.white, Colors.lightBlueAccent],
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        tileMode: TileMode.clamp,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
