import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock notifications for demonstration
    final List<Map<String, String>> notifications = [
      {
        'title': 'Welcome to Stride! 🏃‍♂️',
        'body': 'Your fitness journey starts today. Let\'s get moving!',
        'time': 'Just now',
      },
      {
        'title': 'Goal Reached! 🎉',
        'body': 'You completed your 10,000 steps yesterday. Awesome job!',
        'time': 'Yesterday',
      },
      {
        'title': 'Stay Hydrated! 💧',
        'body': 'Don\'t forget to drink water during your workout.',
        'time': '2 days ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stride', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 24)),
            Text('Notifications', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: Color(0xFF3D5AFE), size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['title']!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(n['body']!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
                      const SizedBox(height: 10),
                      Text(n['time']!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
