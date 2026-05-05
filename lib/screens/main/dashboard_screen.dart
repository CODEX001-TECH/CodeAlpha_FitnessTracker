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

class _DashboardScreenState extends State<DashboardScreen> {
  late PedometerService _pedometerService;
  final String _quote = QuoteConstants.getRandomQuote();

  @override
  void initState() {
    super.initState();
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    _pedometerService = PedometerService(
      onStepCount: (steps) => activityProvider.updateLiveSteps(steps),
    );
    _pedometerService.start();
  }

  @override
  void dispose() {
    _pedometerService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider?>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.directions_run_rounded, color: Color(0xFF3D5AFE), size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${activityProvider?.displayName ?? 'User'}!',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 24),
                ),
                Text(
                  _quote,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.onSurface),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          // Simulation Button for PC users
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
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Motivational Quote Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3D5AFE), Color(0xFF00B0FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D5AFE).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, color: Colors.white70, size: 30),
                        const SizedBox(height: 10),
                        Text(
                          _quote,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Weekly Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 15),
                  WeeklyChart(data: activityProvider.weeklyCalorieData),
                  const SizedBox(height: 30),
                  const Text(
                    'Today\'s Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3D5AFE)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your phone is automatically tracking your steps in the background.',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 20),
                  // Summary Cards Row
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Steps',
                        activityProvider.totalSteps.toInt().toString(),
                        Icons.directions_walk,
                        Colors.orange,
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Calories',
                        activityProvider.totalCaloriesBurned.toInt().toString(),
                        Icons.local_fire_department,
                        Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Recent Activities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 15),
                  // Activities List
                  activityProvider.activities.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: Text('No activities logged yet.',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activityProvider.activities.length,
                          itemBuilder: (context, index) {
                            final activity = activityProvider.activities[index];
                            return _buildActivityTile(activity);
                          },
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Log New Activity',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogActivityScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), 
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.blueAccent),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                ),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(activity.timestamp),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${activity.value.toInt()} ${activity.unit}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }
}
